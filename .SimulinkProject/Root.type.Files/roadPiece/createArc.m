function [roadPoints, forwardPaths, reversePaths, inPoint, facing] = createArc(roadPoints, inPoint, facing, length, curvature, lanes, bidirectional, midTurnLane)
%CREATEARC create an arc road piece, or a piece with a constant curvature,
% otherwise part of a circle
disp("ARC");
% get lane width from global
global LANE_WIDTH;

% number of points desired in arc
N = 5;

% create empty matrix for forward paths
forwardPaths = zeros(lanes, N * 3);

% radian space between start and end
angle = linspace(0, abs(length * curvature), N);

% initial points for x and y of arc starting at 0, 0 and turning left with
% a negative curvature and right with a positive curvature
x = (cos(angle) - 1) / -curvature;
y = sin(angle) / abs(curvature);

% set up initial curve points
curvePoints = [x.' y.' zeros(N, 1)];


%% set up lane paths
% lane paths get set up to right and left of arc according to the arc angle
% which is the product of the length and curvature
if bidirectional
    reversePaths = zeros(lanes, N*3);
    for j=1:N
        theta = -(length*curvature) * (j-1) / (N-1);
        for i=1:lanes
            forwardPaths(i,3*j-2:3*j) = curvePoints(j,:) + ...
                [cos(theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) ...
                sin(theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) ...
                0];
            
            reversePaths(i,(N-j+1)*3-2:3*(N-j+1)) = curvePoints(j,:) + ...
                [cos(pi+theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) ...
                sin(pi+theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) ...
                0];
        end
    end
else
    reversePaths = 0;
    for j=1:N
        theta = -(length * curvature) * (j-1)/N;
        for i=1:lanes
            forwardPaths(i,3*j-2:3*j) = curvePoints(j,:) + ...
                [cos(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) ...
                sin(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) ...
                0];
        end
    end
end

%% Rotate to facing
% rotation matrix
R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];

for i=1:N
   curvePoints(i,:) = [curvePoints(i,1:2)*R curvePoints(i,3)] + inPoint;
   for j=1:lanes
        forwardPaths(j,i*3-2:i*3) = [forwardPaths(j,i*3-2:i*3-1)*R forwardPaths(j,i*3)] + inPoint;
        if bidirectional
            reversePaths(j,i*3-2:i*3) = [reversePaths(j,i*3-2:i*3-1)*R reversePaths(j,i*3)] + inPoint;
        end
   end
end

%% update values
% update inPoint
inPoint = curvePoints(N,:);

% update facing
facing = mod(facing - length * curvature, 2 * pi);

% update roadPoints
roadPoints = [roadPoints; curvePoints];

end

