function [vehicles, egoCar] = matrix2actr(drScn, actorMatrix, pieces)
    % Call Global variables such as the current scenario 's'
    
    % Creates Ego Vehicle and assigns it the ego path, as well as the speed
    % limits of the road
    
    % createVehicle(drScn, pieces, type, pathType, forward, speed, dimensions, posIndex)
    [pieces, egoCar, ep, egoSpeeds] = createVehicle(drScn, pieces, 1, 1, 1, 0, [1 1 1], 1);           
    egoCar.ActorID = 1;

    trajectory(egoCar,ep,egoSpeeds);
    
    vehicles = [egoCar];
    
    % newActor = [actorType pathType carType movSpeed dimensions startLoc forward];
    % actors = ["Other Car", "Tree", "Building", "Stop Sign"];
    % cars = ["Sedan", "Truck", "Motorcycle"];
    
    for i = 1:size(actorMatrix,1)
        
        % places actor somewhere along the road at a road piece and not a
        % road transition piece (odd numbers)
        posIndex = round(actorMatrix(i,8) * length(pieces));
        if posIndex == 0
            posIndex = 2;
        elseif mod(posIndex, 2) == 1
            posIndex = posIndex + 1;
        end
        
        % Creates type of actor based on first value of matrix entry
        switch actorMatrix(i,1)
            case 1
                % Vehicle
                disp('Placing Vehicle');
                
                % createVehicle(drScn, pieces, type, pathType, forward, speed, dimensions, posIndex)
                [pieces, ac, newPath, newSpeeds] = createVehicle(drScn, pieces, actorMatrix(i,2), actorMatrix(i,3), actorMatrix(i,9), actorMatrix(i,4), actorMatrix(i,5:7), posIndex);

                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    newPath = vertcat(newPath, [1000 1000 1000]);
                    newSpeeds = [newSpeeds 10];
                    trajectory(ac, newPath, newSpeeds);
                end
                
                vehicles = vertcat(vehicles, ac);
                
            case 2
                % Pedestrian
                disp('Placing Pedestrian');
                
                % createPedestrian(drScn, pieces, pathType, speed, forward, dimensions, posIndex)
                [ac, newPath, newSpeeds] = createPedestrian(drScn, pieces, actorMatrix(i,3), actorMatrix(i,4), actorMatrix(i,9), actorMatrix(i,5:7), posIndex);
                
                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    newPath = vertcat(newPath, [1000 1000 1000]);
                    newSpeeds = [newSpeeds 10];
                    trajectory(ac, newPath, newSpeeds);
                end
                
            case 3
                % Tree
                disp('Placing Tree');
                
                
            case 4
                % Stop Sign
                disp('Placing Stop Sign');
                
        end % end switch
        
    end % end for loop
    
end % end function
    