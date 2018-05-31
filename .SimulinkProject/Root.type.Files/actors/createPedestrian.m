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
            
            startPoint = pieces(posIndex).roadPoints(2,:);
            % End Curvature
            k_c = abs(pieces(posIndex).curvature) / 2;

            % End circular arc (Radius) - 1 / curvature
            R_c = 1 / k_c;

            % Arc length or length of road
            s_c = pieces(posIndex).length / 2;

            % a - scaling ratio to improve robustness while maintaining geometric
            % equivalence to Euler curve
            a = sqrt(2 * R_c * s_c);

            % theta - radians by which the line turned
            theta = (s_c/a)^2;
            
            % set up  starting point halfway down the curved road
            x = a * fresnels(s_c/a);
            y = a * fresnelc(s_c/a);

            if curv < 0
                facingDir = pieces(posIndex).facing - theta/2;
                rotateAngle = pieces(posIndex).facing - theta;
                R = [cos(rotateAngle - pi/2) sin(rotateAngle - pi/2); -sin(rotateAngle - pi/2) cos(rotateAngle - pi/2)];
                startPoint = [[-x y]*R 0] + startPoint;
            else
                facingDir = pieces(posIndex).facing + theta/2;
                rotateAngle = pieces(posIndex).facing + theta;
                R = [cos(rotateAngle - pi/2) sin(rotateAngle - pi/2); -sin(rotateAngle - pi/2) cos(rotateAngle - pi/2)];
                startPoint = [[x y]*R 0] + startPoint;
            end
            
            startPoint = startPoint + [cos(facingDir - pi/2) sin(facingDir - pi/2) 0];
            
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
        
        stallSpeed = randi(100) / 100;
        
        stallPoint = startPoint + [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
        
        endPoint = startPoint + pieces(posIndex).width * [cos(facingDir + pi/2) sin(facingDir + pi/2) 0];
    
        newPath = [startPoint; stallPoint; endPoint];
        newSpeeds = [0 stallSpeed 1.4];
        
    %
    % Different Path ?
    %
    case 2
        
end % end switch

end % end function

