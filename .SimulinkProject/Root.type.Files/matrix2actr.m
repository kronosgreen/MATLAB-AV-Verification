function [vehicles, egoCar] = matrix2actr(drScn, actorMatrix, pieces, ep)
    % Call Global variables such as the current scenario 's'
    
    % Creates Ego Vehicle and assigns it the ego path, as well as the speed
    % limits of the road
    egoCar = vehicle(drScn);
    egoCar.ActorID = 1;
    
    if size(ep) > 0
        egoSpeeds = [];
        for z=2:length(pieces)
            if pieces(z).type ~= 0
                newSpeeds = ones(1, size(pieces(z).roadPoints, 1)) * pieces(z).speedLimit;
                egoSpeeds = [egoSpeeds newSpeeds];
            end
        end
        trajectory(egoCar,ep,egoSpeeds);
    else
        disp("Error: Empty Ego Path");
    end

    
    vehicles = [];
    
    % newActor = [actorType pathType carType movSpeed dimensions startLoc forward];
    % actors = ["Other Car", "Tree", "Building", "Stop Sign"];
    % cars = ["Sedan", "Truck", "Motorcycle"];
    
    for i = 1:size(actorMatrix,1)
        
        posIndex = round(actorMatrix(i,8) * length(pieces));
        if posIndex == 0
            posIndex = 1;
        elseif mod(posIndex, 2) == 1
            posIndex = posIndex + 1;
        end
        
        position = pieces(posIndex).roadPoints(1,:);
        
        
        switch actorMatrix(i,1)
            case 1
                % Vehicle
                disp('Placing Vehicle');
                
                % createVehicle(drScn, pieces, type, pathType, forward, speed, dimensions, position, posIndex)
                [ac, newPath, newSpeeds] = createVehicle(drScn, pieces, actorMatrix(i,2), actorMatrix(i,3), actorMatrix(i,9), actorMatrix(i,4), actorMatrix(i,5:7), position, posIndex);
                
                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    newPath = vertcat(newPath, [1000 1000 1000]);
                    newSpeeds = [newSpeeds 10];
                    trajectory(ac, newPath, newSpeeds);
                end
                
            case 2
                % Pedestrian
                disp('Placing Pedestrian');
                
                % createPedestrian(drScn, pieces, pathType, speed, dimensions, position, posIndex)
                [ac, newPath, newSpeeds] = createPedestrian(drScn, pieces, actorMatrix(i,3), actorMatrix(i,5:7), position, posIndex);
                
                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    newPath = vertcat(newPath, [1000 1000 1000]);
                    newSpeeds = [newSpeeds 10];
                    trajectory(ac, newPath, newSpeeds);
                end
            case 3
                % Tree
                disp('Placing Tree')
                
                rightDir = pieces(posIndex).facing - pi/2;
                transformVec = (1 + pieces(posIndex).width / 2) * [cos(rightDir) sin(rightDir) 0];
                position = position + transformVec; 
                ac = actor(drScn, 'Length', 0.5, 'Width', 0.5, 'Height', 6, 'Position', position);
            case 4
                % Stop Sign
                disp('Placing Stop Sign')
        end 
    end
    
end
    