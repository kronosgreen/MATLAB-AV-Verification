function [roadPoints, forwardPaths, reversePaths, inPoint, facing] = createStraightLine(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane)
%CREATESTRAIGHTLINE Creates a road as a straight line, used for cases with
%curvature of 0

% get global lane width
global LANE_WIDTH;

% set dirVec
dirVec = [cos(facing) sin(facing) 0];

% set end point of road piece
newPoint = inPoint + length * dirVec;

roadPoints = [roadPoints; inPoint; newPoint];

forwardPaths = zeros(lanes, 6);

% Creates paths as vectors that correspond to the lanes on the road
if bidirectional
    reversePaths = zeros(lanes, 6);
    for i=1:lanes
        startPoint = inPoint + [cos(facing-pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(facing-pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        forwardPaths(i,:) = [startPoint, startPoint + length * dirVec];

        startPoint = inPoint + [cos(facing+pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(facing+pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        reversePaths(i,:) = [startPoint + length * dirVec, startPoint];
    end
else
    reversePaths = 0;
    for i=1:lanes
        startPoint = inPoint + [cos(facing-pi/2)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(facing-pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        forwardPaths(i,:) = [startPoint, startPoint + dirVec * length / 4, startPoint + dirVec * length / 2, startPoint + 3 * dirVec * length / 4, startPoint + length * dirVec];
    end
end

inPoint = newPoint;

end
