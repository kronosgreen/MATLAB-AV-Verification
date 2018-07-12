%{
 Generate Random Road String

   Christopher Medrano
%}

function [roadMatrix, actorMatrix] = getRandMatrix(sizeRoad, sizeActors, rngNum)
    
%GETRANDMATRIX creates matrices randomly with seed rngNum that will become
%a scenario
    
    %need to set up biases/weights for preferred scenarios here
    
    rng(rngNum,'twister');
    
    roadMatrix = zeros(sizeRoad,9);
    
    pieces = ["Multilane Road", "Roundabout", "4-way Intersection", "Fork"];
    
    % 0 = one direction
    % 1 = two directions with double solid yellow line
    % 2 = two directions with dashed yellow line
    % currently remains the same for the entire road
    bidirectional = randi(3) - 1;
    
    for i=1:sizeRoad
        
        % Currently only multilane road is implemented
        roadPiece = 1;
        
        roadLength = randi(12) * 5 + 40;
        
        lanes = randi(5);
        
        midLane = randi(2) - 1;
        
        speedLimit = randi(11) * 2.2352 + 11.176;
        
        % Create 4 way intersection pattern
        % Starting at the top going clockwise, 0 is bidirectional
        % 1 is one-way going out, 2 is one-way going in
        intersectionValid = 0;
        while ~intersectionValid
            intersectionPattern = string(dec2base(randi(81),3));
            if length(intersectionPattern) < 4
                intersectionPattern = ' ' * (4 - length(intersectionPattern)) + intersectionPattern;
            end
            if sum(char(intersectionPattern) == '1') < 3 || sum(char(intersectionPattern) == '2') < 3
                intersectionValid = 1;
            else
                
            end
        end
        
        % sets both curvatures, will currently both be positive
        curvature1 = 0.060 * rand() - 0.030;
        
        curvature2 = 0.060 * rand() - 0.030;
        
        newRoad = [roadPiece roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2];
        
        roadMatrix(i,:) = newRoad;
    end
    
    actorMatrix = zeros(sizeActors, 10);
    
    actors = ["Other Car", "Pedestrian"];
    
    cars = ["Sedan", "Truck", "Motorcycle"]; 
    
    paths = ["Normal", "Off Lane"];
    
    for i = 1:sizeActors
        
        % sets what type of actor it will be
        actorType = randi(length(actors));
        
        % if actor is a vehicle, sets what kind it will be
        carType = randi(length(cars));
        
        % sets what kind of path the actor will take, from normal to
        % reckless
        pathType = randi(length(paths));
        
        % sets how off of the speed limit the actor will be from -3 to 3
        % m/s
        movSpeed = randi(7) - 4;
        
        % sets how off the standard size of whatever the actor is it will
        % be
        dimensions = [randi(10) randi(10) randi(10)];
        
        % sets where in the scene the actor will begin
        startLoc = randi(100) / 100;
        
        % if a vehicle, sets whether it is going on same lanes as the ego
        % vehicle (1) or the opposite lanes (0)
        forward = randi(2) - 1;
        
        % for moving actors, sets how far off of their standard path they
        % will veer, ranges from 0 to 1
        offset = randi(100) / 100;
        
        % joins all of the actor information into a new matrix row
        newActor = [actorType carType pathType movSpeed dimensions startLoc forward offset];
        
        actorMatrix(i,:) = newActor;
        
    end
    
end