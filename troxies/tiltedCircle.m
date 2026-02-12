clear all;

num_points = 200;
t_total = 20;

time_total_array = linspace(0, t_total, num_points);

p = zeros(3, num_points);

theta1 = zeros(1, num_points);
k = zeros(1, num_points);
d = zeros(1, num_points);

r = 0.02;      % Ακτίνα κύκλου (2 cm)

%R = [cosd(45) 0 sind(45); 0 1 0; -sind(45) 0 cosd(45)];
R = [1 0 0; 0 cosd(45) sind(45); 0 -sind(45) cosd(45)];

%c = [0.01; 0.01; 0.05];      % Συντεταγμένες κέντρου
c = [0; 0; 0];

s = linspace(0, 2*pi, num_points);

% Υπολογισμός Κύκλου
for i = 1:num_points
    p(:, i) = c + R * [r*cos(s(i)); r*sin(s(i)); 0];
end

for i = 1:num_points  
    [theta1(i), k(i), d(i)] = inverse_kinematics(p(1, i), p(2, i), p(3, i));

    %theta2(i) = (k(i)/1.3319) - 0.9733;
    theta2(i) = (k(i)-4.13262)/1.37473;
end

%Plotting
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

figure;

subplot(5,1,1);
plot(time_total_array, p(1,  :)*1000);
xlabel('t (s)');
ylabel('x');
grid on;

subplot(5,1,2);
plot(time_total_array, p(2, :)*1000);
xlabel('t (s)');
ylabel('y');
grid on;

subplot(5,1,3);
plot(time_total_array, p(3, :)*1000);
xlabel('t (s)');
ylabel('z');
grid on;

figure;

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

%exportcsv
%{
%Communication Setup
arduino = serialport("COM6", 115200);
pause(3);

%Define previous distance (for Stepper relative calc)
prev_d = d_cm(1);
prev_t = time_total_array(1);

%Starting Position
data_string = sprintf("%.4f,%.4f,%.4f", theta1(1), theta2(1), 0);
writeline(arduino, data_string);
pause(10);

tic
for i = 2:num_points
   
    % SERVO 1 & 2: Use Absolute Angle directly
    val_servo1 = theta1(i);
    val_servo2 = theta2(i);
   
    % STEPPER: Calculate Relative Change (Delta)
    % We keep this relative because stepper drivers work best adding steps to a queue
    current_d = d_cm(i);
    val_stepper = current_d - prev_d;
    prev_d = current_d; % Update for next loop

    % --- 2. SEND COMMAND ---
    % Format: "AbsAngle1,AbsAngle2,Distance"
    % Example: "45.5, 12.0, 0.05"
    %data_string = sprintf("%.4f,%.4f,%.4f", val_servo1, val_servo2, val_stepper);
    data_string = sprintf("%.4f,%.4f,%.4f", 0, val_servo2, 0);
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
   
    pause(wait_time);
end

toc

pause(2);
%Completion
data_string = sprintf("%.4f,%.4f,%.4f", 0, 0, 0);
writeline(arduino, data_string);
fprintf("Motion Complete.\n");
clear arduino;
%}