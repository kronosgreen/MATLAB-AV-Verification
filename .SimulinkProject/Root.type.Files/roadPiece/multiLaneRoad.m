  function [facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, facing, pieces, roadStruct)
    
    %MULTILANEROAD 
    %   Set up road piece with n-lanes based on the lanes parameter. If
    %   bidirectional it will include lanes going the opposite direction
    %   If midTurnLane is true, it will include a turn lane between the two 
    %   directions as well
    disp("Starting Multi-Lane Road");
    
    % set up variables from struct
    length = roadStruct(2);
    lanes = roadStruct(3);
    bidirectional = roadStruct(4);
    midTurnLane = roadStruct(5);
    speedLimit = roadStruct(6);
    curvature1 = roadStruct(8);
    curvature2 = roadStruct(9);
    
    % Set up direction the road starts off going in by taking the 
    % facing parameter in radians and creating a vector
    dirVec = [cos(facing) sin(facing) 0];
    
    % get original parameters stored
    oldFacing = facing;
    oldInPoint = inPoint;
    
    % Get lane width
    global LANE_WIDTH;
    
    % Also set up lane markings & specifications
    % Start off left side of the road with a solid white line
    lm = laneMarking('Solid','Color','w');
    
    % Place lane markings for left side of road if bidirectional, whole
    % road if not
    for i=1:lanes-1
        lm = vertcat(lm, laneMarking('Dashed', 'Color', 'w'));
    end
    
    if bidirectional
        roadWidth = 2 * lanes * LANE_WIDTH;
        if midTurnLane
            roadWidth = roadWidth + LANE_WIDTH;
            % Surround mid-turn lane with dashed-solid lines
            lm = vertcat(lm, [laneMarking('SolidDashed', 'Color', 'y');...
                laneMarking('DashedSolid', 'Color', 'y')]);
        else
            if bidirectional == 1
                % Split road with double solid yellow
                lm = vertcat(lm, laneMarking('DoubleSolid', 'Color', 'y'));
            elseif bidirectional == 2
                % Split road with dashed yellow line
                lm = vertcat(lm, laneMarking('Dashed', 'Color', 'y'));
            end
        end
        
        % Finish off lanes on right side
        for i=1:lanes-1
            lm = vertcat(lm, laneMarking('Dashed', 'Color', 'w'));
        end
    else 
        roadWidth = lanes * LANE_WIDTH;
    end
    
    % end road with a solid white line
    lm = vertcat(lm, laneMarking('Solid', 'Color', 'w'));
    
    % Define lane specifications to be separated by LANE_WIDTH
    ls = lanespec(roadWidth/LANE_WIDTH, 'Width', LANE_WIDTH, 'Marking', lm);
    
    % Transition the lane width from the previous piece to the current one
    % creating a new middle piece in the shape of a trapezoid.
    % Checks to see if this isn't the first piece placed
    if pieces(size(pieces, 1)).lanes ~= 0
        [inPoint, facing, pieces] = laneSizeChange(drScn, inPoint, facing, ...
            roadWidth, pieces, dirVec, roadStruct);
    end
    
    % Set up matrix to store corner points
    corners = zeros(4,3);
    
    % determine the line type
    if curvature1 == 0 && curvature2 == 0
        lineType = 0;
    elseif curvature1 == 0 
        lineType = 1;
        curv = curvature1;
    elseif curvature2 == 0
        lineType = 1;
        curv = curvature2;
    % determining whether the road is clothoid-arc-clothoid or the reverse
    % of that is currently done arbitrarily; most likely will add parameter
    % later
    else
        lineType = 1 + randi(2);
    end
    
    % set up empty matrix for road points
    roadPoints = [];
    
    % Create Curved Multilane Road
    switch lineType
        case 0
            disp("Straight Line");
            [roadPoints, forwardPaths, reversePaths, inPoint, facing] = ...
                createStraightLine(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane);
        case 1
            disp("Line - Clothoid - Arc");
            [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = ...
                createStraightLine(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane);
            [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane, 0, curv);
            [roadPoints, fwPaths3, rvPaths3, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length, curv, lanes, bidirectional, midTurnLane);
            forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2(:,1:size(fwPaths2,2)-3) fwPaths3];
            reversePaths = [rvPaths3(:,1:size(rvPaths3,2)-3) rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
        case 2
            disp("Clothoid - Arc - Clothoid");
            [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane, 0, curvature1);
            [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length, curvature1, lanes, bidirectional, midTurnLane);
            [roadPoints, fwPaths3, rvPaths3, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length, lanes, bidirectional, midTurnLane, curvature1, curvature2);
            forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2(:,1:size(fwPaths2,2)-3) fwPaths3];
            reversePaths = [rvPaths3(:,1:size(rvPaths3,2)-3) rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
        case 3
            disp("Arc - Clothoid - Arc");
            [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length, curvature1, lanes, bidirectional, midTurnLane);
            [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = ...
                createClothoid(roadPoints(1:size(roadPoints,1)-1,:), inPoint, facing, length, lanes, bidirectional, midTurnLane, curvature1, curvature2);
            [roadPoints, fwPaths3, rvPaths3, inPoint, facing] = ...
                createArc(roadPoints(1:size(roadPoints,1)-1,:), inPoint, facing, length, curvature2, lanes, bidirectional, midTurnLane);
            forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2(:,1:size(fwPaths2,2)-3) fwPaths3];
            reversePaths = [rvPaths3(:,1:size(rvPaths3,2)-3) rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
    end
   
    % get original & new direction vector
    oldDirVec = [cos(oldFacing) sin(oldFacing) 0] * 2;
    newDirVec = [cos(facing) sin(facing) 0] * 2;
    
    % shift lane paths by oldDirVec
    for i=1:lanes
        for j=1:3:size(forwardPaths,2)
            forwardPaths(i,j:j+2) = forwardPaths(i,j:j+2) + oldDirVec;
        end
        if bidirectional
            for j=1:3:size(reversePaths,2)
                reversePaths(i,j:j+2) = reversePaths(i,j:j+2) + oldDirVec;
            end
        end
    end
    
    % set up road points with extra points at beginning and end to
    % ensure direction is maintained at each
    endPoint =  inPoint + oldDirVec + newDirVec;
    roadPoints = [oldInPoint; roadPoints + oldDirVec; endPoint];
    
    % Set up corners to make boundaries
    corners(1,:) = oldInPoint + roadWidth/2*[cos(oldFacing+pi/2) sin(oldFacing+pi/2) 0];
    corners(2,:) = oldInPoint - roadWidth/2*[cos(oldFacing+pi/2) sin(oldFacing+pi/2) 0];
    corners(3,:) = endPoint + roadWidth/2*[cos(facing+pi/2) sin(facing+pi/2) 0];
    corners(4,:) = endPoint - roadWidth/2*[cos(facing+pi/2) sin(facing+pi/2) 0];
        
    % Update inPoint
    inPoint = endPoint;

    % Creates a rectangle around the area occupied by the road piece
    botLeftCorner = [min([corners(1,1) corners(2,1) corners(3,1) corners(4,1)])...
        min([corners(1,2) corners(2,2) corners(3,2) corners(4,2)])...
        0];
    topRightCorner = [max([corners(1,1) corners(2,1) corners(3,1) corners(4,1)])...
        max([corners(1,2) corners(2,2) corners(3,2) corners(4,2)])...
        0];
    
    % If conflicts with any other piece, will stop placing
    if ~checkAvailability(pieces, botLeftCorner, topRightCorner, [oldInPoint(1:2);inPoint(1:2)], facing, length)
        disp("@ Multi Lane Road : Could Not Place Piece");
        % return to original variables
        pieces = pieces(1:size(pieces,1)-1);
        inPoint = roadPoints(1,:);
        facing = oldFacing;
        return
    end
    hold on;
    plot(roadPoints(:,1),roadPoints(:,2));
    plot(forwardPaths(1,1:3:size(forwardPaths, 2)),forwardPaths(1,2:3:size(forwardPaths,2)));
    if bidirectional, plot(reversePaths(1,1:3:size(forwardPaths, 2)),reversePaths(1,2:3:size(forwardPaths,2))); end
    % Create Road Piece in Scenario
    road(drScn, roadPoints, 'Lanes', ls);
    
    % Sets up parameters to pass into the road info array
    
    rPiece.type = 1;
    rPiece.lineType = lineType;
    rPiece.roadPoints = roadPoints;
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.length = length;
    rPiece.curvature1 = curvature1;
    rPiece.curvature2 = curvature2;
    rPiece.midTurnLane = midTurnLane;
    rPiece.bidirectional = bidirectional;
    rPiece.lanes = lanes;
    rPiece.forwardDrivingPaths = forwardPaths;
    rPiece.reverseDrivingPaths = reversePaths;
    rPiece.occupiedLanes = zeros(1,lanes + bidirectional*lanes);
    rPiece.width = roadWidth;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = speedLimit;
    
    pieces = [pieces; rPiece];

end