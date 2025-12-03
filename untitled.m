clear all;

num_points = 100;
t_total = 20;

time_total_array = linspace(0, t_total, num_points);

p = zeros(3, num_points);

theta1 = zeros(1, num_points);
k = zeros(1, num_points);
d = zeros(1, num_points);

r = 0.01;      % Ακτίνα κύκλου (1 cm)

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
end

figure;
plot3(p(1,:), p(2,:), p(3,:), 'LineWidth', 2);
grid on;
axis equal;
xlabel('X');
ylabel('Y');
zlabel('Z');

xlim([-0.2 0.2]);
ylim([-0.2 0.2]);
zlim([-0.2 0.2]);

figure(2);

subplot(3,1,1);
plot(time_total_array, theta1);
xlabel('t');
ylabel('theta1');
grid on;

subplot(3,1,2);
plot(time_total_array, k);
xlabel('t');
ylabel('k');
grid on;

subplot(3,1,3);
plot(time_total_array, d);
xlabel('t');
ylabel('d');
grid on;