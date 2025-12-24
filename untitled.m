clear all;

num_points = 100;
t_total = 20;

time_total_array = linspace(0, t_total, num_points);

p = zeros(3, num_points);

theta1 = zeros(1, num_points);
k = zeros(1, num_points);
d = zeros(1, num_points);

r = 0.02;      % Ακτίνα κύκλου (2 cm)

R = [cosd(45) 0 sind(45); 0 1 0; -sind(45) 0 cosd(45)];

%c = [0.01; 0.01; 0.05];      % Συντεταγμένες κέντρου
c = [0; 0; 0];

s = linspace(0, 2*pi, num_points);

% Υπολογισμός Κύκλου
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
arduino = serialport("COM5", 9600);   % άλλαξε COM αν χρειάζεται
pause(2);  % σταθεροποίηση Arduino

%STARTING POSITION

writeline(arduino, sprintf("1 %.3f", theta1(1));
writeline(arduino, sprintf("2 %.3f", theta2(1));
pause(5);

prev_d = d_cm(1);
prev_t = time_total_array(1);

for i = 5:5:num_points

    if(

    %SERVO 1 (θ1)

    writeline(arduino, sprintf("1 %.3f", theta1(i)));
    pause(0.05);

    %SERVO 2 (θ2) 

    writeline(arduino, sprintf("2 %.3f", theta2(i));
    pause(0.05);

    %STEPPER (d)

    current_d = d_cm(i);               % cm
    difference = current_d - prev_d;   % cm διαφορά
    prev_d = current_d;

    writeline(arduino, sprintf("3 %.4f", difference));

    current_t = time_total_array(i);
    difference_t = current_t - prev_t;
    prev_t = time_total_array(i);
    pause(difference_t);
end
%}
