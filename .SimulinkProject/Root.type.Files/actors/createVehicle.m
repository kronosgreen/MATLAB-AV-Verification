function [pieces, ac, newPath, newSpeeds] = createVehicle(drScn, pieces, type, pathType, forward, speed, dimensions, posIndex, offset)
%CREATEVEHICLE Create vehicle function

%Get dimensions of Lane Width
global LANE_WIDTH;

%Get dimensions
vLen = (dimensions(1) + 20) / 30;
vWdth = (dimensions(2) + 20) / 30;
vHght = (dimensions(3) + 20) / 30;
switch(type)
    case 1
        % Sedan
        ac = vehicle(drScn, 'Length', 5 * vLen, 'Width', 2 * vWdth, 'Height', 1.6 * vHght);
    case 2
        % Truck
        ac = vehicle(drScn, 'Length', 5 * vLen, 'Width', 2 * vWdth, 'Height', 1.6 * vHght);
        % standard sizes, but too big to see right now
        %ac = vehicle(drScn, 'Length', 17.5 * vLen, 'Width', 2.5 * vWdth, 'Height', 4.2 * vHght, 'Position', position);
    case 3
        % Motorcycle
        ac = vehicle(drScn, 'Length', 2 * vLen, 'Width', 0.5 * vWdth, 'Height', 1.4 * vHght);
end

% create path for new actor
newPath = [];
newSpeeds = [];
% order of path placement for now
pathOrder = 1;
% base path on path type
switch(pathType)
    
    %
    % Normal Path
    %
    % - will follow the preset paths set by the roads' lanes
    
    case 1
        
        if forward || ~pieces(2).bidirectional
            
            % Create Forward Path
            for a=posIndex:length(pieces)
                % Non zero Pieces have drivable points
                if pieces(a).type ~= 0
                    
                    %find available lane
                    availableLane = -1;
                    for b=1+pieces(a).bidirectional*pieces(a).lanes:(1+pieces(a).bidirectional)*pieces(a).lanes
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b - pieces(a).bidirectional * pieces(a).lanes;
                            break
                        end
                    end
                    
                    %add lane path to new actor's driving path
                    if availableLane ~= -1
                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    else
                        % Actor will slow down if no available lane
                        
                        lane = randi(pieces(a).lanes);
                        
                        disp("could not find available lane");
                        stallPoint = pieces(a).forwardDrivingPaths(lane,1:3) - 2 * [cos(pieces(a-1).facing) sin(pieces(a-1).facing) 0];
                        newPath = vertcat(newPath, stallPoint);
                        newSpeeds = [newSpeeds 0];

                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(lane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    end

                    pathOrder = pathOrder + 1;
                    
                end % end if check for non road pieces
                
            end % end road pieces for loop

        else

            % Create Reverse Path

            for a=posIndex:-1:1
                % Non zero Pieces have drivable points
                if pieces(a).type ~= 0

                    %find available lane
                    availableLane = -1;
                    for b=1:pieces(a).lanes
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b;
                            break
                        end
                    end
                    
                    %add lane path to new actor's driving path
                    if availableLane ~= -1
                        for c=1:3:size(pieces(a).reverseDrivingPaths,2)
                            nextPoint = pieces(a).reverseDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    else
                        % Actor will slow down if no availbale lane
                        
                        lane = randi(pieces(a).lanes);
   
                        disp("could not find available lane");
                        stallPoint = pieces(a).reverseDrivingPaths(lane,1:3) + [cos(pieces(a+1).facing) sin(pieces(a+1).facing) 0];
                        newPath = vertcat(newPath, stallPoint);
                        newSpeeds = [newSpeeds 0];

                        for c=1:3:size(pieces(a).reverseDrivingPaths,2)
                            nextPoint = pieces(a).reverseDrivingPaths(lane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                        
                    end

                    pathOrder = pathOrder + 1;
                    
                end % end if check for non road piece
                
            end % end road for loop

        end % end if forward/reverse

    %
    % Off-lane Path
    %
    % - will veer off normal path by offset parameter
    
    case 2

        if forward || ~pieces(2).bidirectional
            
            % Create Forward Path
            for a=posIndex:length(pieces)
                % Non zero Pieces have drivable points
                if pieces(a).type ~= 0
                    
                    %find available lane
                    availableLane = -1;
                    for b=1+pieces(a).bidirectional*pieces(a).lanes:(1+pieces(a).bidirectional)*pieces(a).lanes
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b - pieces(a).bidirectional * pieces(a).lanes;
                            break
                        end
                    end

                    %add lane path to new actor's driving path
                    if availableLane ~= -1
                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    else
                        % Actor will slow down if no available lane

                        lane = randi(pieces(a).lanes);

                        disp("could not find available lane");
                        stallPoint = pieces(a).forwardDrivingPaths(lane,1:3) - 2 * [cos(pieces(a-1).facing) sin(pieces(a-1).facing) 0];
                        newPath = vertcat(newPath, stallPoint);
                        newSpeeds = [newSpeeds 0];

                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(lane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    end

                    pathOrder = pathOrder + 1;
                    
                end % end if check for non-road pieces
                
            end % end road pieces for loop

        else

            % Create Reverse Path

            for a=posIndex:-1:1
                % Non zero Pieces have drivable points
                if pieces(a).type ~= 0

                    %find available lane
                    availableLane = -1;
                    for b=1:pieces(a).lanes
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b;
                            break
                        end
                    end
                    
                    %add lane path to new actor's driving path
                    if availableLane ~= -1
                        for c=1:3:size(pieces(a).reverseDrivingPaths,2)
                            nextPoint = pieces(a).reverseDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    else
                        % Actor will slow down if no availbale lane
                        
                        lane = randi(pieces(a).lanes);
   
                        disp("could not find available lane");
                        stallPoint = pieces(a).reverseDrivingPaths(lane,1:3) + [cos(pieces(a+1).facing) sin(pieces(a+1).facing) 0];
                        newPath = vertcat(newPath, stallPoint);
                        newSpeeds = [newSpeeds 0];

                        for c=1:3:size(pieces(a).reverseDrivingPaths,2)
                            nextPoint = pieces(a).reverseDrivingPaths(lane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                        
                    end

                    pathOrder = pathOrder + 1;
                    
                end % end if check for non road piece
                
            end % end road for loop

        end % end if forward/reverse
        
        % Noise Generation
        % - moves the points in a path off the lane by the offset parameter
        for n=1:3:length(newPath)
            dirOffset = 2*pi * rand();
            newPath(n:n+2) = newPath(n:n+2) + offset * LANE_WIDTH * [cos(dirOffset) sin(dirOffset) 0];
        end
        
end % end switch

end % end function

