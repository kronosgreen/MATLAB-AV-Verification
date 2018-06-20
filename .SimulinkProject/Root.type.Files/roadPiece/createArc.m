function [roadPoints, forwardPaths, reversePaths, inPoint, facing] = createArc(roadPoints, inPoint, facing, length, curvature, lanes, bidirectional, midTurnLane)
%CREATEARC create an arc road piece, or a piece with a constant curvature,
% otherwise part of a circle

% get lane width from global
global LANE_WIDTH;

% number of points desired in arc
N = 5;

% create empty matrix for forward paths
forwardPaths = zeros(lanes, N * 3);

% radian space between start and end
angle = linspace(0, length * curvature, N);

% initial points for x and y of arc starting at 0, 0 and turning left with
% a negative curvature and right with a positive curvature
x = (cos(angle) - 1) / -curvature;
y = sin(angle) / abs(curvature);

% set up initial curve points
curvePoints = [x.' y.' zeros(N, 1)];

% flip correction for when a left turning road has its points
% flipped, used only for paths on road
fc = (curvature < 0);

% set up lane paths
if bidirectional
    reversePaths = zeros(lanes, N*3);
    for j=1:N
        theta = -(length * curvature) * (j-1)/N;
        for i=1:lanes
            forwardPaths(i,3*j-2:3*j) = curvePoints(j,:) + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
            
            reversePaths(i,3*j-2:3*j) = curvePoints(j,:) + [cos(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        end
    end
else
    reversePaths = 0;
    for j=1:N
        theta = -(length * curvature) * (j-1)/N;
        for i=1:lanes
            forwardPaths(i,3*j-2:3*j) = curvePoints(j,:) + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
        end
    end
end



% rotation matrix
R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];

for i=1:size(curvePoints,1)
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

roadPoints = [roadPoints; curvePoints];

end

