function available = checkAvailability(pieces, botLeftCorner, topRightCorner, endPoints, facing, length)

    %CHECKAVAILABILITY 
    %   Check to see if the next piece will not cause conflicts such as it
    %   arriving at a point where no extra piece could be placed without going
    %   over another piece
    disp("Checking Availability");

    available = true;
    
    if size(pieces,1) <= 3
        return
    end
    
    % left, right, top, and bottom values of new piece
    roadL = botLeftCorner(1);
    roadR = topRightCorner(1);
    roadT = topRightCorner(2);
    roadB = botLeftCorner(2);
    
    % left, right, top, and bottom values of a piece in front of next
    % piece, preventing the road from being locked out of new pieces
    testEndPoint = endPoints(2,1:2) + 40 * [cos(facing) sin(facing)];
    corners = [endPoints(2,1:2) + 6 * [cos(facing+pi/2) sin(facing+pi/2)]; ...
                endPoints(2,1:2) + 6 * [cos(facing-pi/2) sin(facing-pi/2)]; ...
                testEndPoint + 6 * [cos(facing+pi/2) sin(facing+pi/2)]; ...
                testEndPoint + 6 * [cos(facing+pi/2) sin(facing+pi/2)] ];
    testL = min(corners(:,1).');
    testR = max(corners(:,1).');
    testT = max(corners(:,2).');
    testB = min(corners(:,2).');
    
    if pdist(endPoints, 'euclidean') < (length/sqrt(2)-10)
        disp("Too close to end");
        available = false;
        return
    end
    
    for i = 2:size(pieces,1)-1
       oldL = pieces(i).range(1,1);
       oldR = pieces(i).range(2,1);
       oldT = pieces(i).range(2,2);
       oldB = pieces(i).range(1,2);
       if roadR >= oldL && roadL <= oldR && roadT >= oldB && roadB <= oldT && i ~= size(pieces,1)-1
           disp("L,R,T,B : " + oldL + ", " + oldR + ", " + oldT + ", " + oldB);
           disp("new piece : " + roadL + ", " + roadR + ", " + roadT + ", " + roadB);
           available = false;
           return
       end
       if testR >= oldL && testL <= oldR && testT >= oldB && testB <= oldT
           disp("L,R,T,B : " + oldL + ", " + oldR + ", " + oldT + ", " + oldB);
           disp("Test Piece : " + testL + ", " + testR + ", " + testT + ", " + testB);
           available = false;
           return
       end
    end 
     
end %end function