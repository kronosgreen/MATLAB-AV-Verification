function [pieces, facing, inPoint] = fourWayIntersection(pieces, facing, inPoint, roadStruct)
%FOURWAYINTERSECTION Summary of this function goes here
%   Detailed explanation goes here

% Get lane width
global LANE_WIDTH;

% Get variables from road struct
% [roadPiece roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2]
length = roadStruct(2);
lanes = roadStruct(3);
bidirectional = roadStruct(4);
speedLimit = roadStruct(6);
% Intersection pattern

end

