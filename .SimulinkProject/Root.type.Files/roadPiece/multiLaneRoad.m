  function [facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, facing, pieces, roadStruct)
    
    %MULTILANEROAD 
    %   Set up road piece with n-lanes based on the lanes parameter. If
    %   bidirectional it will include lanes going the opposite direction
    %   If midLane is true, it will include a turn lane between the two 
    %   directions as well
    disp("Starting Multi-Lane Road");
    
    % set up variables from struct
    roadType = str2double(roadStruct(1));
    length = str2double(roadStruct(2));
    lanes = str2double(roadStruct(3));
    bidirectional = str2double(roadStruct(4));
    midLane = str2double(roadStruct(5));
    speedLimit = str2double(roadStruct(6));
    curvature1 = str2double(roadStruct(8));
    curvature2 = str2double(roadStruct(9));
    pedPathWays = split(roadStruct(10), ':');
    outlets = split(roadStruct(11), ':');
    showMarkers = str2double(roadStruct(12));
    
    % Set up direction the road starts off going in by taking the 
    % facing parameter in radians and creating a vector
    dirVec = [cos(facing) sin(facing) 0];
    
    % Get Global Variables
    global LANE_WIDTH;
    oldLW = LANE_WIDTH;
    global TRANSITION_PIECE_LENGTH;
    global fid; % test file
    
    % get original parameters stored
    oldFacing = facing;
    oldInPoint = inPoint;
    
    % Set up new inpoint to be where the transition piece would put it
    if roadType == 1, inPoint = inPoint + (TRANSITION_PIECE_LENGTH * [cos(facing) sin(facing) 0]); end
    
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
        switch midLane
            case 0
                % Nothing
                if bidirectional == 1
                    % Split road with double solid yellow
                    lm = vertcat(lm, laneMarking('DoubleSolid', 'Color', 'y'));
                elseif bidirectional == 2
                	% Split road with dashed yellow line
                    lm = vertcat(lm, laneMarking('Dashed', 'Color', 'y'));
                end
                
                for i=1:lanes-1
                    lm = vertcat(lm, laneMarking('Dashed', 'Color', 'w'));
                end
                
                % end road with a solid white line
                lm = vertcat(lm, laneMarking('Solid', 'Color', 'w'));

                % Define lane specifications to be separated by LANE_WIDTH
                ls = lanespec(lanes*2, 'Width', LANE_WIDTH, 'Marking', lm);
                
                % Set up Params for Geometry Construction
                ln = lanes;
                
            case 1
                % Mid-Turn Lane
                roadWidth = roadWidth + LANE_WIDTH;
                % Surround mid-turn lane with dashed-solid lines
                lm = vertcat(lm, [laneMarking('SolidDashed', 'Color', 'y');...
                    laneMarking('DashedSolid', 'Color', 'y')]);
                
                for i=1:lanes-1
                    lm = vertcat(lm, laneMarking('Dashed', 'Color', 'w'));
                end
                
                % end road with a solid white line
                lm = vertcat(lm, laneMarking('Solid', 'Color', 'w'));

                % Define lane specifications to be separated by LANE_WIDTH
                ls = lanespec(lanes*2+1, 'Width', LANE_WIDTH, 'Marking', lm);
                
                % Set up Params for Geometry Construction
                ln = lanes;
                
            case 2
                % Small Median
                % Median of size 1m, splitting the road at 10 degrees
                % x|_\y   x = 1/(2*tan(0.17rad)) = 2.84m
                %  .5*1m
                
                % Build Right Start
                rightStart = [inPoint; ...
                    (inPoint + 2*dirVec); ...
                    (inPoint + 8*dirVec); ...
                    (inPoint + 10*dirVec)];
                % Shift all points right by 1/2 Width
                rightStart = rightStart + 0.5*lanes*LANE_WIDTH*[cos(facing-pi/2) sin(facing-pi/2) 0];
                % Shift top two points by 1/2 median width
                rightStart(3:4,:) = rightStart(3:4,:) + 0.5*[cos(facing-pi/2) sin(facing-pi/2) 0];
                
                % Build Left Start
                leftStart = [inPoint; ...
                    (inPoint + 2*dirVec); ...
                    (inPoint + 8*dirVec); ...
                    (inPoint + 10*dirVec)];
                % Shift all points right by 1/2 Width
                leftStart = leftStart + 0.5*lanes*LANE_WIDTH*[cos(facing+pi/2) sin(facing+pi/2) 0];
                % Shift top two points by 1/2 median width
                leftStart(3:4,:) = leftStart(3:4,:) + 0.5*[cos(facing+pi/2) sin(facing+pi/2) 0];
                
                lm = [lm; laneMarking('Solid', 'Color', 'y')];
                lm(1) = laneMarking('Solid','Color','y');

                % Define lane specifications to be separated by LANE_WIDTH
                ls = lanespec(lanes, 'Width', LANE_WIDTH, 'Marking', lm);
                
                % Set up Params for Geometry Construction
                ln = oldLW * lanes - 1;
                LANE_WIDTH = 1;
                inPoint = inPoint + 20*dirVec;
                
            case 3
                % Large Median
                % Median of size 2m, splitting the road at 10 degrees
                % x|_\y   x = 1/(2*tan(0.17rad)) = 5.67m
                %  .5*2m
                
                % Build Right Start
                rightStart = [inPoint; ...
                    (inPoint + 4*dirVec); ...
                    (inPoint + 16*dirVec); ...
                    (inPoint + 20*dirVec)];
                % Shift all points right by 1/2 Road Width
                rightStart = rightStart + 0.5*lanes*LANE_WIDTH*[cos(facing-pi/2) sin(facing-pi/2) 0];
                % Shift top two points by 1/2 median width
                rightStart(3:4,:) = rightStart(3:4,:) + [cos(facing-pi/2) sin(facing-pi/2) 0];
                
                % Build Left Start
                leftStart = [inPoint; ...
                    (inPoint + 4*dirVec); ...
                    (inPoint + 16*dirVec); ...
                    (inPoint + 20*dirVec)];
                % Shift all points right by 1/2 road Width
                leftStart = leftStart + 0.5*lanes*LANE_WIDTH*[cos(facing+pi/2) sin(facing+pi/2) 0];
                % Shift top two points by 1/2 median width
                leftStart(3:4,:) = leftStart(3:4,:) + [cos(facing+pi/2) sin(facing+pi/2) 0];
                
                inPoint = leftStart(4,:);
                
                lm = [lm; laneMarking('Solid', 'Color', 'y')];
                lm(1) = laneMarking('Solid','Color','y');
                
                % Define lane specifications to be separated by LANE_WIDTH
                ls = lanespec(lanes, 'Width', LANE_WIDTH, 'Marking', lm);
                
                % Set up Params for Geometry Construction
                ln = oldLW * lanes - 1;
                LANE_WIDTH = 1;
                inPoint = inPoint + 20*dirVec;
                
        end

    else 
        % One Way Road
        
        roadWidth = lanes * LANE_WIDTH;
    
        % end road with a solid white line
        lm = vertcat(lm, laneMarking('Solid', 'Color', 'w'));

        % Define lane specifications to be separated by LANE_WIDTH
        ls = lanespec(lanes, 'Width', LANE_WIDTH, 'Marking', lm);
        
        % Set up parameters for geometry construction
        ln = lanes;
        
    end
    
    % Set up matrix to store corner points
    corners = zeros(4,3);
    
    %disp("CURVATURES: " + curvature1 + "," + curvature2);
    % determine the line type
    if curvature1 == 0 && curvature2 == 0
        lineType = 0;
    elseif curvature1 == 0 
        lineType = 1;
        curv = curvature2;
    elseif curvature2 == 0
        lineType = 1;
        curv = curvature1;
    % determining whether the road is clothoid-arc-clothoid or the reverse
    % of that is currently done arbitrarily; most likely will add parameter
    % later
    else
        lineType = 1 + randi(2);
    end
    
    % set up empty matrix for road points
    roadPoints = [];
    
    % Construct Multilane Road
    
    % Select Geometry
    switch lineType
        case 0
            disp("Straight Line");
            [roadPoints, forwardPaths, reversePaths, inPoint, facing] = ...
                createStraightLine(roadPoints, inPoint, facing, length, ln, bidirectional, midLane);
        case 1
            disp("Line - Clothoid - Arc");
            [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = ...
                createStraightLine(roadPoints, inPoint, facing, length/3, ln, bidirectional, midLane);
            [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length/3, ln, bidirectional, midLane, 0, curv);
            [roadPoints, fwPaths3, rvPaths3, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length/3, curv, ln, bidirectional, midLane);
            forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2(:,1:size(fwPaths2,2)-3) fwPaths3];
            reversePaths = [rvPaths3(:,1:size(rvPaths3,2)-3) rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
        case 2
            disp("Clothoid - Arc - Clothoid");
            [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length/3, ln, bidirectional, midLane, 0, curvature1);
            [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length/3, curvature1, ln, bidirectional, midLane);
            [roadPoints, fwPaths3, rvPaths3, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length/3, ln, bidirectional, midLane, curvature1, curvature2);
            forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2(:,1:size(fwPaths2,2)-3) fwPaths3];
            reversePaths = [rvPaths3(:,1:size(rvPaths3,2)-3) rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
        case 3
            disp("Arc - Clothoid - Arc");
            [roadPoints, fwPaths1, rvPaths1, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length/3, curvature1, ln, bidirectional, midLane);
            [roadPoints, fwPaths2, rvPaths2, inPoint, facing] = ...
                createClothoid(roadPoints, inPoint, facing, length/3, ln, bidirectional, midLane, curvature1, curvature2);
            [roadPoints, fwPaths3, rvPaths3, inPoint, facing] = ...
                createArc(roadPoints, inPoint, facing, length/3, curvature2, ln, bidirectional, midLane);
            forwardPaths = [fwPaths1(:,1:size(fwPaths1,2)-3) fwPaths2(:,1:size(fwPaths2,2)-3) fwPaths3];
            reversePaths = [rvPaths3(:,1:size(rvPaths3,2)-3) rvPaths2(:,1:size(rvPaths2,2)-3) rvPaths1];
    end
   
    % Reset LANE_WIDTH
    LANE_WIDTH = oldLW;
    
    % get original & new direction vector
    oldDirVec = [cos(oldFacing) sin(oldFacing) 0] * 2;
    newDirVec = [cos(facing) sin(facing) 0] * 2;
    
    % shift lane paths by oldDirVec
    for j=1:3:size(forwardPaths,2)
        forwardPaths(1:lanes,j:j+2) = forwardPaths(1:lanes,j:j+2) + oldDirVec;
    end
    if bidirectional
        for j=1:3:size(reversePaths,2)
            reversePaths(1:lanes,j:j+2) = reversePaths(1:lanes,j:j+2) + oldDirVec;
        end
    end
    
    % set up road points with extra points at beginning and end to
    % ensure direction is maintained at each
    endPoint =  inPoint + oldDirVec + newDirVec;
    roadPoints = [roadPoints(1,:); roadPoints + oldDirVec; endPoint];
    
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
        inPoint = oldInPoint;
        facing = oldFacing;
         try
            fprintf(fid, "%d,", roadType);
        catch
            disp("Error printing");
            fid = fopen("placedRoadNet.txt","a");
            fprintf(fid, "%d,", roadType);
        end
        return
    end
    
    % Transition the lane width from the previous piece to the current one
    % creating a new middle piece in the shape of a trapezoid.
    % Checks to see if this isn't the first piece placed
    if size(pieces,1) >= 2
        [xinPoint, xfacing, pieces] = laneSizeChange(drScn, oldInPoint, oldFacing, ...
            roadWidth, pieces, dirVec, roadStruct);
    end
    
    % Create Road Piece in Scenario
    if midLane > 1 && bidirectional
        % Set up Small Median Roads
        roadIndex = ceil(lanes/2)*LANE_WIDTH-1;
        
        pLength = size(forwardPaths,2)/3;
        rightPoints = reshape(forwardPaths(roadIndex,:), [3,pLength]).';
        reStart = rightPoints(size(rightPoints,1),:);
        rightEnd = [reStart + 2 * newDirVec; ...
                    reStart + 8 * newDirVec; ...
                    reStart + 10 * newDirVec];
        
        pLength = size(reversePaths,2)/3;
        leftPoints = flipud(reshape(reversePaths(roadIndex,:), [3,pLength]).');
        leStart = leftPoints(size(leftPoints,1),:);
        leftEnd =  [leStart + 2 * newDirVec; ...
                    leStart + 8 * newDirVec; ...
                    leStart + 10 * newDirVec];
        
        if midLane == 2
            rightEnd(2:3,:) = rightEnd(2:3,:) + 0.5 * [cos(facing+pi/2) sin(facing+pi/2) 0];
            leftEnd(2:3,:) = leftEnd(2:3,:) + 0.5 * [cos(facing-pi/2) sin(facing-pi/2) 0];
            
            % set paths back to normal
            forwardPaths = forwardPaths(2:3:size(forwardPaths,1),:);
            reversePaths = reversePaths(2:3:size(reversePaths,1),:);
        elseif midLane == 3
            rightEnd(2:3,:) = rightEnd(2:3,:) + [cos(facing+pi/2) sin(facing+pi/2) 0];
            leftEnd(2:3,:) = leftEnd(2:3,:) + [cos(facing-pi/2) sin(facing-pi/2) 0];
            
            % set paths back to normal
            forwardPaths = forwardPaths(2:3:size(forwardPaths,1),:);
            reversePaths = reversePaths(2:3:size(reversePaths,1),:);
        end            
        
        rightPoints = [rightStart; rightPoints; rightEnd];
        leftPoints = [leftStart; leftPoints; leftEnd];
        
        hold on;
        plot(rightPoints(:,1),rightPoints(:,2));
        plot(leftPoints(:,1),leftPoints(:,2));
        
        road(drScn, leftPoints, 'Lanes', ls);
        road(drScn, rightPoints, 'Lanes', ls);
        
        
    else
        road(drScn, roadPoints, 'Lanes', ls);
        
        % Plot Paths 
        hold on;
        plot(roadPoints(:,1),roadPoints(:,2));
        plot(forwardPaths(1,1:3:size(forwardPaths, 2)),forwardPaths(1,2:3:size(forwardPaths,2)));
        if bidirectional, plot(reversePaths(1,1:3:size(forwardPaths, 2)),reversePaths(1,2:3:size(forwardPaths,2))); end
        if bidirectional && lanes > 1, plot(reversePaths(2,1:3:size(forwardPaths, 2)),reversePaths(2,2:3:size(forwardPaths,2))); end
        if lanes > 1, plot(forwardPaths(2,1:3:size(forwardPaths, 2)),forwardPaths(2,2:3:size(forwardPaths,2))); end
        
    end
    
    % Sets up parameters to pass into the road info array
    
    rPiece.type = 1;
    rPiece.lineType = lineType;
    rPiece.roadPoints = roadPoints;
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.length = length;
    rPiece.curvature1 = curvature1;
    rPiece.curvature2 = curvature2;
    rPiece.midLane = midLane;
    rPiece.bidirectional = bidirectional;
    rPiece.lanes = lanes;
    rPiece.forwardDrivingPaths = forwardPaths;
    rPiece.reverseDrivingPaths = reversePaths;
    rPiece.occupiedLanes = zeros(1,lanes + bidirectional*lanes);
    rPiece.width = roadWidth;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = speedLimit;
    rPiece.pedPathWays = pedPathWays;
    rPiece.showMarkers = showMarkers;
    
    pieces = [pieces; rPiece];

end