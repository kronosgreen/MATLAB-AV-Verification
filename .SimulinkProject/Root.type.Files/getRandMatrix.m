%{
 Generate Random Road String

   Christopher Medrano
%}

function [roadMatrix, actorMatrix] = getRandMatrix(sizeRoad, sizeActors, rngNum)
    
%GETRANDMATRIX creates matrices randomly with seed rngNum that will become
%a scenario
    
    %need to set up biases/weights for preferred scenarios here
    
    rng(rngNum,'twister');
    
    %
    % Create Road Matrix
    %
    
    roadMatrix = repmat("0", sizeRoad, 12);
    
    pieces = ["Multilane Road", "4-way Intersection", "3-way Intersection", ...
                "Pedestrian Crosswalk", "Side Lot Enter"];
    
    % 0 = one direction
    % 1 = two directions with double solid yellow line
    % 2 = two directions with dashed yellow line
    % currently remains the same for the entire road
    bidirectional = randi(3) - 1;
    bidirChanged = 0;
    
    % initialize lanes to 3 if none being set
    lanes = 3;
    
    for i=1:sizeRoad
        
        % Update Bidirectional for intersections/road changes
        if bidirChanged
            bidirectional = double(~bidirectional);
            bidirChanged = 0;
        end
        % Currently only multilane road is implemented
        % Determines which piece will be placed
        roadType = randi(length(pieces));
        
        % give second option for three way intersection
        if roadType == 3, bidirectional = [char(48+bidirectional), char(47+randi(3))]; end
        
        % Sets length of the road in meters,
        if roadType == 4
            roadLength = randi(10); % Single crosswalk can be 1 through 10m wide
        else
            roadLength = randi(13) * 10 + 70; % Roads can be 80-200m long
        end
        
        % Sets how many lanes there are to drive on, if road is two-way,
        % lane num will be for each direction (e.g. 3 lanes means 3 going each way),
        % ranges from 1 to 5
        % For 4 way intersections, lane #s represent the roads from top 
        % going clockwise
        % For 3-way intersections, lane #s will be going forward and for 
        % road going out in either direction (left or right) from that road
        % as well as a binary value determining said direction
        if roadType == 2
            lanes = dec2base(258+randi(1036),6);
            while sum(lanes == '0') > 0
                lanes = dec2base(258+randi(1036),6);
            end
            lanes = string(lanes);
        elseif roadType == 3
            % [lanes forward/back, lanes going out, direction going out]
            lanes = string([char(48+randi(5)) char(48+randi(5)) char(47+randi(2))]);
        elseif roadType == 4 % Don't change lanes if going into a single crosswalk
            if str2double(string(lanes)) > 5 % Check if coming out of intersection
                lanes = randi(5);
            end
        elseif roadType == 1 || roadType == 5
            lanes = randi(5);
        end
        
        % Determines what the road will have in the center
        % 0 - nothing 
        % 1 - mid-turn lane
        % 2 - median
        % 3 - large median
        midLane = randi(4) - 1;
        
        % Sets the speed limit for the road, when setting the paths, actors
        % will use this value to set their speed
        speedLimit = randi(11) * 2.2352 + 11.176;
        % Set a lower speed limit for pedestrian crosswalk
        if roadType == 4, speedLimit = (randi(3) + 1) * 2.2352; end
        
        % sets both curvatures, mainly for multilane road. Starting
        % curvature and ending curvature, both zero means straight line,
        % cannot be too close or else errors will arise
        curvature1 = 0.050 * rand() - 0.025;
        if abs(curvature1) < 0.001, curvature1 = 0; end
        curvature2 = 0.050 * rand() - 0.025;
        while abs(curvature2 - curvature1) < 0.003
            curvature2 = 0.050 * rand() - 0.025;
        end
        if abs(curvature2) < 0.001, curvature2 = 0; end
        
        if roadType == 2
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

            bidirChanged = (intersectionPattern(continueDirection) == '0') ~= bidirectional;
            % Convert to string so that it occupies one column in the matrix
            intersectionPattern = string(intersectionPattern);
        else
            intersectionPattern = 0;
        end
        
        % Pedestrian Pathways - 'pos1_side1_freq1:pos2...'
        if roadType == 4
            leftFreq = 48 + randi(10) - 1;
            rightFreq = 48 + randi(10) - 1;
            pedPathWays = [48 48 leftFreq ':' 48 49 rightFreq];
        else
            numPed = randi(6) - 1;
            if numPed > 0
                pedPathWays = [char(48+randi(10)-1) char(48+randi(2)-1) char(48+randi(10)-1)];
                for k=1:numPed-1
                    pedPathWays = [pedPathWays ':' (48+randi(10)-1) (48+randi(2)-1) (48+randi(10)-1)];
                end
            else
                pedPathWays = 0;
            end
        end
        pedPathWays = string(pedPathWays);
        
        % Outlets - 'pos1_side1_size1:pos2...'
        numOutlets = randi(4) - 1;
        if roadType == 1 && numOutlets > 0
            outlets = [char(48+randi(10)-1) char(48+randi(2)-1) char(48+randi(10)-1)];
            for k = 1:numOutlets-1
                outlets = [outlets ':' (48+randi(10)-1) (48+randi(2)-1) (48+randi(10)-1)];
            end
        else
            outlets = "000";
        end
        outlets = string(outlets);
        
        % Show Lane Markers
        showMarkers = randi(2) - 1;
        
        % places all values in a row that will be appended to the main road
        % matrix
        %             1           2        3        4             5         6
        newRoad = [roadType, roadLength, lanes, string(bidirectional), midLane, speedLimit, ...
                    ... %   7                8        9             10          11        12 
                    intersectionPattern, curvature1, curvature2, pedPathWays, outlets, showMarkers];

        roadMatrix(i,:) = newRoad;
        
        % Reset bidirectional if 3-way inter
        if roadType == 3, bidirectional = str2double(bidirectional(1)); end
        
    end
    
    %
    % Create Actor Matrix
    %
    
    actorMatrix = zeros(sizeActors, 10);
    
    actors = ["Vehicle", "Pedestrian"];
    
    cars = ["Sedan", "Truck", "Motorcycle"]; 
    
    paths = ["Normal", "Off Lane", "Platooning", "Cut Off", "Stop At Point", "Follow"];
    
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
        
        % Position vehicle will cut off ego
        cutOffPoint = randi(100) / 100;
        
        % Position vehicle will stop moving
        stopPoint = randi(100) / 100;
        
        % joins all of the actor information into a new matrix row
        newActor = [actorType carType pathType movSpeed dimensions startLoc forward offset cutOffPoint, stopPoint];
        

        
        actorMatrix(i,:) = newActor;
        
    end
    
end