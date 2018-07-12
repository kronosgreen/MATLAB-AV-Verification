function available = checkAvailability(pieces, botLeftCorner, topRightCorner, endPoints)

    %CHECKAVAILABILITY 
    %   Check to see if the next piece will not cause conflicts such as it
    %   arriving at a point where no extra piece could be placed without going
    %   over another piece
    disp("Checking Availability");

    available = true;
    
    if length(pieces) <= 3
        return
    end
    
    % left, right, top, and bottom values of new piece
    roadL = botLeftCorner(1);
    roadR = topRightCorner(1);
    roadT = topRightCorner(2);
    roadB = botLeftCorner(2);
    
    if pdist(endPoints, 'euclidean') < 35
        disp("Too close to end");
        available = false;
        return
    end
    
    for i = 2:length(pieces)-2
       oldL = pieces(i).range(1,1);
       oldR = pieces(i).range(2,1);
       oldT = pieces(i).range(2,2);
       oldB = pieces(i).range(1,2);
       if roadR >= oldL && roadL <= oldR && roadT >= oldB && roadB <= oldT
           disp("L,R,T,B : " + oldL + ", " + oldR + ", " + oldT + ", " + oldB);
           disp("failed : " + roadL + ", " + roadR + ", " + roadT + ", " + roadB);
           available = false;
           return
       end
    end 
     
end %end function