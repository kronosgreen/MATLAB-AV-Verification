function [curvePoints, forwardPaths, reversePaths, inPoint, facing] = createArc(inPoint, facing, length, curvature)
%CREATEARC Summary of this function goes here
%   Detailed explanation goes here

% number of points desired in arc
N = 4;

% radian space between start and end
angle = linspace(0, length * curvature, N);

% initial points for x and y of arc starting at 0, 0 and turning left with
% a negative curvature and right with a positive curvature
x = (cos(angle) - 1) / -curvature;
y = sin(angle) / abs(curvature);

% set up initial curve points
curvePoints = [x.' y.' zeros(N, 1)];

% rotation matrix
R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];

for i=1:length(curvePoints)
   curvePoints(i,:) = [[curvePoints(i,1) curvePoints(i,2)]*R 0] + inPoint; 
end

for i=1:lanes
    for n=1:3:N*3
        forwardPaths(i,n:n+2) = [[forwardPaths(i,n) forwardPaths(i,n+1)]*R forwardPaths(i,n+2)] + inPoint;
        if bidirectional
            reversePaths(i,n:n+2) = [[reversePaths(i,n) reversePaths(i,n+1)]*R reversePaths(i,n+2)] + inPoint;
        end
    end
end

inPoint = curvePoints(N,:);

facing = mod(facing - length * curvature, 2 * pi);


end
