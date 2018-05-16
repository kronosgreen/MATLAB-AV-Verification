function [ep, facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, ep, facing, pieces, lanes, egoLane, length, bidirectional, midTurnLane, speedLimit, roadSlickness, angle)
    
    %MULTILANEROAD 
    %   Set up road piece with n-lanes based on the lanes parameter. If
    %   bidirectional it will include lanes going the opposite direction
    %   If midTurnLane is true, it will include a turn lane between the two 
    %   directions as well
    disp("Starting Multi-Lane Road");
    
    % Set up direction the road starts off going in by taking the 
    % facing parameter in radians and creating a vector
    dirVec = [cos(facing) sin(facing) 0];
    
    
    % Set up the width of the road based on whether it is 
    % bidirectional and whether it has a turn lane, is passed 
    % into the AV Toolbox function "road" as the third parameter
    LANE_WIDTH = 3; 

    if bidirectional
        roadWidth = 2 * lanes * LANE_WIDTH;
        if midTurnLane
            roadWidth = roadWidth + LANE_WIDTH;
        end
    else 
        roadWidth = lanes * LANE_WIDTH;
    end

    
    % Transition the lane width from the previous piece to the current one
    % creating a new middle piece in the shape of a trapezoid.
    % Checks to see if this isn't the first piece placed w "curLanes ~= 0"
    if pieces(size(pieces, 1)).lanes ~= 0
        if roadWidth > pieces(size(pieces,1)).width
            [ep, inPoint, facing, pieces] = laneIncrease(drScn, inPoint, ep, facing, roadWidth, pieces, dirVec, lanes, egoLane, bidirectional, midTurnLane, speedLimit, roadSlickness);
        elseif roadWidth < pieces(size(pieces,1)).width
            [ep, inPoint, facing, pieces] = laneDecrease(drScn, inPoint, ep, facing, roadWidth, pieces, dirVec, lanes, egoLane, bidirectional, midTurnLane, speedLimit, roadSlickness);
        end
    end

    %secondPoint = (inPoint + length*dirVec/2) * rotz(angle/4);
    %thirdPoint = (inPoint + length*dirVec) * rotz(angle/2);
    newPoint = inPoint + length/2 * dirVec;
    
    %Add road piece to scene (straight for now) with 'roadWidth' width
    %road(drScn, [inPoint; secondPoint; thirdPoint], roadWidth);
    road(drScn, [inPoint; newPoint], roadWidth);
    
    
    % Creates paths as vectors that correspond to the lanes on the road
    rPaths = zeros(lanes, 24);
    
    if bidirectional
        for i=1:lanes
            startPoint = inPoint + [cos(facing-pi/2)*(LANE_WIDTH/2 + midTurnLane*LANE_WIDTH/2 + (i-1)*LANE_WIDTH) sin(facing-pi/2)*(LANE_WIDTH/2 + midTurnLane*LANE_WIDTH/2 + (i-1)*LANE_WIDTH) 0];
            newPath = [(dirVec*2 + startPoint), (dirVec*3 + startPoint), ((length/2-4)*dirVec + startPoint), ((length/2-3)*dirVec + startPoint)];
            rPaths(i,1:12) = newPath;
        end
    else
        for i=1:lanes
            startPoint = inPoint + [cos(facing-pi/2)*(LANE_WIDTH/2 + (i-1)*LANE_WIDTH - lanes*LANE_WIDTH/2) sin(facing-pi/2)*(LANE_WIDTH/2 + midTurnLane*LANE_WIDTH/2 + (i-1)*LANE_WIDTH) 0];
            newPath = [(dirVec*2 + startPoint), (dirVec*3 + startPoint), ((length/2-4)*dirVec + startPoint), ((length/2-3)*dirVec + startPoint)];
            rPaths(i,1:12) = newPath;
        end
    end
    
    % Repeats process but after turning the road by the angle parameter
    
    facing = mod((facing - degtorad(angle)), 2*pi);
    dirVec = [cos(facing) sin(facing) 0];
    endPoint = newPoint + length/2 * dirVec;
    road(drScn, [newPoint; endPoint], roadWidth);
    
    if bidirectional
        for i=1:lanes
            startPoint = newPoint + [cos(facing-pi/2)*(LANE_WIDTH/2 + midTurnLane*LANE_WIDTH/2 + (i-1)*LANE_WIDTH) sin(facing-pi/2)*(LANE_WIDTH/2 + midTurnLane*LANE_WIDTH/2 + (i-1)*LANE_WIDTH) 0];
            newPath = [(dirVec*2 + startPoint), (dirVec*3 + startPoint), ((length/2-4)*dirVec + startPoint), ((length/2-3)*dirVec + startPoint)];
            rPaths(i,13:24) = newPath;
        end
    else
        for i=1:lanes
            startPoint = newPoint + [cos(facing-pi/2)*(LANE_WIDTH/2 + (i-1)*LANE_WIDTH - lanes*LANE_WIDTH/2) sin(facing-pi/2)*(LANE_WIDTH/2 + midTurnLane*LANE_WIDTH/2 + (i-1)*LANE_WIDTH) 0];
            newPath = [(dirVec*2 + startPoint), (dirVec*3 + startPoint), ((length/2-4)*dirVec + startPoint), ((length/2-3)*dirVec + startPoint)];
            rPaths(i,13:24) = newPath;
        end
    end
    
    
    %set up egoPath point
    for i=1:8
        nextPoint = rPaths(egoLane,(3*i - 2):3*i);
        ep = vertcat(ep, nextPoint);
    end
    
    % Creates a rectangle around the area occupied by the road piece
    if facing >= 0 && facing < pi/2
        botLeftCorner = inPoint + [-cos(facing+pi/2)*roadWidth/2 -sin(facing-pi/2)*roadWidth/2 0];
        topRightCorner = inPoint + length*dirVec + [cos(facing-pi/2)*4 sin(facing+pi/2)*4 0];
    elseif facing >= pi/2 && facing < pi
        botLeftCorner = inPoint + [-cos(facing-pi/2)*roadWidth/2 -sin(facing+pi/2)*roadWidth/2 0];
        topRightCorner = inPoint + length*dirVec + [cos(facing+pi/2)*4 sin(facing-pi/2)*4 0];
    elseif facing >= pi && facing < 3*pi/2
        botLeftCorner = inPoint + length*dirVec + [-cos(facing-pi/2)*roadWidth/2 -sin(facing+pi/2)*roadWidth/2 0];
        topRightCorner = inPoint + [cos(facing+pi/2)*4 sin(facing-pi/2)*4 0];
    else
        botLeftCorner = inPoint + length*dirVec + [-cos(facing+pi/2)*roadWidth/2 -sin(facing-pi/2)*roadWidth/2 0];
        topRightCorner = inPoint + [cos(facing-pi/2)*4 sin(facing+pi/2)*4 0];
    end
    
    % Sets up parameters to pass into the road info array
    
    rPiece.type = 1;
    %rPiece.roadPoints = [inPoint; secondPoint; thirdPoint];
    rPiece.roadPoints = [inPoint; newPoint];
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.midTurnLane = midTurnLane;
    rPiece.bidirectional = bidirectional;
    rPiece.lanes = lanes;
    rPiece.drivingPaths = rPaths;
    rPiece.occupiedLanes = zeros(1,lanes);
    rPiece.occupiedLanes(egoLane) = 1;
    rPiece.width = roadWidth;
    rPiece.egoLane = egoLane;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = speedLimit;
    rPiece.slickness = roadSlickness;
    
    pieces = [pieces; rPiece];
    
    inPoint = endPoint;
    

end