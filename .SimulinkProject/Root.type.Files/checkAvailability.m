function [available] = checkAvailability(pieces, nextPiece, inPoint, facing)

    %CHECKAVAILABILITY 
    %   Check to see if the next piece will not cause conflicts such as it
    %   arriving at a point where no extra piece could be placed without going
    %   over another piece
    disp("Checking Availability");

    available = true;
    
    LANE_WIDTH = 3;
    
    dirVec = [cos(facing) sin(facing) 0];

    switch nextPiece(1)
        %multilane road
        case 1
            
            rLength = nextPiece(2);
            roadWidth = nextPiece(3) * LANE_WIDTH * (nextPiece(5) + 1) + nextPiece(6) * LANE_WIDTH;
            
            if facing >= 0 && facing < pi/2
                botLeftCorner = inPoint + [-cos(facing+pi/2)*roadWidth/2 -sin(facing-pi/2)*roadWidth/2 0];
                topRightCorner = inPoint + rLength*dirVec + [cos(facing-pi/2)*4 sin(facing+pi/2)*4 0];
            elseif facing >= pi/2 && facing < pi
                botLeftCorner = inPoint + [-cos(facing-pi/2)*roadWidth/2 -sin(facing+pi/2)*roadWidth/2 0];
                topRightCorner = inPoint + rLength*dirVec + [cos(facing+pi/2)*4 sin(facing-pi/2)*4 0];
            elseif facing >= pi && facing < 3*pi/2
                botLeftCorner = inPoint + rLength*dirVec + [-cos(facing-pi/2)*roadWidth/2 -sin(facing+pi/2)*roadWidth/2 0];
                topRightCorner = inPoint + [cos(facing+pi/2)*4 sin(facing-pi/2)*4 0];
            else
                botLeftCorner = inPoint + rLength*dirVec + [-cos(facing+pi/2)*roadWidth/2 -sin(facing-pi/2)*roadWidth/2 0];
                topRightCorner = inPoint + [cos(facing-pi/2)*4 sin(facing+pi/2)*4 0];
            end
            
            roadArea = [botLeftCorner; topRightCorner];
            
            futurePieces = [0 0 0; 0 0 0];
            
            for i = 1:length(pieces)-1
               pRange = pieces(i).range;
               if roadArea(1,1) > pRange(2,1) && roadArea(1,2) > pRange(2,2) && roadArea(2,1) < pRange(1,1) && roadArea(2,1) < pRange(2,1)
                   available = false;
               end
            end 
                
            
        case 2
            
        case 3
            
        case 4
            
        case 5
            
    end
    
    disp(available);
end

