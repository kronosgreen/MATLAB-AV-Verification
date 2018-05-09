function [ep, inPoint, facing, pieces] = laneIncrease(drScn, inPoint, ep, facing, newWidth, pieces, dirVec, lanes, egoLane, bidirectional, midTurnLane, sLimit, rSlick)
    %LANEINCREASE Summary of this function goes here
    %   Creates the transition piece between a road piece and one of greater
    %   width


    if facing >= 0 && facing < pi/2
        botLeftCorner = inPoint + [-cos(facing+pi/2)*newWidth/2 -sin(facing-pi/2)*newWidth/2 0];
        topRightCorner = inPoint + 10*dirVec + [cos(facing-pi/2)*newWidth/2 sin(facing+pi/2)*newWidth/2 0];
    elseif facing >= pi/2 && facing < pi
        botLeftCorner = inPoint + [-cos(facing-pi/2)*newWidth/2 -sin(facing+pi/2)*newWidth/2 0];
        topRightCorner = inPoint + 10*dirVec + [cos(facing+pi/2)*newWidth/2 sin(facing-pi/2)*newWidth/2 0];
    elseif facing >= pi && facing < 3*pi/2
        botLeftCorner = inPoint + 10*dirVec + [-cos(facing-pi/2)*newWidth/2 -sin(facing+pi/2)*newWidth/2 0];
        topRightCorner = inPoint + [cos(facing+pi/2)*newWidth/2 sin(facing-pi/2)*newWidth/2 0];
    else
        botLeftCorner = inPoint + 10*dirVec + [-cos(facing+pi/2)*newWidth/2 -sin(facing-pi/2)*newWidth/2 0];
        topRightCorner = inPoint + [cos(facing-pi/2)*newWidth/2 sin(facing+pi/2)*newWidth/2 0];
    end
    
    oldPoint = inPoint;

    rWidth = pieces(length(pieces)).width;

    change = newWidth - rWidth;

    %how broken down will the 
    numPieces = 8;

    for i = 1:numPieces
        rWidth = rWidth + change/numPieces;
        newPoint = oldPoint + 10*dirVec/numPieces;
        road(drScn, [oldPoint; newPoint], rWidth);
        oldPoint = newPoint;
    end

    
    rPiece.type = 0;
    rPiece.roadPoints = [inPoint; newPoint];
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.midTurnLane = midTurnLane;
    rPiece.bidirectional = bidirectional;
    rPiece.lanes = lanes;
    rPiece.drivingPaths = [0];
    rPiece.occupiedLanes = [0];
    rPiece.width = rWidth;
    rPiece.egoLane = egoLane;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = sLimit;
    rPiece.slickness = rSlick;

    inPoint = newPoint;
    
    pieces = [pieces; rPiece];

end

