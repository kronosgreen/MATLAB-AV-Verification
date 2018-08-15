function [vehicles, egoCar] = matrix2actr(drScn, actorMatrix, pieces)

    %% Ego Vehicle
    % Creates Ego Vehicle and assigns it the ego path, as well as the speed
    % limits of the road
    
    disp("CREATING EGO VEHICLE");
    egoStruct =  [1 1 1 0 10 10 10 0 1 0];
    [pieces, egoCar, ep, egoSpeeds] = createVehicle(drScn, pieces, egoStruct, 1);           
    egoCar.ActorID = 1;
    
    trajectory(egoCar,ep(1:size(ep,1)-1,:),egoSpeeds(1:size(egoSpeeds,2)-1));
    
    vehicles = egoCar;
    
    %% Create Actors
    
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
                
                [pieces, ac, newPath, newSpeeds] = createVehicle(drScn, pieces, actorMatrix(i,:), posIndex);
                
                vehicles = vertcat(vehicles, ac);
                
                trajectory(ac, newPath, newSpeeds);
                
            case 2
                % Pedestrian
                disp('Placing Pedestrian');
                
                % createPedestrian(drScn, pieces, actorStruct, posIndex)
                [ac, newPath, newSpeeds] = createPedestrian(drScn, pieces, actorMatrix(i,:), posIndex);
                
                if ~isempty(newPath)
                    %have to add a far off point or else the simulation
                    %will stop when anyone reaches the end
                    newPath = vertcat(newPath, [1000 1000 1000]);
                    newSpeeds = [newSpeeds 10];
                    trajectory(ac, newPath, newSpeeds);
                end
                
        end % end switch
        
    end % end for loop
    
end % end function
    