function [ep, facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, ep, facing, pieces, lanes, egoLane, length, bidirectional, midTurnLane, speedLimit, roadSlickness, curvature)
    
    %MULTILANEROAD 
    %   Set up road piece with n-lanes based on the lanes parameter. If
    %   bidirectional it will include lanes going the opposite direction
    %   If midTurnLane is true, it will include a turn lane between the two 
    %   directions as well
    disp("Starting Multi-Lane Road");
    
    % Set up direction the road starts off going in by taking the 
    % facing parameter in radians and creating a vector
    dirVec = [cos(facing) sin(facing) 0];
    forwardVec = [cos(pi/2) sin(pi/2) 0];
    
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
    
    if curvature ~= 0
        
        % Create Curved Multilane Road
        
        % Create empty matrix for lane paths
        rPaths = zeros(lanes, 18);
        
        %
        % Set up Clothoid Curve based on given curvature
        %

        % First Point

        % End Curvature
        k_c = abs(curvature) / 3;

        % End circular arc (Radius) - 1 / curvature
        R_c = 1 / k_c;

        % Arc length or length of road
        s_c = length / 3;

        % a - scaling ratio to improve robustness while maintaining geometric
        % equivalence to Euler curve
        a = sqrt(2 * R_c * s_c);

        % theta - radians by which the line turned
        theta = (s_c/a)^2;

        % set up first point of the curve at a third of the road length
        x1 = a * fresnels(s_c/a);
        y1 = a * fresnelc(s_c/a);
        
        % set up lane paths up to this point
        if bidirectional
            for i=1:lanes
                startPoint = [cos(0)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(0)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
                firstCurvePoint = 2 * forwardVec + [x1 y1 0] + [cos(-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
                newPath = [startPoint, startPoint + 2 * forwardVec, firstCurvePoint];
                rPaths(i,1:9) = newPath;
            end
        else
            for i=1:lanes
                startPoint = [cos(0)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(0)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
                firstCurvePoint = 2 * forwardVec + [x1 y1 0] + [cos(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
                newPath = [startPoint, startPoint + 2 * forwardVec, firstCurvePoint];
                rPaths(i,1:9) = newPath;
            end
        end

        % Second Point

        % End Curvature
        k_c = 2 * abs(curvature) / 3;

        % End circular arc (Radius) - 1 / curvature
        R_c = 1 / k_c;

        % Arc length or length of road
        s_c = 2 * length / 3;

        % a - scaling ratio to improve robustness while maintaining geometric
        % equivalence to Euler curve
        a = sqrt(2 * R_c * s_c);

        % theta - radians by which the line turned
        theta = (s_c/a)^2;

        % set up mid-point at half the road length
        x2 = a * fresnels(s_c/a);
        y2 = a * fresnelc(s_c/a);
        
        % add second curve point to lane paths
        if bidirectional
            for i=1:lanes
                rPaths(i,10:12) = 2 * forwardVec + [x2 y2 0] + [cos(-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
            end
        else
            for i=1:lanes
                rPaths(i,10:12) = 2 * forwardVec + [x2 y2 0] + [cos(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
            end
        end

        %Third Point

        % End Curvature
        k_c = abs(curvature);

        % End circular arc (Radius) - 1 / curvature
        R_c = 1 / k_c;

        % Arc length or length of road
        s_c = length;

        % a - scaling ratio to improve robustness while maintaining geometric
        % equivalence to Euler curve
        a = sqrt(2 * R_c * s_c);

        % theta - radians by which the line turned
        theta = (s_c/a)^2;

        % set up final point of curve at full length
        x3 = a * fresnels(s_c/a);
        y3 = a * fresnelc(s_c/a);

        % add last curve points to the lane paths
        curveFacing = [cos(pi/2 - theta) sin(pi/2 - theta) 0];
        if bidirectional
            for i=1:lanes
                lastCurvePoint = 2 * forwardVec + [x3 y3 0] + [cos(-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
                rPaths(i,13:18) = [lastCurvePoint, lastCurvePoint + 2 * curveFacing];
            end
        else
            for i=1:lanes
                lastCurvePoint = 2 * forwardVec + [x3 y3 0] + [cos(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
                rPaths(i,13:18) = [lastCurvePoint, lastCurvePoint + 2 * curveFacing];
            end
        end
        
        % Rotate path points and road points to orient to facing
        % Add inPoint to place it in the correct location
        R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];

        if curvature >= 0
            curvePoints = [0 0 0; [x1 y1]*R 0; [x2 y2]*R 0; [x3 y3]*R 0] + inPoint + 2 * dirVec;
            for i=1:lanes
                for n=1:3:16
                    rPaths(i,n:n+2) = [[rPaths(i,n) rPaths(i,n+1)]*R rPaths(i,n+2)] + inPoint;
                end
            end
        else
            curvePoints = [0 0 0; [-x1 y1]*R 0; [-x2 y2]*R 0; [-x3 y3]*R 0] + inPoint + 2 * dirVec;
            theta = -1 * theta;
            for i=1:lanes
                for n=1:3:16
                    rPaths(i,n:n+2) = [[-rPaths(i,n) rPaths(i,n+1)]*R rPaths(i,n+2)] + inPoint;
                end
            end
        end

        % Adjust facing to new direction of road
        facing = mod(facing - theta, 2*pi);
        
        dirVec = [cos(facing) sin(facing) 0];

        % set up road points with extra points at beginning and end to
        % ensure direction is maintained at each
        roadPoints = [inPoint; curvePoints; curvePoints(4,:) + 2 * dirVec];

        road(drScn, roadPoints, roadWidth);
        
        for i=1:3:16
            nextPoint = rPaths(egoLane,i:i+2);
            ep = vertcat(ep, nextPoint);
        end
        
        inPoint = roadPoints(6,:);
        
    else
        
        % Creates straight road
        
        newPoint = roadPoint + roadLength * dirVec;
        
        roadPoints = [inPoint; newPoint];
        
        road(drScn, roadPoints, roadWidth);
        
        rPaths = zeros(lanes, 6);
    
        % Creates paths as vectors that correspond to the lanes on the road
        if bidirectional
            for i=1:lanes
                startPoint = inPoint + [cos(facing-pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(facing-pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
                newPath = [startPoint, startPoint + length * dirVec];
                rPaths(i,:) = newPath;
            end
        else
            for i=1:lanes
                startPoint = inPoint + [cos(facing-pi/2)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(facing-pi/2)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
                newPath = [startPoint, startPoint + length * dirVec];
                rPaths(i,:) = newPath;
            end
        end
        
        inPoint = newPoint;
        
        %set up egoPath point
        for i=1:8
            nextPoint = rPaths(egoLane,(3*i - 2):3*i);
            ep = vertcat(ep, nextPoint);
        end
        
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
    rPiece.roadPoints = roadPoints;
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
    
    %inPoint = endPoint;
    

end