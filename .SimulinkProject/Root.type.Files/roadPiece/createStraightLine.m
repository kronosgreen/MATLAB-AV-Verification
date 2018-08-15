function [roadPoints, forwardPaths, reversePaths, inPoint, facing] = createStraightLine(roadPoints, inPoint, facing, length, roadStruct)
%CREATESTRAIGHTLINE Creates a road as a straight line, used for cases with
%curvature of 0

disp("LINE");

% get global lane width
global LANE_WIDTH;

% Get variables
lanes = roadStruct(3);
bidirectional = roadStruct(4);
midTurnLane = roadStruct(5);

% set dirVec
dirVec = [cos(facing) sin(facing) 0];

% set end point of road piece
newPoints = [inPoint + 0.25 * length * dirVec; inPoint + 0.5 * length * dirVec; inPoint + 0.75 * length * dirVec; inPoint + length * dirVec];

roadPoints = [roadPoints; inPoint; newPoints];

forwardPaths = zeros(lanes, 15);

% Creates paths as vectors that correspond to the lanes on the road
if bidirectional
    reversePaths = zeros(lanes, 15);
    for i=1:lanes
        startPoint = inPoint + (LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) * [cos(facing-pi/2) sin(facing-pi/2) 0];
        forwardPaths(i,:) = [startPoint + dirVec * 0.05, startPoint + 0.25 * length * dirVec, startPoint + 0.5 * length * dirVec, startPoint + 0.75 * length * dirVec, startPoint + 0.95 * length * dirVec];

        startPoint = inPoint + (LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) * [cos(facing+pi/2) sin(facing+pi/2) 0];
        reversePaths(i,:) = [startPoint + 0.95 * length * dirVec, startPoint + 0.75 * length * dirVec, startPoint + 0.5 * length * dirVec, startPoint + 0.25 * length * dirVec, startPoint + dirVec * 0.05];
    end
else
    reversePaths = 0;
    for i=1:lanes
        startPoint = inPoint + (LANE_WIDTH * (1/2 + (i-1) - lanes/2)) * [cos(facing-pi/2) sin(facing-pi/2) 0];
        forwardPaths(i,:) = [startPoint + dirVec * 0.05, startPoint + 0.25 * length * dirVec, startPoint + 0.5 * length * dirVec, startPoint + 0.75 * length * dirVec, startPoint + 0.95 * length * dirVec];
    end
end

inPoint = newPoints(4,:);

end
