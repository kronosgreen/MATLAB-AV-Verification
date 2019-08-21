function [facing, inPoint, pieces] = sideLotEnter(drScn, inPoint, facing, pieces, roadStruct)
%SIDELOTENTER Create road piece side lot enter, based on Taltech path
%   Detailed explanation goes here
    disp("Starting Side-Lot Enter");
    
    % set up variables from struct
    length = str2double(roadStruct(2));
    lanes = str2double(roadStruct(3));
    bidirectional = str2double(roadStruct(4));
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
    roadWidth = 2 * lanes * LANE_WIDTH;
    
    inPoint = inPoint + (TRANSITION_PIECE_LENGTH * dirVec);
    
    mainRoad = ["5" length lanes "1" "2" speedLimit "0000" "0" "0" pedPathWays outlets showMarkers];
    sidelot = ["5" length/3 1 "1" "0" speedLimit "0000" "0" "0" "000" "000" "0"];
    
    midPoint = inPoint + (length/2 + 20) * dirVec;
    midPoint = midPoint + (roadWidth/2 + 1) * [cos(facing-pi/2) sin(facing-pi/2) 0];
    if bidirectional, sidelotFacing = facing + pi/2; else, sidelotFacing = facing - pi/2; end
    
    corners = [midPoint; inPoint; inPoint + length*dirVec];
    
    botLeftCorner = [min(corners(:,1).') min(corners(:,2).') 0];
    topRightCorner = [max(corners(:,1).') max(corners(:,2).') 0];

    if ~checkAvailability(pieces, botLeftCorner, topRightCorner, [inPoint; inPoint + length*dirVec], facing, length)
        disp("@ Four-Way Intersection : Could Not Place Piece");
        inPoint = oldInPoint;
        return
    end
    
    [facing, inPoint, piece1] = multiLaneRoad(drScn, inPoint, facing, [], mainRoad);
    [xfacing, xinPoint, piece2] = multiLaneRoad(drScn, midPoint, sidelotFacing, [], sidelot);
    
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
    rPiece.bidirectional = 1;
    rPiece.lanes = lanes;
    rPiece.forwardDrivingPaths = piece1.forwardDrivingPaths;
    rPiece.reverseDrivingPaths = piece1.reverseDrivingPaths;
    rPiece.occupiedLanes = zeros(1,2*lanes);
    rPiece.width = roadWidth;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = speedLimit;
    rPiece.pedPathWays = pedPathWays;
    rPiece.showMarkers = showMarkers;
    
    pieces = [pieces; piece1];
end