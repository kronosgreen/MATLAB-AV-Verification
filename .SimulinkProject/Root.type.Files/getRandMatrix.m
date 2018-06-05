%{
 Generate Random Road String

   Christopher Medrano
%}

function [roadMatrix, actorMatrix] = getRandMatrix(sizeRoad, sizeActors, rngNum)
    
%GETRANDMATRIX creates matrices randomly with seed rngNum that will become
%a scenario
    
    %need to set up biases/weights for preferred scenarios here
    
    rng(rngNum,'twister');
    
    pieces = ["Multilane Road", "Roundabout", "4-way Intersection", "Fork"];
    
    roadMatrix = zeros(sizeRoad,8);
    
    egoLane = 1;
    
    % 0 = one direction
    % 1 = two directions with double solid yellow line
    % 2 = two directions with dashed yellow line
    % currently set to be bidirectional
    bidirectional = randi(2);
    
    for i=1:sizeRoad
        
        % Currently only multilane road is implemented
        roadPiece = 1;
        
        roadLength = randi(18) * 5 + 10;
        
        lanes = randi(5);
        
        %keeping it bidirectional for now
        probChangeBiDir = randi(100)/100;
        if probChangeBiDir < 0
            bidirectional = randi(3) - 1;
        end
        
        midLane = randi(2) - 1;
        
        speedLimit = randi(11) * 2.2352 + 11.176;
        
        roadSlickness = randi(100) / 200;
        
        curvature = randi(100)/1500 - 0.0333;
        
        newRoad = [roadPiece roadLength lanes bidirectional midLane speedLimit roadSlickness curvature];
        
        roadMatrix(i,:) = newRoad;
    end
    
    actorMatrix = zeros(sizeActors,9);
    
    actors = ["Other Car", "Pedestrian", "Tree", "Building", "Stop Sign"];
    
    cars = ["Sedan", "Truck", "Motorcycle"]; 
    
    paths = ["Normal", "Cut Off", "Tailgating", "Sudden Stop", "Lane Entering"];
    
    for i = 1:sizeActors
        
        actorType = randi(2);%(length(actors));
        
        carType = randi(3);%(length(cars));
        
        pathType = 1;%randi(length(paths));
        
        movSpeed = randi(7) - 4;
        
        dimensions = [randi(10) randi(10) randi(10)];
        
        startLoc = randi(100) / 100;
        
        forward = randi(2) - 1;
        
        newActor = [actorType carType pathType movSpeed dimensions startLoc forward];
        
        actorMatrix(i,:) = newActor;
        
    end
    
end