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
        % Determines which piece will be placed
        roadPiece = 1;
        
        % Sets length of the road in meters,
        % ranges from 45 to 100
        roadLength = randi(12) * 5 + 40;
        
        % Sets how many lanes there are to drive on, if road is two-way,
        % lane # will be for each side (e.g. 3 lanes means 3 on each side),
        % ranges from 1 to 5
        % For 4 way intersections, lane #s represent the roads from top 
        % going clockwise
        if roadPiece == 2
            lanes = string(dec2base(258+randi(1036),6));
        else
            lanes = randi(5);
        end
        
        % Determines whether the road will have a turn lane in the middle
        % (1) or not (0)
        midLane = randi(2) - 1;
        
        % Sets the speed limit for the road, when setting the paths, actors
        % will use this value to set their speed
        speedLimit = randi(11) * 2.2352 + 11.176;
        
        
        % sets both curvatures, mainly for multilane road. Starting
        % curvature and ending curvature, both zero means straight line
        curvature1 = 0.060 * rand() - 0.030;
        curvature2 = 0.060 * rand() - 0.030;
        
        % Create 4 way intersection pattern
        % Starting at the top going clockwise, 0 is bidirectional
        % 1 is one-way going in, 2 is one-way going out
        % Starts from left going clockwise w/ each digit
        intersectionValid = 0;
        while ~intersectionValid
            intersectionPattern = string(dec2base(randi(27)-1,3));
            for k=1:3-length(intersectionPattern)
                intersectionPattern = '0' + intersectionPattern;
            end
            if sum(char(intersectionPattern) == '1') == 3 || sum(char(intersectionPattern) == '2') == 3 || sum(char(intersectionPattern) == '0') <= 1
                intersectionValid = 0;
            else
                intersectionValid = 1;
            end
        end
        
        % places all values in a row that will be appended to the main road
        % matrix
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