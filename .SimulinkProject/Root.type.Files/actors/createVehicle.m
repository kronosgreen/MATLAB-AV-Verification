function [vehicleCreated, actors, pieces, ac, newPath, newSpeeds] = createVehicle(drScn, actors, pieces, actorStruct, posIndex)
%CREATEVEHICLE Creates vehicle based on given parameters and generates
%path and speed based on generated road

% Get dimensions of Lane Width
global LANE_WIDTH;

% Get variables
typeVehicle = actorStruct(2);
pathType = actorStruct(3);
speed = actorStruct(4);
dimensions = actorStruct(5:7);
startLocation = actorStruct(8);
forward = actorStruct(9);
offset = actorStruct(10);

% Get dimensions
vLen = (dimensions(1) + 20) / 30;
vWdth = (dimensions(2) + 20) / 30;
vHght = (dimensions(3) + 20) / 30;

switch(typeVehicle)
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

if pathType == 3 && length(drScn.Actors) < 2
    pathType = randi(2);
end
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
                    
                    % Find available lane by checking occupied lane array
                    % in each piece. The number in each lane represents
                    % how far a vehicle was in its path when it passed
                    % through that lane, avoiding most conflicts by merely
                    % checking that it doesn't match where the current
                    % vehicle is
                    availableLane = -1;
                    for b=1+(size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths,1): ...
                            (size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths,1) + size(pieces(a).forwardDrivingPaths,1)
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b - (size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths,1);
                            break
                        end
                    end
                    %add lane path to new actor's driving path
                    start = 1;
                    if a==posIndex, start = randi(size(pieces(a).forwardDrivingPaths,2)/3) * 3 - 2; end
                    if availableLane ~= -1
                        for c=start:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    else
                        % Actor will slow down if no available lane
                        
                        lane = randi(size(pieces(a).forwardDrivingPaths,1));
                        %stallPoint = pieces(a).forwardDrivingPaths(lane,1:3) - 2 * [cos(pieces(a-1).facing) sin(pieces(a-1).facing) 0];
                        %newPath = vertcat(newPath, stallPoint);
                        %newSpeeds = [newSpeeds 0];

                        for c=start:3:size(pieces(a).forwardDrivingPaths,2)
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

                    % If there are no lanes going reverse available, go
                    % somewhere where there is or end the vehicle's path
                    if pieces(a).reverseDrivingPaths == 0
                        if isempty(newPath)
                            continue;
                        else
                            break;
                        end
                    end
                    % Find available lane by checking occupied lane array
                    % in each piece. The number in each lane represents
                    % how far a vehicle was in its path when it passed
                    % through that lane, avoiding most conflicts by merely
                    % checking that it doesn't match where the current
                    % vehicle is
                    availableLane = -1;
                    for b=1:size(pieces(a).reverseDrivingPaths,1)
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b;
                            break
                        end
                    end
                    
                    %add lane path to new actor's driving path
                    start = 1;
                    if a==posIndex, start = randi(size(pieces(a).forwardDrivingPaths,2)/3) * 3 - 2; end
                    if availableLane ~= -1
                        for c=start:3:size(pieces(a).reverseDrivingPaths,2)
                            nextPoint = pieces(a).reverseDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            newSpeeds = [newSpeeds pieces(a).speedLimit+speed];
                        end
                    else
                        % Actor will slow down if no availbale lane
                        
                        lane = randi(size(pieces(a).reverseDrivingPaths,1));
   
                        disp("could not find available lane");
                        stallPoint = pieces(a).reverseDrivingPaths(lane,1:3) + [cos(pieces(a).facing) sin(pieces(a).facing) 0];
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
                    
                    % Find available lane by checking occupied lane array
                    % in each piece. The number in each lane represents
                    % how far a vehicle was in its path when it passed
                    % through that lane, avoiding most conflicts by merely
                    % checking that it doesn't match where the current
                    % vehicle is
                    availableLane = -1;
                    for b=1+(size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths,1): ...
                            (size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths,1) + size(pieces(a).forwardDrivingPaths,1)
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b - (size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths,1);
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

                        lane = randi(size(pieces(a).forwardDrivingPaths,1));

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
                    
                    % If there are no lanes going reverse available, go
                    % somewhere where there is or end the vehicle's path
                    if pieces(a).reverseDrivingPaths == 0
                        if isempty(newPath)
                            continue;
                        else
                            break;
                        end
                    end
                    
                    % Find available lane by checking occupied lane array
                    % in each piece. The number in each lane represents
                    % how far a vehicle was in its path when it passed
                    % through that lane, avoiding most conflicts by merely
                    % checking that it doesn't match where the current
                    % vehicle is
                    availableLane = -1;
                    for b=1:size(pieces(a).reverseDrivingPaths,1)
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
            newPath(n:n+2) = newPath(n:n+2) + offset * [cos(dirOffset) sin(dirOffset) 0];
        end
    
        
    %
    % Platooning
    %
    % - will send vehicle behind previous vehicle
    
    case 3
        
        disp("Platooning");
        
        followDist = ac.Length + 3;
        
        prevPath = actors(length(actors)).path;
        prevSpeeds = actors(length(actors)).speeds;
        
        angle = atan2(prevPath(2,2) - prevPath(1,2), prevPath(2,1) - prevPath(1,1));
        newPoint = prevPath(1,:) - followDist * [cos(angle) sin(angle) 0];
        
        newPath = [newPoint; prevPath];
        newSpeeds = [prevSpeeds(1) prevSpeeds];
        
    %
    % Cut Off Ego Vehicle
    %
    % - Track ego vehicle's position assuming its path is known 
    %   and it is following the speed limit and construct path 
    %   that passes ego vehicle and enters its lane
        
    case 4        
        disp("Cut Off Ego Vehicle");
        pathOrder = 1;
        
        egoPath = actors(1).path;
        %vehicleSpeeds = actors(1).speeds;
        %vehicleSpeeds(end) = [];
        vehicleSpeeds = [];
        cutOffPoint = size(egoPath,1) * actorStruct(11);
        
        %disp(vehicleSpeeds);
        vehicleProgress = 1;
        %disp(egoPath);
        
        if forward || ~pieces(2).bidirectional
            for a = posIndex:length(pieces)
                if pieces(a).type ~= 0
                    availableLane = -1;
                    for b = 1 + (size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths, 1):...
                            (size(pieces(a).reverseDrivingPaths,2) ~= 1) * size(pieces(a).reverseDrivingPaths, 1) + size(pieces(a).forwardDrivingPaths,1)
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                           pieces(a).occupiedLanes(b) = pathOrder;
                           availableLane = b - (size(pieces(a).reverseDrivingPaths, 2) ~= 1) * size(pieces(a).reverseDrivingPaths, 1);
                           break
                        end
                    end

                    start = 1;
                    if a == posIndex, start = randi(size(pieces(a).forwardDrivingPaths, 2) / 3) * 3 - 2; end

                    if availableLane ~= -1
                        for c = start:3:size(pieces(a).forwardDrivingPaths,2)
                            nextPoint = pieces(a).forwardDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            vehicleSpeeds = [vehicleSpeeds pieces(a).speedLimit+speed];
                        end
                    end
                end

                pathOrder = pathOrder + 1;
            end
        else 
            
        end
        %disp(vehicleSpeeds);
        while vehicleProgress <= cutOffPoint
           
           vehicleSpeeds(vehicleProgress) = round(vehicleSpeeds(vehicleProgress) + (2 * vehicleProgress));
           vehicleProgress = vehicleProgress + 1;
           
        end
        
        egoPath = actors(1).path;
        
        while vehicleProgress <= size(newPath, 1)
            newPath(vehicleProgress,1) = egoPath(1,1);
            vehicleProgress = vehicleProgress + 1;
        end
        
        newSpeeds = vehicleSpeeds;
            
           
    case 5
        disp("Stop at point");
        pathOrder = 1;
        vehicleSpeeds = [];
        
        %disp(size(pieces(2).roadPoints, 1));
        %disp(actorStruct(12));
        stopPoint = size(pieces(2).roadPoints, 1) * actorStruct(12);
        startPoint = size(pieces(2).roadPoints, 1) * startLocation;
        disp(startPoint);
        if forward || ~pieces(2).bidirectional
            for a = posIndex:length(pieces)
                if pieces(a).type ~= 0
                    availableLane = -1;
                    for b = 1 + (size(pieces(a).reverseDrivingPaths, 2) ~= 1) * size(pieces(a).reverseDrivingPaths, 1):...
                            (size(pieces(a).reverseDrivingPaths, 2) ~= 1 * size(pieces(a).reverseDrivingPaths, 1) + size(pieces(a).reverseDrivingPaths, 1))
                        
                        if pieces(a).occupiedLanes(b) ~= pathOrder
                            pieces(a).occupiedLanes(b) = pathOrder;
                            availableLane = b - (size(pieces(a).reverseDrivingPaths, 2) ~= 1) * size(pieces(a).reverseDrivingPaths, 1);
                            break;
                        end
                    end
                    
                    start = 1;
                    if a == posIndex, start = randi(size(pieces(a).forwardDrivingPaths, 2) / 3) * 3 - 2; end
                    
                    if availableLane ~= -1
                        for c = start:3:size(pieces(a).forwardDrivingPaths, 2)
                            nextPoint = pieces(a).forwardDrivingPaths(availableLane, c:c+2);
                            newPath = vertcat(newPath, nextPoint);
                            vehicleSpeeds = [vehicleSpeeds pieces(a).speedLimit + speed];
                        end
                    end
                end
                pathOrder = pathOrder + 1;
            end
            
        else
            
        end
        
        %disp(vehicleSpeeds);
        vehicleProgress = 1;
        prevSpeed = vehicleSpeeds(1);
