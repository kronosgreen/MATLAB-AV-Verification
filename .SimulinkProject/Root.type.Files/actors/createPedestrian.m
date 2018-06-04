function [ac, newPath, newSpeeds] = createPedestrian(drScn, pieces, pathType, dimensions, position, posIndex)
%CREATEPEDESTRIAN Create pedestrian function

%Get dimensions
vLen = (dimensions(1) + 40) / 50;
vWdth = (dimensions(2) + 40) / 50;
vHght = (dimensions(3) + 40) / 50;

ac = actor(drScn, 'Length', 0.2 * vLen, 'Width', 0.2 * vWdth, 'Height', 1.75 * vHght, 'Position', position);

% create path for new actor
newPath = [];
newSpeeds = [];

% determine starting position to the right of the road
if posIndex
switch(pieces(posIndex).type)
 
    % Multilane Road
    case 1

        curv = pieces(posIndex).curvature;
        if curv ~= 0
            
            % Curved Road
            
            % First point of road is where clothoid curve begins
            inPoint = pieces(posIndex).roadPoints(2,:);
            
            % Part of road crossing where 0 < localPos <= 1
            localPos = 0.5;
            
            % End Curvature
            k_c = abs(pieces(posIndex).curvature) * localPos;

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
                
end % end switch - road type

% base path on path type
switch(pathType)
    
    %
    % Normal Path
    %
    % - will cross the road
    
    case 1
        
        stallSpeed = randi(100) / 100 + 1;
        
        stallPoint = startPoint + [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
        
        endPoint = startPoint + pieces(posIndex).width * [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
    
        newPath = [startPoint; stallPoint; midPoint; endPoint];
        newSpeeds = [stallSpeed stallSpeed 1.4 1.4];
        
    %
    % Different Path ?
    %
    case 2
        
end % end switch

end % end function

