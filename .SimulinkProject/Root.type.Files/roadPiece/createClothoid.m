function [roadPoints, forwardPaths, reversePaths, inPoint, facing] = createClothoid(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane, startCurvature, endCurvature)
%CREATECLOTHOID Creates a clothoid line given a starting point, start and
%end curvature, and a facing direction. Returns points for driving paths as
%well

% check if curvature is changing signs, negative to positive or positive to
% negative
% also check to see if they are the same, in which case, an arc will be
% made instead
if (startCurvature < 0 && endCurvature > 0) || (startCurvature > 0 && endCurvature < 0)
    [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = createClothoid(roadPoints, inPoint, facing, length/2, lanes, bidirectional, midTurnLane, startCurvature, 0);
    [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = createClothoid(roadPoints, inPoint, facing, length/2, lanes, bidirectional, midTurnLane, 0, endCurvature);
    forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2];
    reversePaths = [rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
    return;
elseif startCurvature == endCurvature
    [roadPoints, forwardPaths, reversePaths, inPoint, facing] = createArc(roadPoints, inPoint, facing, length, startCurvature, lanes, bidirectional, midTurnLane);
    return;
end

% get global lane width
global LANE_WIDTH;

% flip correction for when a left turning road has its points
% flipped, used only for paths on road
fc = (endCurvature < 0);

% how many points make up the clothoid, including the starting point
N = 6;

% array to store thetas, or change in direction at each point
thetas = zeros(1,N);

% rate of change of curvature, is the constant used to determine the
% clothoid, as it remains at the same rate throughout the curve
d_k = abs(endCurvature - startCurvature) / length;

% starting length
length_start = min(abs(startCurvature), abs(endCurvature)) / d_k;

% length increments
length_iter = length / (N-1);

% set up empty matrices for paths
forwardPaths = zeros(lanes, N*3);
if bidirectional
    reversePaths = zeros(lanes, N*3);
else
    reversePaths = 0;
end

% set up empty matrix for points
clothoidPoints = zeros(N, 3);

% if either point is zero, can't use equation, so skip first point
if length_start == 0, p_start = 2; 
else, p_start = 1; end

%% clothoid points calculator

for i=p_start:N
    
    % curvature
    k_c = min(abs(startCurvature),abs(endCurvature)) + (i - 1) * length_iter * d_k;
    
    % End arc radius
    R_c = 1 / k_c;
    
    % End length
    s_c = length_start + (i - 1) * length_iter;
    
    % scaling factor
    a = sqrt(2 * R_c * s_c);
    
    % get point on clothoid 
    x = a * fresnels(s_c/a);
    y = a * fresnelc(s_c/a);
    
    clothoidPoints(i,:) = [x y 0];
    
    % change in facing tangent
    theta = (s_c/a)^2;
    
    thetas(i) = theta;
    
end
disp(thetas);
%% Adjust points back to zero if not starting at zero
if length_start ~= 0
    shiftPoint = clothoidPoints(1,1:2);
    shiftTheta = thetas(1);
    clothoidPoints(:,1:2) = clothoidPoints(:,1:2) - shiftPoint;
    R = [cos(shiftTheta) sin(shiftTheta); -sin(shiftTheta) cos(shiftTheta)];
    for i=1:N
        clothoidPoints(i,1:2) = clothoidPoints(i,1:2)*R;
        thetas(i) = thetas(i) - shiftTheta;
    end
    shifted = 1;
else
    shifted = 0;
end

%% Adjust points for a decreasing curvature
% have to flip over the x axis, shift back to 0 using the last point, and
% rotate 90 degrees clockwise
if abs(startCurvature) > abs(endCurvature)
    % used for a turn correction
    flipped = 1;
    
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    
    clothoidPoints(:,2) = -clothoidPoints(:,2);
    clothoidPoints(:,1:2) = [(clothoidPoints(:,1)-clothoidPoints(N,1)) (clothoidPoints(:,2)-clothoidPoints(N,2))];
    for i=1:N
        clothoidPoints(i,1:2) = [clothoidPoints(i,1) clothoidPoints(i,2)]*R;
    end
    % flip all the coordinates, since they are all now reversed
    clothoidPoints = flipud(clothoidPoints);
    
else
    flipped = 0;
end

%% If shifted, update theta
disp("THETAS");
disp(thetas);
disp("THETA: " + theta);
if shifted
    theta = theta - thetas(N);
    disp("SHIFT THETA: " + shiftTheta); 
end
disp("THETA: " + theta);
%% adjust points for negative direction, flip over y axis
if startCurvature < 0 || endCurvature < 0
    theta = -1 * theta;
    if shifted, thetas(:) = -thetas(:) + pi/2; end
    clothoidPoints(:,1) = -clothoidPoints(:,1);
end

%% Set up Forward and Reverse paths

% if flipped, update angles
if flipped
    flpThetas = zeros(1,N);
    startFacing = pi - thetas(N);
    for i=1:N
        flpThetas(i) = startFacing + thetas(1,N) - thetas(1,N-i+1);
    end
    thetas = flpThetas;
end

for i=1:N
    if bidirectional
        for j=1:lanes
            lanePoint = clothoidPoints(i,:) + ...
                [cos(flipped*pi-thetas(i))*(LANE_WIDTH * (1/2 + midTurnLane/2 + (j-1))) ...
                sin(flipped*pi-thetas(i))*(LANE_WIDTH * (1/2 + midTurnLane/2 + (j-1))) ...
                0];
            forwardPaths(j,3*i-2:3*i) = lanePoint;

            lanePoint = clothoidPoints(i,:) + ...
                [cos(pi-thetas(i))*(LANE_WIDTH * (1/2 + midTurnLane/2 + (j-1))) ...
                sin(pi-thetas(i))*(LANE_WIDTH * (1/2 + midTurnLane/2 + (j-1))) ...
                0];
            reversePaths(j,3*(N-i)+1:3*(N-i+1)) = lanePoint;
        end
    else
        for j=1:lanes
            lanePoint = clothoidPoints(i,:) + ...
                [cos(-thetas(i))*(LANE_WIDTH * (1/2 + (j-1) - lanes/2)) ...
                sin(-thetas(i))*(LANE_WIDTH * (1/2 + (j-1) - lanes/2)) ...
                0];
            forwardPaths(j,3*i-2:3*i) = lanePoint;
        end
    end
end

%% Rotate points to facing and adjust to inPoint
% Rotate path points and road points to orient to facing
% Add inPoint to place it in the correct location

rTheta = facing - pi/2;

R = [cos(rTheta) sin(rTheta); -sin(rTheta) cos(rTheta)];

for i=1:N
	clothoidPoints(i,:) = [clothoidPoints(i,1:2)*R clothoidPoints(i,3)] + inPoint;
end

for i=1:lanes
    for n=1:3:3*N
        forwardPaths(i,n:n+2) = [forwardPaths(i,n:n+1)*R forwardPaths(i,n+2)] + inPoint;
        if bidirectional
            reversePaths(i,n:n+2) = [reversePaths(i,n:n+1)*R reversePaths(i,n+2)] + inPoint;
        end
    end
end

%% update values

if shifted && flipped
    disp("SHIFTED & FLIPPED");
elseif shifted
    disp("SHIFTED");
else
    disp("FLIPPED");
end
% update inPoint
inPoint = clothoidPoints(N,:);

% update facing
facing = mod(facing - theta, 2*pi);

%update road points with new curve points
roadPoints = [roadPoints; clothoidPoints];

end

