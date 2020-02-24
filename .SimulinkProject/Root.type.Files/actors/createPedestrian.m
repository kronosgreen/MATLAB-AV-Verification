function [ac, newPath, newSpeeds] = createPedestrian(drScn, pieces, actorStruct, posIndex)
%CREATEPEDESTRIAN Create pedestrian function

% Get lane width
global LANE_WIDTH;

% Get Variables
pathType = actorStruct(3);
speed = actorStruct(4);
forward = actorStruct(9);
dimensions = actorStruct(5:7);

%Get dimensions
pLen = (dimensions(1) + 40) / 45;
pWdth = (dimensions(2) + 40) / 45;
pHght = (dimensions(3) + 40) / 45;

ac = actor(drScn, 'Length', 0.2 * pLen, 'Width', 0.2 * pWdth, 'Height', 1.75 * pHght);

% create path for new actor
newPath = [];
newSpeeds = [];

% determine starting position to the right of the road
switch(pieces(posIndex).type)
 
    % Multilane Road
    case 1
        % Part of road crossing where 0 < localPos <= 1
        localPos = 1 + round((size(pieces(posIndex).roadPoints, 1) - 1) * randi(100)/100);
        
        % Center of road where pedestrian crosses
        midPoint = pieces(posIndex).roadPoints(localPos,:);
        nextPoint = pieces(posIndex).roadPoints(localPos+1,:);
        
        facingDir = mod( pi/2 - atan2( nextPoint(2)-midPoint(2), nextPoint(1)-midPoint(1) ), 2*pi );
        facingDir = -180;
        % Get point on the right side of the road at the middle
        startPoint = midPoint + pieces(posIndex).width/2 * [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
    
    % Four-way Intersection
    case 2
        
        % Number - Road to cross - index in roadPoints - direction
        % 1 -  left   - 3 - (facing - pi/2) : ->
        % 2 -  top    - 5 - (facing +- pi) : v
        % 3 -  right  - 7 - (facing + pi/2): <-
        % 4 -  bottom - 2 - facing : ^
        crossingRoad = randi(4);
        
        % Set up Facing direction of road to cross, always points inwards
        faceDiffs = [-pi/2 pi pi/2 0];
        facingDir = mod( pieces(posIndex).facing + faceDiffs(crossingRoad), 2*pi );
        
        % Set up Starting Point
        midPoint = pieces(posIndex).roadPoints(mod(crossingRoad*2,7)+1,:);
        % Get width of road being crossed (temp)
        roadWidth = LANE_WIDTH * 5;
        startPoint = midPoint + roadWidth/2 * [cos(facingDir-pi/2+pi*(forward==1)) sin(facingDir-pi/2+pi*(forward==1)) 0];
    
    % THree Way Intersection
    case 3
    
    % Pedestrian Crosswalk
    case 4
        
    % Side Lot Enter
    case 5
        
                
end % end switch - road type

if pathType == 3, pathType = 1; end % originally for platooning

% base path on path type
switch(pathType)
    
    %
    % Normal Path
    %
    % - will cross the road
    
    case 1
        
        % causes the pedestrian to wait at its starting end between 0.33
        % seconds and 10 seconds by making it move one meter with a speed
        % of 0.1 to 3 m/s
        %stallSpeed = randi(30) / 10;
        
        % sets another point on the left side of the road
        endPoint = startPoint + pieces(posIndex).width * [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
        
        % sets up actor path crossing the street from right to left if
        % forward parameter is true, left to right if not 
        if forward
            %stallPoint = startPoint + [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
            %newPath = [startPoint; stallPoint; endPoint];
            newPath = [startPoint; endPoint];
        else
            %stallPoint = endPoint + [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
            %newPath = [endPoint; stallPoint; startPoint];
            newPath = [endPoint; startPoint];
        end
        
        % after inching at the stall speed, moves across the street at a
        % speed between 1.0 and 4.5 m/s
        %newSpeeds = [stallSpeed stallSpeed (speed+9)/4];
        newSpeeds = [(speed+9)/4 (speed+9)/4];
        
    %
    % stops in the middle of the road
    %
    case 2
        
        % causes the pedestrian to wait at its starting end between 0.33
        % seconds and 10 seconds by making it move one meter with a speed
        % of 0.1 to 3 m/s
        stallSpeed = randi(30) / 10;
        
        % stopping point, somewhere between the two possible stall points,
        % or 1 meter from either side of the road
        stopPoint = startPoint + (rand() * (pieces(posIndex).width - 2.01) + 1.01) * [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
        
        % sets another point on the left side of the road
        endPoint = startPoint + pieces(posIndex).width * [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
        
        % sets up actor path crossing the street from right to left if
        % forward parameter is true, left to right if not 
        if forward
            stallPoint = startPoint + [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
            newPath = [startPoint; stallPoint; stopPoint; endPoint];
        else
            stallPoint = endPoint + [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
            newPath = [endPoint; stallPoint; stopPoint; startPoint];
        end
        
        % after inching at the stall speed, moves across the street at a
        % speed between 1.0 and 4.5 m/s
        newSpeeds = [stallSpeed (speed+9)/4 0 (speed+9)/4];
        
end % end switch

% Add far off point to continue simulation after vehicle path
% done
if ~isempty(newPath)
    newPath = [newPath; 1000 1000 1000];
    newSpeeds = [newSpeeds 10];
end

end % end function
