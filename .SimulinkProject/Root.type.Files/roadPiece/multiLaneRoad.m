  function [facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, facing, pieces, lanes, length, bidirectional, midTurnLane, speedLimit, roadSlickness, curvature1, curvature2)
    
    %MULTILANEROAD 
    %   Set up road piece with n-lanes based on the lanes parameter. If
    %   bidirectional it will include lanes going the opposite direction
    %   If midTurnLane is true, it will include a turn lane between the two 
    %   directions as well
    disp("Starting Multi-Lane Road");
    
    % Set up direction the road starts off going in by taking the 
    % facing parameter in radians and creating a vector
    dirVec = [cos(facing) sin(facing) 0];
    forwardVec = [0 1 0];
    oldFacing = facing;
    
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
        [inPoint, facing, pieces] = laneSizeChange(drScn, inPoint, facing, roadWidth, pieces, dirVec, lanes, bidirectional, midTurnLane, speedLimit, roadSlickness);
    end
    
    % Set up matrix to store corner points
    corners = zeros(4,3);
    
    
    if curvature1 ~= 0 || curvature2 ~= 0
        
        if curvature1 == 0 || curvature2 == 0
            lineType = 1
        
        
        % Create Curved Multilane Road
        
        
        
        % Set up first two corners
        corners(1,:) = inPoint + [cos(facing + pi/2) sin(facing + pi/2) 0];
        corners(2,:) = inPoint - [cos(facing + pi/2) sin(facing + pi/2) 0];

        % Adjust facing to new direction of road
        facing = mod(facing - theta, 2*pi);
        
        dirVec = [cos(facing) sin(facing) 0];

        % set up road points with extra points at beginning and end to
        % ensure direction is maintained at each
        roadPoints = [inPoint; curvePoints; curvePoints(4,:) + 2 * dirVec];
        
        % Set up last two corners
        corners(3,:) = roadPoints(6,:) + [cos(facing + pi/2) sin(facing + pi/2) 0];
        corners(4,:) = roadPoints(6,:) - [cos(facing + pi/2) sin(facing + pi/2) 0];
        
        % Update inPoint
        inPoint = roadPoints(6,:);
        
    else
        
        %
        % Creates Straight Road
        %
        
        newPoint = inPoint + length * dirVec;
        
        roadPoints = [inPoint; newPoint];
        
        forwardPaths = zeros(lanes, 6);
        
        % change in direction
        theta = 0;
    
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
        
        % Set up corners to make boundaries
        corners(1,:) = inPoint + roadWidth/2*[cos(facing+pi/2) sin(facing+pi/2) 0];
        corners(2,:) = inPoint - roadWidth/2*[cos(facing+pi/2) sin(facing+pi/2) 0];
        corners(3,:) = newPoint + roadWidth/2*[cos(facing+pi/2) sin(facing+pi/2) 0];
        corners(4,:) = newPoint - roadWidth/2*[cos(facing+pi/2) sin(facing+pi/2) 0];
        
        % Update inPoint
        inPoint = newPoint;
        
    end
    
    
    % Creates a rectangle around the area occupied by the road piece
    botLeftCorner = [min([corners(1,1) corners(2,1) corners(3,1) corners(4,1)]) min([corners(1,2) corners(2,2) corners(3,2) corners(4,2)]) 0];
    topRightCorner = [max([corners(1,1) corners(2,1) corners(3,1) corners(4,1)]) max([corners(1,2) corners(2,2) corners(3,2) corners(4,2)]) 0];
    
    % If conflicts with any other piece, will stop placing
    if ~checkAvailability(pieces, botLeftCorner, topRightCorner)
        % return original variables
        inPoint = roadPoints(1,:);
        facing = oldFacing;
        return
    end
    
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
    rPiece.slickness = roadSlickness;
    
    pieces = [pieces; rPiece];

end