function [inPoint, facing, pieces] = laneSizeChange(drScn, inPoint, facing, newWidth, pieces, dirVec, lanes, bidirectional, midTurnLane, sLimit, rSlick)
    %LANESIZECHANGE
    %   Creates the transition piece between two road pieces to account for
    %   difference in number of lanes or size
    
    % get global value for lane width
    global LANE_WIDTH;
    
    % Setting a separate reference for the starting point
    oldPoint = inPoint;
    
    % Old width
    rWidth = pieces(length(pieces)).width;
    
    % Total change in road width
    change = newWidth - rWidth;

    % How many pieces the transition will take place over
    numPieces = 8;
    
    % Total length of transition piece
    transitionSize = 10;
    
    % Lane Markings
    if newWidth >= rWidth
        % Get number of lanes in smaller road
        smallerLaneNum = pieces(length(pieces)).lanes;
        % Get number of lanes in larger road
        largerLaneNum = lanes;
        % get total lane number
        totalLanes = newWidth / LANE_WIDTH;
        % adds mid lane if not added yet
        if bidirectional && ~midTurnLane && pieces(length(pieces)).midTurnLane
            totalLanes = totalLanes + 1;
        end
    else
        % Get number of lanes in smaller road
        smallerLaneNum = lanes;
        % Get number of lanes in larger road
        largerLaneNum = pieces(length(pieces)).lanes;
        % get total lane number
        totalLanes = rWidth / LANE_WIDTH;
        % adds mid lane if not added yet
        if bidirectional && ~pieces(length(pieces)).midTurnLane && midTurnLane
            totalLanes = totalLanes + 1;
        end
    end

    
    %
    % Get types of lane markers throughout road
    %
    lm = laneMarking('Solid','Color','w');
    if bidirectional
        % Place left side of road's lane markers
        for i=1:largerLaneNum-1
            lm = vertcat(lm, laneMarking('Dashed','Color','w'));
        end
        
        % Place yellow lines in middle
        if midTurnLane || pieces(length(pieces)).midTurnLane
            lm = vertcat(lm, [laneMarking('SolidDashed','Color','y'); ...
                laneMarking('DashedSolid','Color','y')]);
        else
            if bidirectional == 1
                lm = vertcat(lm, laneMarking('DoubleSolid','Color','y'));
            elseif bidirectional == 2
                lm = vertcat(lm, laneMarking('Dashed','Color','y'));
            end
        end
        
        % Place right side of road's lane markers
        for i=1:largerLaneNum-1
            lm = vertcat(lm, laneMarking('Dashed','Color','w'));
        end
    else
        for i=1:largerLaneNum-1
            lm = vertcat(lm, laneMarking('Dashed','Color','w'));
        end
    end
    lm = vertcat(lm, laneMarking('Solid','Color','w'));
    
    
    %
    % Calculate Transition pieces and place on road
    %
    for i = 1:numPieces
        
        % calculate new width of transition piece
        rWidth = rWidth + change/numPieces;
        % calculate new end point for transition piece
        newPoint = oldPoint + transitionSize*dirVec/numPieces;
        
        % Lane Specifications
        % Set widths
        widths = zeros(totalLanes,1);
        % will determine how many of outer lanes will have non-zero width
        availableWidth = rWidth;
        
        if bidirectional
            % determines whether to account for a mid turn lane when
            % calculating lane index
            mid = (midTurnLane || pieces(length(pieces)).midTurnLane);
            
            if midTurnLane && ~pieces(length(pieces)).midTurnLane
            % mid turn lane to no mid turn lane

                midLaneWidth = LANE_WIDTH * (numPieces - i) / numPieces;
                
            elseif ~midTurnLane && pieces(length(pieces)).midTurnLane
            % no mid turn lane to mid turn lane

                midLaneWidth = LANE_WIDTH * i / numPieces;

            else
            % both mid turn lanes or neither
            % if neither, will get overwritten

                midLaneWidth = LANE_WIDTH;

            end   
            
            if midLaneWidth < 0.5
                midLaneWidth = 0.5;
            end
            widths(largerLaneNum+1) = midLaneWidth;
            % will only subtract if mid lane exists
            availableWidth = availableWidth - mid * midLaneWidth;
                
            for b = 1:smallerLaneNum
                % road to left of mid turn lane
                widths(largerLaneNum - b + 1) = LANE_WIDTH;
                % road to right of mid turn lane
                widths(largerLaneNum + b + mid) = LANE_WIDTH;
                % update available width
                availableWidth = availableWidth - 2 * LANE_WIDTH;
            end
            % here is where the sizes will change 
            for b = largerLaneNum - smallerLaneNum:-1:1
                
                if availableWidth >= 2 * LANE_WIDTH
                % create new lanes
                    
                    % lane on left side of road
                    widths(b) = LANE_WIDTH;
                    % lane on right side of road
                    widths(totalLanes - b + 1) = LANE_WIDTH;
                    % update available width
                    availableWidth = availableWidth - 2 * LANE_WIDTH;
                    
                elseif availableWidth >= 1
                % give out remainding width
                    
                    % lane on left side of road
                    widths(b) = availableWidth/2;
                    % lane on right side of road
                    widths(totalLanes - b + 1) = availableWidth/2;
                    % update available width
                    availableWidth = 0;
                
                else
                % set remainding widths to 0.5, the minimum width for a
                % lane
                
                     % lane on left side of road
                    widths(b) = 0.5;
                    % lane on right side of road
                    widths(totalLanes - b + 1) = 0.5;
                    
                end
                
            end
            
        else
            % Forward only
            
            % Even to even or odd to odd lane numbers
            if mod(smallerLaneNum, 2) == mod(largerLaneNum, 2)
                % Center lanes that coincide line up with smaller road
                
                % center lanes start
                cenLaneStart = ceil((largerLaneNum - smallerLaneNum) / 2) + 1;
                for b=0:smallerLaneNum-1
                    widths(cenLaneStart + b) = LANE_WIDTH;
                end
                
                % Outer Lanes
                for b=1:cenLaneStart-1
                    if availableWidth >= 2 * LANE_WIDTH
                        widths(b) = LANE_WIDTH;
                        widths(totalLanes - b + 1) = LANE_WIDTH;
                        availableWidth = availableWidth - LANE_WIDTH * 2;
                    elseif availableWidth >= 1
                        widths(b) = availableWidth / 2;
                        widths(totalLanes - b + 1) = availableWidth / 2;
                        availableWidth = 0;
                    else
                        widths(b) = 0.5;
                        widths(totalLanes - b + 1) = 0.5;
                    end
                end
                
            % Odd to even or even to odd lane numbers
            else
                
                % keep going to the right with what space you have
                for b=1:largerLaneNum
                    if availableWidth >= LANE_WIDTH
                        widths(b) = LANE_WIDTH;
                        availableWidth = availableWidth - LANE_WIDTH;
                    elseif availableWidth >= 0.5
                        widths(b) = availableWidth;
                        availableWidth = 0;
                    else
                        widths(b) = 0.5;
                    end
                end
                
            end % end odd-even / even-odd 1-way transitions
            
        end % end 1-way road (~bidirectional)
        
        % Create spec
        ls = lanespec(totalLanes,'Width',widths,'Marking',lm);
        
        % Place road piece in scene
        road(drScn, [oldPoint; newPoint], 'Lanes', ls);
        
        % Update oldPoint
        oldPoint = newPoint;
        
    end % end for loop making transition piece
    
    % set up bounding box
    if facing >= 0 && facing < pi/2
        botLeftCorner = inPoint + [-cos(facing+pi/2)*newWidth/2 -sin(facing-pi/2)*newWidth/2 0];
        topRightCorner = inPoint + transitionSize*dirVec + [cos(facing-pi/2)*newWidth/2 sin(facing+pi/2)*newWidth/2 0];
    elseif facing >= pi/2 && facing < pi
        botLeftCorner = inPoint + [-cos(facing-pi/2)*newWidth/2 -sin(facing+pi/2)*newWidth/2 0];
        topRightCorner = inPoint + transitionSize*dirVec + [cos(facing+pi/2)*newWidth/2 sin(facing-pi/2)*newWidth/2 0];
    elseif facing >= pi && facing < 3*pi/2
        botLeftCorner = inPoint + transitionSize*dirVec + [-cos(facing-pi/2)*newWidth/2 -sin(facing+pi/2)*newWidth/2 0];
        topRightCorner = inPoint + [cos(facing+pi/2)*newWidth/2 sin(facing-pi/2)*newWidth/2 0];
    else
        botLeftCorner = inPoint + transitionSize*dirVec + [-cos(facing+pi/2)*newWidth/2 -sin(facing-pi/2)*newWidth/2 0];
        topRightCorner = inPoint + [cos(facing-pi/2)*newWidth/2 sin(facing+pi/2)*newWidth/2 0];
    end

    
    rPiece.type = 0;
    rPiece.lineType = 0;
    rPiece.roadPoints = [inPoint; newPoint];
    rPiece.range = [botLeftCorner; topRightCorner];
    rPiece.facing = facing;
    rPiece.length = 10;
    rPiece.curvature1 = 0;
    rPiece.curvature2 = 0;
    rPiece.midTurnLane = midTurnLane;
    rPiece.bidirectional = bidirectional;
    rPiece.lanes = lanes;
    rPiece.forwardDrivingPaths = 0;
    rPiece.reverseDrivingPaths = 0;
    rPiece.occupiedLanes = [0];
    rPiece.width = rWidth;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = sLimit;
    rPiece.slickness = rSlick;

    inPoint = newPoint;
    
    pieces = [pieces; rPiece];

end

