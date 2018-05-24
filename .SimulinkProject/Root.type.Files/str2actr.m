function [vehicles, egoCar] = str2actr(drScn, actorMatrix, pieces, ep)
    % Call Global variables such as the current scenario 's'
    
    % Creates Ego Vehicle and assigns it the ego path, as well as the speed
    % limits of the road
    egoCar = vehicle(drScn);
    egoCar.ActorID = 1;
    
    if size(ep) > 0
        egoSpeeds = [];
        for z=2:length(pieces)
            if pieces(z).type ~= 0
                sLim = pieces(z).speedLimit;
                newSpeeds = ones(1, size(pieces(z).roadPoints, 1)) * sLim;
                egoSpeeds = [egoSpeeds newSpeeds];
            end
        end
        trajectory(egoCar,ep,egoSpeeds);
    else
        disp("Error: Empty Ego Path");
    end

    
    vehicles = [];
    
    % newActor = [actorType pathType carType movSpeed dimensions startLoc];
    % actors = ["Other Car", "Tree", "Building", "Stop Sign"];
    % cars = ["Sedan", "Truck", "Motorcycle"];
    
    for i = 1:size(actorMatrix,1)
        
        posIndex = round(actorMatrix(i,8) * length(pieces));
        if posIndex == 0
            posIndex = 1;
        end
        position = pieces(posIndex).roadPoints(1,:);
        
        
        switch actorMatrix(i,1)
            case 1
                % Vehicle
                disp('Placing Vehicle');
                
                %Get dimensions
                vLen = (actorMatrix(i,5) + 20) / 30;
                vWdth = (actorMatrix(i,6) + 20) / 30;
                vHght = (actorMatrix(i,7) + 20) / 30;
                switch(actorMatrix(i,3))
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
                % order of path placement for now
                pathOrder = 1;
                % base path on path type
                switch(actorMatrix(i,2))
                    % normal path
                    case 1
                        if actorMatrix(i,9) || ~pieces(2).bidirectional
                            % Create Forward Path
                            for a=posIndex:length(pieces)
                                % Non zero Pieces have drivable points
                                if pieces(a).type ~= 0

                                    %find available lane
                                    availableLane = -1;
                                    for b=1+pieces(a).bidirectional*pieces(a).lanes:(1+pieces(a).bidirectional)*pieces(a).lanes
                                        if pieces(a).occupiedLanes(b) ~= pathOrder
                                            pieces(a).occupiedLanes(b) = pathOrder;
                                            availableLane = b;
                                            break
                                        end
                                    end
                                    %add lane path to new actor's driving path
                                    if availableLane ~= -1
                                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                                            nextPoint = pieces(a).forwardDrivingPaths(availableLane, c:c+2);
                                            newPath = vertcat(newPath, nextPoint);
                                        end
                                    else
                                        % Will find a way to make an actor
                                        % wait or something
                                        for c=1:3:size(pieces(a).forwardDrivingPaths,2)
                                            nextPoint = pieces(a).forwardDrivingPaths(1, c:c+2);
                                            newPath = vertcat(newPath, nextPoint);
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
                                        end
                                    else
                                        % Will find a way to make an actor
                                        % wait or something if there's
                                        % another actor already there
                                        for c=1:3:size(pieces(a).reverseDrivingPaths,2)
                                            nextPoint = pieces(a).reverseDrivingPaths(1, c:c+2);
                                            newPath = vertcat(newPath, nextPoint);
                                        end
                                    end

                                    pathOrder = pathOrder + 1;
                                end
                            end
                                    
                        end
                        
                    % cut-off
                    case 2
                        
                end
                
                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    newPath = vertcat(newPath, [1000 1000 1000]);
                    trajectory(ac, newPath, ones(1,size(newPath,1)) * actorMatrix(i, 4));
                end
                
            case 2
                % Tree
                disp('Placing Tree')
                
                rightDir = pieces(posIndex).facing - pi/2;
                transformVec = (1 + pieces(posIndex).width / 2) * [cos(rightDir) sin(rightDir) 0];
                position = position + transformVec; 
                ac = actor(drScn, 'Length', 0.5, 'Width', 0.5, 'Height', 6, 'Position', position);
            case 3
                % Building
                disp('Placing Building')
            case 4
                % Stop Sign
                disp('Placing Stop Sign')
        end 
    end
    
end
    