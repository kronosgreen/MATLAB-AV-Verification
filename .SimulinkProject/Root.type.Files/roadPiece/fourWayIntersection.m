function [pieces, facing, inPoint] = fourWayIntersection(pieces, facing, inPoint, roadStruct)
%FOURWAYINTERSECTION Creates a four-way intersection where each road

% Get lane width
global LANE_WIDTH;

% Get variables from road struct
% [roadPiece roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2]
length = roadStruct(2);
lanes = char(roadStruct(3));
speedLimit = roadStruct(6);
interPattern = char(roadStruct(7));

% t,b,l,r = Top, Bottom, Left, Right
% Get Lanes 
tLanes = str2num(lanes(1));
rLanes = str2num(lanes(2));
bLanes = str2num(lanes(3));
lLanes = str2num(lanes(4));

% Get Intersection pattern
tDirection = str2double(interPattern(1));
rDirection = str2double(interPattern(2));
bDirection = str2double(interPattern(3));
lDirection = str2double(interPattern(4));

% Calculate Road Widths
tWidth = ((tDirection == 0) + 1) * tLanes * LANE_WIDTH;
rWidth = ((rDirection == 0) + 1) * rLanes * LANE_WIDTH;
bWidth = ((bDirection == 0) + 1) * bLanes * LANE_WIDTH;
lWidth = ((lDirection == 0) + 1) * lLanes * LANE_WIDTH;

% lengths that will be used to set everything in the proper place
% The square connecting all of the roads has a width of 
% max([tWidth, bWidth]) + lengthBeta & a length of max([lWidth, rWidth]) +
% lengthAlpha
%  
%   Ex. If the top width > bottom & right width > left:
%
%         Lb            tWidth
%        ______|_____________________|___
%   Lb   |                           |
%     ___|                           |
%        |                           |
%        |                           |
% lWidth |                           | rWidth
%        |       Intersection        |
%     ___|           Space           |
%        |                           |
%  La+Lb |                           |___
%        |                           |
%        |___________________________|  La
%                 |             | 
%          La+Lb       bWidth     La
%

lengthAlpha = abs(rWidth - lWidth)/2;
lengthBeta = abs(tWidth - bWidth)/2;

%[facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, facing, pieces, roadStruct)


end