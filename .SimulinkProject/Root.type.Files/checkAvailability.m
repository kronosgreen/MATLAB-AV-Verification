function available = checkAvailability(pieces, botLeftCorner, topRightCorner)

    %CHECKAVAILABILITY 
    %   Check to see if the next piece will not cause conflicts such as it
    %   arriving at a point where no extra piece could be placed without going
    %   over another piece
    disp("Checking Availability");

    available = true;
    
    roadArea = [botLeftCorner; topRightCorner];
            
    for i = 2:length(pieces)-1
       pRange = pieces(i).range;
       if roadArea(1,1) > pRange(2,1) && roadArea(1,2) > pRange(2,2) && roadArea(2,1) < pRange(1,1) && roadArea(2,1) < pRange(2,1)
           available = false;
       end
    end 
     
end %end function