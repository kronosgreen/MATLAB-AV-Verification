function [ep, inPoint, facing, pieces] = ohPiece(drScn, ep, inPoint, facing, pieces)


    holdPoint = inPoint;
    
    firstX = inPoint(1);
    secondX = firstX + 8.5*cos(facing);
    thirdX = firstX + 16.5*cos(facing);
    fourthX = firstX + 25*cos(facing);
    
    firstY = inPoint(2);
    secondY = firstY + 8.5*sin(facing);
    thirdY = firstY + 16.5*sin(facing);
    fourthY = firstY + 25*sin(facing);
    
    secondPoint = [secondX secondY 0];
    thirdPoint = [thirdX thirdY 0];
    fourthPoint = [fourthX fourthY 0];
    
    road(drScn, [inPoint; secondPoint],6);
    road(drScn, [thirdPoint; fourthPoint],6);
        
    R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];
    
    rPoint1 = [1.5 4] * R;
    rPoint2 = [8 12] * R;
    rPoint3 = [1.5 21] * R;
    
    pPoint1 = inPoint + [rPoint1, 0];
    pPoint2 = inPoint + [rPoint2, 0];
    pPoint3 = inPoint + [rPoint3, 0];
    
    pathPoints = [pPoint1; pPoint2; pPoint3];
    
    ep = vertcat(ep, pathPoints);
    
    inPoint = fourthPoint;
    
    
    midPoint = (holdPoint + inPoint)/2;
    
    midX = midPoint(1);
    leftX = midX - 12.5*sin(facing);
    midLeftX = midX - 4*sin(facing);
    rightX = midX + 12.5*sin(facing);
    midRightX = midX + 4*sin(facing);
    
    midY = midPoint(2);
    leftY = midY + 12.5*cos(facing);
    midLeftY = midY + 4*cos(facing);
    rightY = midY - 12.5*cos(facing);
    midRightY = midY - 4*cos(facing);
    
    rightPoint = [rightX rightY 0];
    leftPoint = [leftX leftY 0];
    
    road(drScn, [leftX leftY 0; midLeftX midLeftY 0],6);
    road(drScn, [midRightX midRightY 0; rightX rightY 0],6);
    
    
    r = 8;
    angles = [pi/4 3*pi/4 5*pi/4 7*pi/4 pi/4];
    ohPoints = [zeros(1,3); zeros(1,3); zeros(1,3); zeros(1,3); zeros(1,3)];
    
    for i = 1:length(angles)
        thisX = midX + r*cos(angles(i));
        thisY = midY + r*sin(angles(i));
        ohPoints(i,:) = [thisX thisY 0];
    end
    
    road(drScn,ohPoints,6);
    
    
    dirVec = [cos(facing) sin(facing) 0];
    
    boxPoints = [0 0 0 0 0 0];
    pieces = vertcat(pieces, boxPoints);
    %ep = vertcat(ep, 24*dirVec);
    %ep = vertcat(ep, 25*dirVec);
    
end