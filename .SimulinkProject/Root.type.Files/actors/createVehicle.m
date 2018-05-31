function [ac, newPath, newSpeeds] = createVehicle(drScn, pieces, type, pathType, forward, speed, dimensions, position, posIndex)
%CREATEVEHICLE Create vehicle function

%Get dimensions
vLen = (dimensions(1) + 20) / 30;
vWdth = (dimensions(2) + 20) / 30;
vHght = (dimensions(3) + 20) / 30;
switch(type)
    case 1
        % Sedan
        ac = vehicle(drScn, 'Length', 5 * vLen, 'Width', 2 * vWdth, 'Height', 1.6 * vHght, 'Position', position);
    case 2
        % Truck
        ac = vehicle(drScn, 'Length', 5 * vLen, 'Width', 2 * vWdth, 'Height', 2.5 * vHght, 'Position', position);
    case 3
        % Motorcycle
        ac = vehicle(drScn, 'Length', 2 * vLen, 'Width', 0.5 * vWdth, 'Height', 1.4 * vHght, 'Position', position);
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
                        % Will find a way to make an actor
                        % wait or something
                        lanes = pieces(a).lanes;
                        if speed > 2
                            speed = speed - 2
                        end
                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(randi(lanes), c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    end

                    pathOrder = pathOrder + 1;
                end
            end

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
                        % Will find a way to make an actor
                        % wait or something if there's
                        % another actor already there
                        lanes = pieces(a).lanes;
                        for c=1:3:size(pieces(a).reverseDrivingPaths,2)
                            nextPoint = pieces(a).reverseDrivingPaths(randi(lanes), c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    end

                    pathOrder = pathOrder + 1;
                end
            end

        end

    % cut-off
    case 2

end % end switch

end % end function