%         while vehicleProgress <= stopPoint
%             vehicleSpeeds(vehicleProgress) = round(prevSpeed * .5);
%             prevSpeed = vehicleSpeeds(vehicleProgress);
%             vehicleProgress = vehicleProgress + 1;
%         end
        
        disp(newPath)
        disp(startPoint)
        vehicleLocation = 1;
        while vehicleLocation <= startPoint
            newPath(vehicleLocation, 2) = newPath(vehicleLocation, 2);
            vehicleLocation = vehicleLocation + 1;
        end
        
        while vehicleLocation <= size(newPath, 1)
            newPath(vehicleLocation, 2) = newPath(startPoint, 2);
            vehicleLocation = vehicleLocation + 1;
        end
        disp(newPath)
        
        
%         while vehicleProgress <= size(newPath, 1)
%             vehicleSpeeds(vehicleProgress) = 0.00001;
%             vehicleProgress = vehicleProgress + 1;
%         end
        disp(vehicleSpeeds);
        newSpeeds = vehicleSpeeds;
        
    case 6
        disp("Follow Ego Vehicle");
        
        newPath = actors(length(actors)).path;
        i = 1;
        while i < size(newPath)
            vehicleSpeeds(i) = pieces(1).speedLimit + speed;
            i = i + 1;
        end
        
        
end % end switch

% Add far off point to continue simulation after vehicle path
% done

%disp(newPath);
%disp(newSpeeds);
if ~isempty(newPath)
    disp(newPath);
    newPath = [newPath; 1000 1000 1000];
    newSpeeds = [newSpeeds 10];
    vehicleCreated = 1;
else
    disp("PATH IS EMPTY");
    vehicleCreated = 0;
end

newAct.path = newPath;
newAct.speeds = newSpeeds;

actors = [actors; newAct];

end % end function

