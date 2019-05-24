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
        localPos = randi(100)/100;
        % get curvature of road
        curv = ( pieces(posIndex).curvature2 - pieces(posIndex).curvature1 ) * localPos + pieces(posIndex).curvature1;
        
        if curv ~= 0
            
            % Curved Road
            
            % First point of road is where clothoid curve begins
            inPoint = pieces(posIndex).roadPoints(2,:);
            
            % End Curvature
            k_c = curv;

            % End circular arc (Radius) - 1 / curvature
            R_c = 1 / k_c;

            % Arc length or length of road
            s_c = pieces(posIndex).length * localPos;

            % a - scaling ratio to improve robustness while maintaining geometric
            % equivalence to Euler curve
            a = sqrt(2 * R_c * s_c);

            % theta - radians by which the line turned
            theta = (s_c/a)^2;
            
            % set up  starting point halfway down the curved road
            x = a * fresnels(s_c/a);
            y = a * fresnelc(s_c/a);
            
            % set up starting point on right side of road
            if curv >= 0
                facing = pieces(posIndex-1).facing;
                facingDir = mod(facing - theta, 2*pi);
                R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];
                midPoint = [[x y]*R 0] + inPoint;
            % set up starting point on left side. Because the coordinates
            % are flipped for left turning roads, it will switch to the
            % right side and move across the road going left
            else
                facing = pieces(posIndex-1).facing;
                facingDir = mod(facing + theta, 2*pi);
                R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];
                midPoint = [[-x y]*R 0] + inPoint;
            end
            
            startPoint = midPoint + pieces(posIndex).width/2 * [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
            
        else
            
            % Straight road
            facingDir = pieces(posIndex).facing;
            
            % Get point at middle of the road
            midPoint = pieces(posIndex).roadPoints(1,:) + (pieces(posIndex).length/2) * [cos(facingDir) sin(facingDir) 0];
            
            % Get point on the right side of the road at the middle
            startPoint = midPoint + pieces(posIndex).width/2 * [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
            
        end
    
    % MultiLane Road
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
                
end % end switch - road type

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
        stallSpeed = randi(30) / 10;
        
        % sets another point on the left side of the road
        endPoint = startPoint + pieces(posIndex).width * [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
        
        % sets up actor path crossing the street from right to left if
        % forward parameter is true, left to right if not 
        if forward
            stallPoint = startPoint + [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
            newPath = [startPoint; stallPoint; endPoint];
        else
            stallPoint = endPoint + [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
            newPath = [endPoint; stallPoint; startPoint];
        end
        
        % after inching at the stall speed, moves across the street at a
        % speed between 1.0 and 4.5 m/s
        newSpeeds = [stallSpeed stallSpeed (speed+9)/4];
        
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
