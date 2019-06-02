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
    bidirChanged = 0;
    
    for i=1:sizeRoad
        
        % Update Bidirectional for intersections/road changes
        if bidirChanged
            bidirectional = double(~bidirectional);
            bidirChanged = 0;
        end
        % Currently only multilane road is implemented
        % Determines which piece will be placed
        roadType = 2;%randi(2);
        
        % Sets length of the road in meters,
        % ranges from 80 to 150
        roadLength = 70 + floor(rngNum/20) * 10;%randi(8) * 10 + 70;
        
        % Sets how many lanes there are to drive on, if road is two-way,
        % lane # will be for each side (e.g. 3 lanes means 3 on each side),
        % ranges from 1 to 5
        % For 4 way intersections, lane #s represent the roads from top 
        % going clockwise
        if roadType == 2
            lanes = dec2base(258+randi(1036),6);
            while sum(lanes == '0') > 0
                lanes = dec2base(258+randi(1036),6);
            end
            lanes = string(lanes);
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
        % curvature and ending curvature, both zero means straight line,
        % cannot be too close or else errors will arise
        curvature1 = 0.060 * rand() - 0.030;
        if abs(curvature1) < 0.001, curvature1 = 0; end
        curvature2 = 0.060 * rand() - 0.030;
        while abs(curvature2 - curvature1) < 0.003
            curvature2 = 0.060 * rand() - 0.030;
        end
        if abs(curvature2) < 0.001, curvature2 = 0; end
        
        % Create 4 way intersection pattern
        % 0 is bidirectional
        % 1 is one-way going in
        % 2 is one-way going out
        % Starts from left going clockwise w/ each digit until right side
        intersectionValid = 0;
        while ~intersectionValid
            intersectionPattern = dec2base(randi(27)-1,3);
            % prevent lane patterns that create a travel lane with nowhere
            % to go
            if sum(intersectionPattern == '1') == 3 || ...
                (sum(intersectionPattern == '2') == 3 && bidirectional) || ...
                (~bidirectional && sum(intersectionPattern == '1') == 2 && sum(intersectionPattern == '0') == 1)
                intersectionValid = 0;
            else
                intersectionValid = 1;
            end
        end
        for k=1:3-size(intersectionPattern,2)
            intersectionPattern = ['0' intersectionPattern];
        end
        % Determine what direction the scenario will continue from
        % 1 - Left
        % 2 - Forward
        % 3 - Right
        continueDirection = randi(3);
        % Make sure road is going out and not in
        while intersectionPattern(continueDirection) == '1'
            continueDirection = randi(3);
        end
        intersectionPattern = [intersectionPattern int2str(continueDirection)];
        
        bidirChanged = roadType == 2 && ((intersectionPattern(continueDirection) == '0') ~= bidirectional);
        % Convert to string so that it occupies one column in the matrix
        intersectionPattern = string(intersectionPattern);
        
        % TalTech Parameters
        %radius = randi(5) + 5;
        %outer_radius = randi(5) + 5;
        
        %outgoing_angles = ;
        % side lot
        %barrier = randi(10);
        %outgoing_lanes = randi(3);
        
        % radius outer_radius outgoing_angles barrier outgoing_lanes
        % places all values in a row that will be appended to the main road
        % matrix
        newRoad = [roadType roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2];
        
        % Potential Parameters
        % - parameters that will be put in for additional pieces
        %gate = randi(2) - 1;
        % pedestrians
        %pedestrian_walkway = randi(3);
        % should include all possibilities
        % maybe separated and made into patches
        %outside_area = randi(10); % random obstacles layed out across open area
        %intersecting_pathways = randi(30);

        
        roadMatrix(i,:) = newRoad;
    end
    
    actorMatrix = zeros(sizeActors, 10);
    
    actors = ["Other Car", "Pedestrian"];
    
    cars = ["Sedan", "Truck", "Motorcycle"]; 
    
    paths = ["Normal", "Off Lane", "Platooning"];
    
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