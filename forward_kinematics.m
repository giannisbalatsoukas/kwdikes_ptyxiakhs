function [px, py, pz] = forward_kinematics(theta1, k, d)

    % s: συνολικό μήκος τόξου [deg*m]
    % k: καμπυλότητα (curvature)(deg per unit length, ώστε s*k να είναι σε μοίρες)[m^(-1)]
    % d1: axial offset [m]
    % θ1: γωνία σε μοίρες [0, 360)

    % cosd(X) is the cosine of the elements of X , expressed in degrees 
    % cosd(90) is exactly zero
    % cos(pi/2) reflects the accuracy of the floating point value of pi 

    s = 0.048; 
    
    px = -(1/k)*cosd(theta1)*(1-cos(s*k));
    py = -(1/k)*sind(theta1)*(1-cos(s*k));
    pz = d + (1/k)*sin(s*k)
end