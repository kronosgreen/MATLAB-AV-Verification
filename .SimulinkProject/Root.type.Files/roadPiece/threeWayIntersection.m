function [facing, inPoint, pieces] = threeWayIntersection(drScn, inPoint, facing, pieces, roadStruct)
%THREEWAYINTERSECTION Summary of this function goes here
%   Detailed explanation goes here

    disp("Starting 3-Way Intersection");
    
    % set up variables from struct
    length = str2double(roadStruct(2));
    lanes = char(roadStruct(3));
    bidirectional = char(roadStruct(4));
    midLane = str2double(roadStruct(5));
    speedLimit = roadStruct(6);
    pedPathWays = roadStruct(10);
    outlets = roadStruct(11);
    showMarkers = str2double(roadStruct(12));
    % Get Global Variables
    global LANE_WIDTH;
    global TRANSITION_PIECE_LENGTH;
    global fid; % test file
    
    oldInPoint = inPoint;
    
    dirVec = [cos(facing) sin(facing) 0];
    
    roadWidth = str2double(lanes(1)) * LANE_WIDTH;
    if str2double(bidirectional(1))
        roadWidth = 2 * roadWidth;
    end
    
    inPoint = inPoint + (TRANSITION_PIECE_LENGTH * dirVec);
    
    mainRoad = ["3" length lanes(1) bidirectional(1) midLane speedLimit "0000" "0" "0" pedPathWays outlets showMarkers];
    outRoad = ["3" length/2 lanes(2) bidirectional(2) midLane speedLimit "0000" "0" "0" pedPathWays outlets showMarkers];
    
    % Calculate midpoint to place outgoing road
    midPoint = inPoint + length*dirVec/2;
    % shift forward if median included
    if midLane > 1, midPoint = midPoint + 20*dirVec; end
    % move to end of side 
    %midPoint = midPoint + (roadWidth/2 + 0.1) * [cos(facing-pi/2) sin(facing-pi/2) 0];
    % third lane value will point the extra road left if true, right if false
    if str2double(lanes(3)), outFacing = facing + pi/2; else, outFacing = facing - pi/2; end
    
    corners = [midPoint; inPoint; inPoint + length*dirVec];
    
    botLeftCorner = [min(corners(:,1).') min(corners(:,2).') 0];
    topRightCorner = [max(corners(:,1).') max(corners(:,2).') 0];

    if ~checkAvailability(pieces, botLeftCorner, topRightCorner, [inPoint; inPoint + length*dirVec], facing, length)
        disp("@ Four-Way Intersection : Could Not Place Piece");
        inPoint = oldInPoint;
        return
    end
    
    [facing, inPoint, piece1] = multiLaneRoad(drScn, inPoint, facing, [], mainRoad);
    [xfacing, xinPoint, piece2] = multiLaneRoad(drScn, midPoint, outFacing, [], outRoad);
    
    % Transition the lane width from the previous piece to the current one
    % creating a new middle piece in the shape of a trapezoid.
    % Checks to see if this isn't the first piece placed
    if size(pieces,1) >= 2
        mainRoad(5) = "0";
        [xinPoint, xfacing, pieces] = laneSizeChange(drScn, oldInPoint, facing, ...
            roadWidth, pieces, dirVec, mainRoad);
    end
    
    rPiece.type = 5;
    rPiece.lineType = 0;
    rPiece.roadPoints = [inPoint; inPoint+length*dirVec];
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.length = length;
    rPiece.curvature1 = 0;
    rPiece.curvature2 = 0;
    rPiece.midLane = 0;
    rPiece.bidirectional = str2double(bidirectional(1));
    rPiece.lanes = lanes;
    rPiece.forwardDrivingPaths = piece1.forwardDrivingPaths;
    rPiece.reverseDrivingPaths = piece1.reverseDrivingPaths;
    rPiece.occupiedLanes = zeros(1,2*str2double(lanes(1)));
    rPiece.width = roadWidth;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = speedLimit;
    rPiece.pedPathWays = pedPathWays;
    rPiece.showMarkers = showMarkers;
    
    pieces = [pieces; piece1];

end

