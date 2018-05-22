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
                newSpeeds = [sLim sLim sLim sLim sLim sLim sLim sLim];
                egoSpeeds = [egoSpeeds newSpeeds];
            end
        end
        disp(egoSpeeds);
        path(egoCar,ep,egoSpeeds);
    else
        disp("Error: Empty Ego Path");
    end

    
    vehicles = [];
    
    % newActorAssertion = [actorType pathType carType movSpeed dimensions startLoc];
    %    actors = ["Other Car", "Tree", "Building", "Stop Sign"];
    %   cars = ["Sedan", "Truck", "Motorcycle"];
    
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
                % base path on path type
                switch(actorMatrix(i,2))
                    % normal path
                    case 1
                        for a=posIndex:length(pieces)
                            if pieces(a).type ~= 0
                                %find available lane
                                availableLane = -1;
                                for b=1:length(pieces(a).occupiedLanes)
                                    if pieces(a).occupiedLanes(b) == 0
                                        pieces(a).occupiedLanes(b) = 1;
                                        availableLane = b;
                                        break
                                    end
                                end
                                %add lane path to new actor's driving path
                                if availableLane ~= -1
                                    for c=1:4
                                        nextPoint = pieces(a).drivingPaths(availableLane,(3*c - 2):3*c);
                                        newPath = vertcat(newPath, nextPoint);
                                    end
                                else
                                     for c=1:4
                                        nextPoint = pieces(a).drivingPaths(availableLane,(3*c - 2):3*c);
                                        newPath = vertcat(newPath, nextPoint);
                                    end
                                end
                            end
                        end
                    % cut-off
                    case 2
                        %{ 
                        for a=posIndex:length(pieces)
                            if pieces(a).type ~= 0
                                %find available lane
                                availableLane = -1;
                                for b=1:length(pieces(a).occupiedLanes)
                                    if pieces(a).occupiedLanes(b) == 0
                                        pieces(a).occupiedLanes(b) = 1;
                                        availableLane = b;
                                        break
                                    end
                                end
                                %add lane path to new actor's driving path
                                if availableLane ~= -1
                                    for c=1:4
                                        nextPoint = pieces(a).drivingPaths(availableLane,(3*c - 2):3*c);
                                        newPath = vertcat(newPath, nextPoint);
                                    end
                                else
                                     for c=1:4
                                        nextPoint = pieces(a).drivingPaths(pieces(a).egoLane,(3*c - 2):3*c);
                                        newPath = vertcat(newPath, nextPoint);
                                    end
                                end
                            end
                        end
                        %}
                        for c=1:4
                            nextPoint = pieces(2).drivingPaths(1,(3*c - 2):3*c);
                            newPath = vertcat(newPath, nextPoint);
                        end
                        for c=1:4
                            nextPoint = pieces(3).drivingPaths(2,(3*c - 2):3*c);
                            newPath = vertcat(newPath, nextPoint);
                        end
                end
                
                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    farOffPoint = [1000 1000 1000];
                    newPath = vertcat(newPath, farOffPoint);
                    path(ac, newPath, actorMatrix(i, 4));
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
    