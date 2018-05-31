%{
 Generate Random Road String

   Christopher Medrano
%}

function [roadMatrix, actorMatrix] = getRandMatrix(sizeRoad, sizeActors, rngNum)
    
    %need to set up biases/weights for preferred scenarios here
    
    rng(rngNum,'twister');
    
    pieces = ["Multilane Road", "Roundabout", "4-way Intersection", "Fork"];
    
    randPiece = randi(length(pieces), sizeRoad, 1);
    
    roadMatrix = zeros(sizeRoad,9);
    
    egoLane = 1;
    
    bidirectional = 1;%randi(2) - 1;
    
    for i=1:sizeRoad
        
        roadPiece = 1;%randPiece(i);
        
        roadLength = randi(18) * 5 + 10;
        
        lanes = randi(5);
        
        % keeping 1 vs 2 way roads the same throughout scene
        probChangeLane = randi(100)/100;
        if probChangeLane < 0
            egoLane = randi(lanes);
        else
            if egoLane > lanes
                egoLane = randi(lanes);
            end
        end
        
        %keeping it bidirectional for now
        probChangeBiDir = randi(100)/100;
        if probChangeBiDir < 0
            bidirectional = randi(2) - 1;
        end
        
        midLane = randi(2) - 1;
        
        speedLimit = randi(11) * 2.2352 + 11.176;
        
        roadSlickness = randi(100) / 200;
        
        curvature = randi(100)/1500 - 0.0333;
        
        newRoad = [roadPiece roadLength lanes egoLane bidirectional midLane speedLimit roadSlickness curvature];
        
        roadMatrix(i,:) = newRoad;
    end
    
    actorMatrix = zeros(sizeActors,9);
    
    actors = ["Other Car", "Tree", "Building", "Stop Sign"];
    
    cars = ["Sedan", "Truck", "Motorcycle"]; 
    
    paths = ["Normal", "Cut Off", "Tailgating", "Sudden Stop", "Lane Entering"];
    
    for i = 1:sizeActors
        
        actorType = 1;%randi(length(actors));
        
        carType = randi(length(cars));
        
        pathType = 1;%randi(length(paths));
        
        movSpeed = randi(7) - 4;
        
        dimensions = [randi(10) randi(10) randi(10)];
        
        startLoc = randi(100) / 100;
        
        forward = randi(2) - 1;
        
        newActor = [actorType carType pathType movSpeed dimensions startLoc forward];
        
        actorMatrix(i,:) = newActor;
        
    end
    
end