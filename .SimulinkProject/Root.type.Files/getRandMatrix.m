%{
 Generate Random Road String

   Christopher Medrano
%}

function [roadAssertionMatrix, actorAssertionMatrix] = getRandMatrix(sizeRoad, sizeActors, rngNum)
    
    %need to set up biases/weights for preferred scenarios here
    
    rng(rngNum,'twister');
    
    pieces = ["Multilane Road", "Roundabout", "4-way Intersection", "Fork"];
    
    randPiece = randi(length(pieces), sizeRoad, 1);
    
    roadAssertionMatrix = zeros(sizeRoad,9);
    
    egoLane = 1;
    bidirectional = 1;
    
    for i=1:sizeRoad
        
        roadPiece = 1;%randPiece(i);
        
        roadLength = randi(18) * 5 + 10;
        
        lanes = randi(5);
        
        probChangeLane = randi(100)/100;
        if probChangeLane < 0.1
            egoLane = randi(lanes);
        else
            if egoLane > lanes
                egoLane = randi(lanes);
            end
        end
        
        probChangeBiDir = randi(100)/100;
        if probChangeBiDir < 0.5
            bidirectional = randi(2) - 1;
        end
        
        midLane = randi(2) - 1;
        
        speedLimit = randi(16)  * 5;
        
        roadSlickness = randi(100) / 200;
        
        angle = randi(180) - 90;
        
        newRoadAssertion = [roadPiece roadLength lanes egoLane bidirectional midLane speedLimit roadSlickness angle];
        
        roadAssertionMatrix(i,:) = newRoadAssertion;
    end
    
    actorAssertionMatrix = zeros(sizeActors,8);
    
    actors = ["Other Car", "Tree", "Building", "Stop Sign"];
    
    cars = ["Sedan", "Truck", "Motorcycle"]; 
    
    paths = ["Normal", "Cut Off", "Tailgating", "Sudden Stop", "Lane Entering"];
    
    for i = 1:sizeActors
        
        actorType = randi(length(actors));
        
        pathType = randi(length(paths));
        
        carType = randi(length(cars));
        
        movSpeed = randi(20) * 5;
        
        dimensions = [randi(10) randi(10) randi(10)];
        
        startLoc = randi(100) / 100;
        
        newActorAssertion = [actorType pathType carType movSpeed dimensions startLoc];
        
        actorAssertionMatrix(i,:) = newActorAssertion;
        
    end
    
end