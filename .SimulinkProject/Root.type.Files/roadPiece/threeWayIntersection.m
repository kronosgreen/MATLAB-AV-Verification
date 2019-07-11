function [facing, inPoint, pieces] = threeWayIntersection(drScn, inPoint, facing, pieces, roadStruct)
%THREEWAYINTERSECTION Summary of this function goes here
%   Detailed explanation goes here

disp("Starting 3-Way Intersection");
    
% set up variables from struct
roadType = roadStruct(1);
length = roadStruct(2);
lanes = roadStruct(3);
bidirectional = roadStruct(4);
midTurnLane = roadStruct(5);
speedLimit = roadStruct(6);
curvature1 = roadStruct(8);
curvature2 = roadStruct(9);



end

