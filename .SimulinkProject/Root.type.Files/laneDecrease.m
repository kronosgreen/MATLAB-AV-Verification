function [ep, inPoint, facing, pieces] = laneDecrease(drScn, inPoint, ep, facing, newWidth, pieces, dirVec, lanes, egoLane, bidirectional, midTurnLane, sLimit, rSlick);
%LANEDECREASE Summary of this function goes here
%   Detailed explanation goes here


    LANE_WIDTH = 3;

    oldPoint = inPoint;

    rWidth = pieces(length(pieces)).width;

    if facing >= 0 && facing < pi/2
        botLeftCorner = inPoint + [-cos(facing+pi/2)*rWidth/2 -sin(facing-pi/2)*rWidth/2 0];
        topRightCorner = inPoint + 10*dirVec + [cos(facing-pi/2)*rWidth/2 sin(facing+pi/2)*rWidth/2 0];
    elseif facing >= pi/2 && facing < pi
        botLeftCorner = inPoint + [-cos(facing-pi/2)*rWidth/2 -sin(facing+pi/2)*rWidth/2 0];
        topRightCorner = inPoint + 10*dirVec + [cos(facing+pi/2)*rWidth/2 sin(facing-pi/2)*rWidth/2 0];
    elseif facing >= pi && facing < 3*pi/2
        botLeftCorner = inPoint + 10*dirVec + [-cos(facing-pi/2)*rWidth/2 -sin(facing+pi/2)*rWidth/2 0];
        topRightCorner = inPoint + [cos(facing+pi/2)*rWidth/2 sin(facing-pi/2)*rWidth/2 0];
    else
        botLeftCorner = inPoint + 10*dirVec + [-cos(facing+pi/2)*rWidth/2 -sin(facing-pi/2)*rWidth/2 0];
        topRightCorner = inPoint + [cos(facing-pi/2)*rWidth/2 sin(facing+pi/2)*rWidth/2 0];
    end


    change = rWidth - newWidth;

    %amou
    numPieces = 8;

    for i = 1:numPieces
        rWidth = rWidth - change/numPieces;
        newPoint = oldPoint + 10*dirVec/numPieces;
        road(drScn, [oldPoint; newPoint], rWidth);
        oldPoint = newPoint;
    end

    inPoint = newPoint;

    rPiece.type = 0;
    rPiece.roadPoints = [inPoint; newPoint];
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.midTurnLane = midTurnLane;
    rPiece.bidirectional = bidirectional;
    rPiece.lanes = lanes;
    rPiece.forwardDrivingPaths = 0;
    rPiece.reverseDrivingPaths = 0;
    rPiece.occupiedLanes = [0];
    rPiece.width = rWidth;
    rPiece.egoLane = egoLane;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = sLimit;
    rPiece.slickness = rSlick;

    pieces = [pieces; rPiece];

end

