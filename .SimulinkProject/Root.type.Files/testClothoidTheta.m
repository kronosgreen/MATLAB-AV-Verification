function [finish] = testClothoidTheta(curvature, length)
%TESTCLOTHOIDTHETA Function testing clothoid function and its calculation
%of theta, comparing it against a value based on the points 

% Open file for stat collecting
%fid = fopen('thetas_accuracy_data.txt', 'a');

% Number of points to test
N = 1000;

% array to store thetas, or change in direction at each point
thetas = zeros(1,N);

% set up empty matrix for points
clothoidPoints = zeros(N, 2);

% keep track of ratios between theta & actualTheta
thetaRatios = zeros(N,1);

%% clothoid points calculator

for i=1:N
    
    % curvature
    k_c = i * curvature / N;
    
    % End arc radius
    R_c = 1 / k_c;
    
    % End length
    s_c = i * length / N;
    
    % scaling factor
    a = sqrt(2 * R_c * s_c);
    
    % get point on clothoid 
    x = a * fresnels(s_c/a);
    y = a * fresnelc(s_c/a);
    
    clothoidPoints(i,:) = [x y];
    
    % change in facing tangent
    theta = double(mod(k_c * s_c / 2, 2*pi));
    
    % get change in facing tangent from atan to check accuracy
    if i > 1
        actualTheta = pi/2 - atan2( clothoidPoints(i,2)-clothoidPoints(i-1,2), clothoidPoints(i,1)-clothoidPoints(i-1,1) );
        actualTheta = double( mod( actualTheta, 2*pi ));
        change = double( actualTheta / theta );
        thetaRatios(i) = change;
        disp("#" + i + " | Theta : " + theta + "  ActTheta : " + actualTheta + "   Change : " + change);
        %fprintf(fid, '%d ', i);
        %if i < 10, fprintf(fid, ' '); end
        %fprintf(fid, '| %f ', startCurvature);
        %if startCurvature >= 0, fprintf(fid, ' '); end
        %fprintf(fid, '| %f ', endCurvature);
        %if endCurvature >= 0, fprintf(fid, ' '); end
        %fprintf(fid, '| %f | %f | %.2f \n',  actualTheta, theta, change);
    end
    
    thetas(i) = theta;
    
end
plot(thetaRatios); 
finish = 1;
%fclose(fid);

end

