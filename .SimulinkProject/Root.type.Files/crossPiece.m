function [ep, inPoint, facing, pieces] = crossPiece(drScn, inPoint, ep, facing, pieces)

    holdPoint = inPoint;
    
    [ep, inPoint, facing, pieces] = straightPiece(drScn, inPoint, ep, facing, pieces);
    
    midPoint = (holdPoint + inPoint)/2;
    
    midX = midPoint(1);
    leftX = midX - 12.5*sin(facing);
    rightX = midX + 12.5*sin(facing);
    
    midY = midPoint(2);
    leftY = midY + 12.5*cos(facing);
    rightY = midY - 12.5*cos(facing);
    
    rightPoint = [rightX rightY 0];
    leftPoint = [leftX leftY 0];
    
    road(drScn, [leftPoint; rightPoint],6)
    

end