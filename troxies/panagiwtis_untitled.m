clear all;

% --- [Your existing Geometry/Inverse Kinematics setup remains unchanged] ---
num_points = 100;
t_total = 20;
time_total_array = linspace(0, t_total, num_points);
p = zeros(3, num_points);
theta1 = zeros(1, num_points);
theta2 = zeros(1, num_points); % Ensure this is initialized
k = zeros(1, num_points);
d = zeros(1, num_points);
r = 0.02;    
R = [1 0 0; 0 cosd(45) sind(45); 0 -sind(45) cosd(45)];
c = [0; 0; 0];
s = linspace(0, 2*pi, num_points);

for i = 1:num_points
    p(:, i) = c + R * [r*cos(s(i)); r*sin(s(i)); 0];
end

for i = 1:num_points  
    [theta1(i), k(i), d(i)] = inverse_kinematics(p(1, i), p(2, i), p(3, i));
    theta2(i) = (k(i)/1.3319) - 0.9733;
end

figure;
plot3(p(1,:), p(2,:), p(3,:), 'LineWidth', 2);
grid on;
axis equal;
xlabel('X');
ylabel('Y');
zlabel('Z');

xlim([-0.05 0.05]);
ylim([-0.05 0.05]);
zlim([-0.05 0.05]);

figure(2);

subplot(5,1,1);
plot(time_total_array, theta1);
xlabel('t (s)');
ylabel('theta1 (degrees)');
grid on;

subplot(5,1,2);
plot(time_total_array, k);
xlabel('t (s)');
ylabel('k (1/m)');
grid on;

subplot(5,1,3);
plot(time_total_array, theta2);
xlabel('t (s)');
ylabel('theta2 (degrees)');
grid on;

subplot(5,1,4);
plot(time_total_array, d);
xlabel('t (s)');
ylabel('d (m)');
grid on;

d_cm = 100.*d;

subplot(5,1,5);
plot(time_total_array, d_cm);
xlabel('t (s)');
ylabel('d (cm)');
grid on;

%{
% ================= COMMUNICATION SETUP =================
arduino = serialport("COM6", 115200); % MUST match Arduino
pause(3);

% Define previous distance (for Stepper relative calc)
prev_d = d_cm(1);
prev_t = time_total_array(1);

% Move to Start Position (Optional)
fprintf("Starting Motion...\n");

% ================= MOTION LOOP =================
for i = 1:num_points
   
    % --- 1. PREPARE DATA ---
   
    % SERVO 1 & 2: Use Absolute Angle directly
    val_servo1 = theta1(i);
    val_servo2 = theta2(i);
   
    % STEPPER: Calculate Relative Change (Delta)
    % We keep this relative because stepper drivers work best adding steps to a queue
    current_d = d_cm(i);
    val_stepper_delta = current_d - prev_d;
    prev_d = current_d; % Update for next loop

    % --- 2. SEND COMMAND ---
    % Format: "AbsAngle1,AbsAngle2,DeltaDistance"
    % Example: "45.5, 12.0, 0.05"
    data_string = sprintf("%.4f,%.4f,%.4f", val_servo1, val_servo2, val_stepper_delta);
    writeline(arduino, data_string);
   
    % --- 3. TIMING ---
    % Calculate exact time to wait for this step
    current_t = time_total_array(i);
    if i > 1
        wait_time = current_t - prev_t;
    else
        wait_time = 0.1; % Default for first point
    end
    prev_t = current_t;
   
    % Small adjustment to keep buffer from overflowing
    pause(max(0, wait_time - 0.005));
end

fprintf("Motion Complete.\n");
clear arduino;
%}