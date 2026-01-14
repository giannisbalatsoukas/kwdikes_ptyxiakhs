function [theta1, k, d] = inverse_kinematics(px, py, pz)

    % s: συνολικό μήκος τόξου [deg*m]
    % k: καμπυλότητα (curvature)(deg per unit length, ώστε s*k να είναι σε μοίρες)[m^(-1)]
    % d1: axial offset [m]
    % θ1: γωνία σε μοίρες [0, 360)

    % cosd(X) is the cosine of the elements of X , expressed in degrees 
    % cosd(90) is exactly zero
    % cos(pi/2) reflects the accuracy of the floating point value of pi 

    s = 0.048;
    tol = 1e-6;
    h = 1e-6;      
    MaxIter = 200;
    k0 = 0.002;
    kk(1) = k0;

    r = hypot(px, py);

    f = @(k) (1./k).*(1 - cos(s.*k)) - r;

    fval = f(kk(1));

    for i = 1:MaxIter
        dfdk = (f(kk(i)+h) - f(kk(i)-h)) / (2*h);
        dk = -fval / dfdk;
        kk(i+1) = kk(i) + dk;
        fval = f(kk(i+1));
    
        if abs(kk(i+1) - kk(i)) < tol
            break;
        end
    end

    k = kk(i+1);

    d = pz -(1/k)*sin(s*k);

    theta1_rad = atan2((-k*py)/(1-cos(s*k)), (-k*px)/(1-cos(s*k)));

    theta1 = (180/pi)*theta1_rad;

    %if theta1 < 0
    %    theta1 = theta1 + 360;
    %end

end