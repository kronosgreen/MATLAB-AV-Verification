function [facing, inPoint, pieces] = fourWayIntersection(drScn, inPoint, facing, pieces, roadStruct)
%FOURWAYINTERSECTION Creates a four-way intersection where each road has
%its own unique properties such as lanes and directions. One of the
%outgoing roads is selected to continue with the scenario generation. 

disp("Starting Four-Way Intersection");
%% Setting Parameters

% Get lane width
global LANE_WIDTH;

% Get size of transition piece
global TRANSITION_PIECE_LENGTH;

% Set up inpoint where transition piece would put it
oldInPoint = inPoint;
if size(pieces,1) >= 2, inPoint = inPoint + TRANSITION_PIECE_LENGTH * [cos(facing) sin(facing) 0]; end

% Create Direction Vector
dirVec = [cos(facing) sin(facing) 0];

% Get variables from road struct
% [roadPiece roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2]
length = str2double(roadStruct(2));
lanes = char(roadStruct(3));
bidirectional = str2double(roadStruct(4));
speedLimit = str2double(roadStruct(6));
interPattern = char(roadStruct(7));
pedPathWays = roadStruct(10);
showMarkers = str2double(roadStruct(12));

% prepare parameters
if pieces(end).bidirectional ~= bidirectional
    bidirectional = ~bidirectional;
end
for k=1:4-size(interPattern,2)
    interPattern = ['0' interPattern];
end

% t,b,l,r = Top, Bottom, Left, Right

% Get Lanes 
lLanes = str2double(lanes(1));
tLanes = str2double(lanes(2));
rLanes = str2double(lanes(3));
bLanes = str2double(lanes(4));
contLanes = [lLanes tLanes rLanes];

% Get Intersection pattern
% 0 - bidirectional
% 1 - one way in
% 2 - one way out
lDirection = str2double(interPattern(1));
tDirection = str2double(interPattern(2));
rDirection = str2double(interPattern(3));
% Continue direction - where the scenario will continue generating from
% 1 - left
% 2 - up
% 3 - right
contDirection = str2double(interPattern(4));

% Calculate Road Widths
lWidth = ((lDirection == 0) + 1) * lLanes * LANE_WIDTH;
tWidth = ((tDirection == 0) + 1) * tLanes * LANE_WIDTH;
rWidth = ((rDirection == 0) + 1) * rLanes * LANE_WIDTH;
bWidth = (double(bidirectional > 0) + 1) * bLanes * LANE_WIDTH;
contWidths = [lWidth tWidth rWidth];

%% Calculating position of the four roads

% lengths that will be used to set everything in the proper place
% The square connecting all of the roads has a width of 
% max([tWidth, bWidth]) + lengthBeta & a length of max([lWidth, rWidth]) +
% lengthAlpha
%  
%   Ex. If the top width > bottom & right width > left:
%
%         Lb            tWidth
%        ______|_____________________|___      _
%   Lb   |                           |
%     ___|                           |
%        |                           |
%        |                           |
% lWidth |                           | rWidth
%        |       Intersection        |            centerWidth
%     ___|           Space           |
%        |                           |
%  La+Lb |                           |___ 
%        |                           |
%        |___________________________|  La     _
%                 |             | 
%          La+Lb       bWidth     La
%

lengthAlpha = abs(rWidth - lWidth)/2;
lengthBeta = abs(tWidth - bWidth)/2;

centerWidth = max([tWidth bWidth]) + lengthBeta;
centerHeight = max([lWidth rWidth]) + lengthAlpha;

% Start - End Points
% Setting up the points for each road going into the intersection
bRoadPoints = [inPoint; (inPoint + (length/2 + 4) * [cos(facing) sin(facing) 0])];
tRoadPoints = [bRoadPoints(2,:) + (centerHeight * [cos(facing) sin(facing) 0]); 0 0 0];
tRoadPoints(2,:) = tRoadPoints(1,:) + (length/2 + 4) * [cos(facing) sin(facing) 0];

% sets where the left and right roads going into it will line up since they
% will directly face each other as the top and bottom roads do
if bWidth > tWidth
    centerY = bRoadPoints(2,:) + max([lWidth rWidth])/2 * [cos(facing) sin(facing) 0];
else
    centerY = bRoadPoints(2,:) + (max([lWidth rWidth])/2 + lengthAlpha) * [cos(facing) sin(facing) 0];
end

if rWidth > lWidth
    lRoadPoints = centerY + max([tWidth bWidth])/2 * [cos(facing+pi/2) sin(facing+pi/2) 0];
    rRoadPoints = centerY + (max([tWidth bWidth])/2 + lengthBeta) * [cos(facing-pi/2) sin(facing-pi/2) 0];
else
    lRoadPoints = centerY + (max([tWidth bWidth])/2 + lengthBeta) * [cos(facing+pi/2) sin(facing+pi/2) 0];
    rRoadPoints = centerY + max([tWidth bWidth])/2 * [cos(facing-pi/2) sin(facing-pi/2) 0];
end

lRoadPoints = vertcat(lRoadPoints, lRoadPoints(1,:) + (length/2 + 4) * [cos(facing+pi/2) sin(facing+pi/2) 0]);
rRoadPoints = vertcat(rRoadPoints, rRoadPoints(1,:) + (length/2 + 4) * [cos(facing-pi/2) sin(facing-pi/2) 0]);

% Set up the points for the center space. Will be a rectangle of sides
% max(L,R) + lengthAlpha and max(T,B) + lengthBeta

centerRoadPoints = lRoadPoints(1,:);
% aligns the point with the center of the space horizontally
centerRoadPoints = centerRoadPoints + centerWidth/2 * [cos(facing-pi/2) sin(facing-pi/2) 0];
% moves the point to the start of the space at the bottom
if bWidth > tWidth
    centerRoadPoints = centerRoadPoints + max([rWidth lWidth])/2 * [cos(facing+pi) sin(facing+pi) 0];
else
    centerRoadPoints = centerRoadPoints + (max([rWidth lWidth])/2 + lengthAlpha) * [cos(facing+pi) sin(facing+pi) 0];
end
% add the end point at the top of the center space
centerRoadPoints = [centerRoadPoints; centerRoadPoints + centerHeight * [cos(facing) sin(facing) 0]];

%% Check Validity

% Calculate New InPoint based on direction that scenario will continue from
endPoints = [lRoadPoints(2,:); tRoadPoints(2,:); rRoadPoints(2,:)];
newInPoint = endPoints(contDirection,:);
intersFacing = [pi/2 0 -pi/2];
newFacing = facing + intersFacing(contDirection);

fwdVec = [cos(facing) sin(facing)];
rghtVec = [cos(facing-pi/2) sin(facing-pi/2)];

corners = [lRoadPoints(2,1:2)+lWidth/2 * fwdVec; lRoadPoints(2,1:2)-lWidth/2 * fwdVec; ...
    tRoadPoints(2,1:2) + tWidth/2 * rghtVec; tRoadPoints(2,1:2) - tWidth/2 * rghtVec; ...
    rRoadPoints(2,1:2) + rWidth/2 * fwdVec; rRoadPoints(2,1:2) - rWidth/2 * fwdVec; ...
    bRoadPoints(1,1:2) + bWidth/2 * rghtVec; bRoadPoints(1,1:2) - bWidth/2 * rghtVec];

botLeftCorner = [min(corners(:,1).') min(corners(:,2).') 0];

topRightCorner = [max(corners(:,1).') max(corners(:,2).') 0];

if ~checkAvailability(pieces, botLeftCorner, topRightCorner, [newInPoint-[length,length,0];newInPoint], newFacing, length)
    disp("@ Four-Way Intersection : Could Not Place Piece");
    inPoint = oldInPoint;
    return
end
%% Start Building Road into Scene
        %             1           2        3        4             5         6
   %     newRoad = [roadType, roadLength, lanes, bidirectional, midLane, speedLimit, ...
                    ... %   7                8        9             10          11        12 
        %            intersectionPattern, curvature1, curvature2, pedPathWays, outlets, showMarkers];
leftAssertion = [2 length/2 lLanes int8(lDirection == 0) 0 speedLimit lDirection 0 0 "0" "0" showMarkers];
topAssertion = [2 length/2 tLanes int8(tDirection == 0) 0 speedLimit tDirection 0 0 "0" "0" showMarkers];
rightAssertion = [2 length/2 rLanes int8(rDirection == 0) 0 speedLimit rDirection 0 0 "0" "0" showMarkers];
bottomAssertion = [2 length/2 bLanes int8(bidirectional) 0 speedLimit 0 0 0 "0" "0" showMarkers];

% Create Transition Piece
if size(pieces,1) >= 2
    [inPoint, facing, pieces] = laneSizeChange(drScn, oldInPoint, facing, ...
        bWidth, pieces, dirVec, bottomAssertion);
end

% Create roadPoints
roadPoints = [lRoadPoints; tRoadPoints; rRoadPoints; bRoadPoints];

% Go through all of the points and flip if the direction is the other way 
if lDirection == 1, lRoadPoints = flipud(lRoadPoints); end
if tDirection == 1, tRoadPoints = flipud(tRoadPoints); end
if rDirection == 1, rRoadPoints = flipud(rRoadPoints); end

% Create assertions that will make the four roads going into the intersection
% Based on the information that will create the approprite multi-lane road
%
% Base: [roadPiece roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2];
[facingLeft, inPointLeft, leftPiece] = multiLaneRoad(drScn, lRoadPoints(1,:), mod(facing+pi/2-pi*(lDirection==1),2*pi), pieces(1,1), leftAssertion);

[facingTop, inPointTop, topPiece] = multiLaneRoad(drScn, tRoadPoints(1,:), mod(facing-pi*(tDirection==1), 2*pi), pieces(1,1), topAssertion);

[facingRight, inPointRight, rightPiece] = multiLaneRoad(drScn, rRoadPoints(1,:), mod(facing-pi/2-pi*(rDirection==1), 2*pi), pieces(1,1), rightAssertion);

[facingBottom, inPointBottom, bottomPiece] = multiLaneRoad(drScn, inPoint, facing, pieces(1,1), bottomAssertion);

% Create Center Road Area
try
    % Making the width a little bit smaller to avoid an intersection with
    % the right or left roads keeping them from being placed
    road(drScn, centerRoadPoints, centerWidth - 0.01);
    % plot center space
    plot(centerRoadPoints(:,1),centerRoadPoints(:,2));
    cenBorder = centerRoadPoints(1,1:2) + centerWidth/2 * [cos(facing-pi/2) sin(facing-pi/2)];
    cenBorder = [cenBorder; centerRoadPoints(1,1:2)  + centerWidth/2 * [cos(facing+pi/2) sin(facing+pi/2)]];
    cenBorder = [cenBorder; cenBorder(2,:) + centerHeight * [cos(facing) sin(facing)]];
    cenBorder = [cenBorder; cenBorder(3,:) + centerWidth * [cos(facing-pi/2) sin(facing-pi/2)]];
    cenBorder = [cenBorder; cenBorder(1,:)];
    plot(cenBorder(:,1),cenBorder(:,2));
catch ME
   disp("Error placing center road piece: " + ME.identifier);
end

%% Calculate Turn Lanes for Each Road

% Lanes will be set to go in specific directions, allowing turns or not, in
% a logical manner. Setting them up will start with the forward road, then
% the left road, then the right road, as left turning lanes are more
% important than right, and lanes will almost always continue forward if
% there is a lane there.

% Lane Type - Code
% -2 : Left Only
% -1 : Left & Straight
%  0 : Straight
%  1 : Right & Straight
%  2 : Right Only
% Extra Lane Codes
%  3 : Left, Straight, & Right
% -4 : Merge Straight to the Left
%  4 : Merge Straight to the Right

bLanePattern = zeros(1,bLanes);
availableLanes = bLanes;

% Cars can drive going through the top road in the intersection
if tDirection ~= 1
    % Lanes will all continue to the top since more are available than
    % starting lanes
    if tLanes >= availableLanes
        % Set lanes that can go left
        if lDirection ~= 1
            bLanePattern(1,1) = -1;
        end
        % Set lanes that can go right
        if rDirection ~= 1
            if bLanePattern(1,bLanes) == 0 && bLanes ~= 1
                bLanePattern(1,bLanes) = 1;
            else
                bLanePattern(1,bLanes) = 3;
            end
        end
    % There are more lanes to start than there are at the top which means
    % the excess will go left and/or right
    else
        % Don't count lanes going forward
        availableLanes = availableLanes - tLanes;
        % Set lanes to go left
        if lDirection ~= 1
            numLeftTurnLanes = min([2 availableLanes lLanes]);
            bLanePattern(1,1:numLeftTurnLanes) = -2;
            availableLanes = availableLanes - numLeftTurnLanes;
        end
        % Set lanes to go right
        if rDirection ~= 1
            if availableLanes > 0
               numRightTurnLanes = min([2 availableLanes rLanes]);
               bLanePattern(1,(bLanes-numRightTurnLanes+1):bLanes) = 2;
               availableLanes = availableLanes - numRightTurnLanes;
            else
                if bLanePattern(1,bLanes) == 0 && bLanes ~= 1
                    bLanePattern(1,bLanes) = 1;
                else
                    bLanePattern(1,bLanes) = 3;
                end
            end
        end
        
    end

else
    % No available lanes going up, have to distribute all going left 
    % and right (-2 & 2)
    contLaneNum = lLanes * (lDirection ~= 1) + rLanes * (rDirection ~= 1);
    if availableLanes <= contLaneNum
        if lDirection ~= 1
            % Enough lanes in left road to have a lane turning left into
            % each of them
            if availableLanes > lLanes
                bLanePattern(1,1:lLanes) = -2;
                availableLanes = availableLanes - lLanes;
            % More lanes in left road than there are to start, so set all
            % but one to left turning lanes since it gets priority
            else
                bLanePattern(1,1:bLanes-1) = -2;
                availableLanes = 1;
            end
        end
        if rDirection ~= 1
            % Enough lanes in right road to set all remaining lanes to
            % right turn
            if rLanes >= availableLanes
                bLanePattern(1,bLanes-availableLanes+1:bLanes) = 2;
                availableLanes = 0;
            % Lanes will be left over and have to merge into turning lanes
            else
                bLanePattern(1,bLanes-rLanes+1:bLanes) = 2;
                
            end
        end

    else
    % More lanes than there are lanes to continue, some will have to merge

    end

end

%% Set up lane paths (Basic)
%
% Setting up paths for vehicles to take. Made by connecting the appropriate
% lane path from the starting road at the bottom of the intersection to the
% appropriate lane path in the continuing one. 
%
switch contDirection
    case 1
        %
        % Go Left
        %
        % Create Reverse Paths as right turn from left side
        if lDirection ~= 0 || ~bidirectional
            reversePaths = 0;
        else
            leftRoadRightTurn = lLanes - rLanes*(rDirection~=1);
            if leftRoadRightTurn <= 0, leftRoadRightTurn = 1; end
            minLanes = min([2 leftRoadRightTurn bLanes]);
            reversePaths = [leftPiece(2).reverseDrivingPaths(lLanes-minLanes+1:lLanes,:) bottomPiece(2).reverseDrivingPaths(bLanes-minLanes+1:bLanes,:)];
        end
        % Create forward paths
        minLanes = min([bottomPiece(2).lanes leftPiece(2).lanes 2]);
        forwardPaths = [bottomPiece(2).forwardDrivingPaths(1:minLanes,:) leftPiece(2).forwardDrivingPaths(1:minLanes,:)];
    case 2
        %
        % Go Straight
        %
        % Create reverse paths coming back across from the top road
        if tDirection ~= 0 || ~bidirectional
            reversePaths = 0;
        else
            minLanes = min([tLanes bLanes]);
            reversePaths = [topPiece(2).reverseDrivingPaths(1:minLanes,:) bottomPiece(2).reverseDrivingPaths(1:minLanes,:)];
        end
        % Create forward paths
        minLanes = min([bottomPiece(2).lanes topPiece(2).lanes]);
        forwardPaths = [bottomPiece(2).forwardDrivingPaths(1:minLanes,:) topPiece(2).forwardDrivingPaths(1:minLanes,:)];
    case 3
        %
        % Go Right
        %
        % Create reverse paths as left turns from right side
        if rDirection ~= 0 || ~bidirectional
            reversePaths = 0;
        else
            rightRoadLeftTurn = rLanes - lLanes*(lDirection~=1);
            if rightRoadLeftTurn <= 0, rightRoadLeftTurn = 1; end
            minLanes = min([2 rightRoadLeftTurn bLanes]);
            reversePaths = [rightPiece(2).reverseDrivingPaths(1:minLanes,:) bottomPiece(2).reverseDrivingPaths(1:minLanes,:)];
        end
        % Create forward Paths
        minLanes = min([2 bottomPiece(2).lanes rightPiece(2).lanes]);
        forwardPaths = [bottomPiece(2).forwardDrivingPaths(bLanes-minLanes+1:bLanes,:) rightPiece(2).forwardDrivingPaths(rLanes-minLanes+1:rLanes,:)];
end

%% Set up continue spot & Piece

rPiece.type = 2;
rPiece.lineType = 4;
rPiece.roadPoints = roadPoints;
rPiece.range = [botLeftCorner; topRightCorner];
rPiece.facing = facing;
rPiece.length = length;
rPiece.curvature1 = 0;
rPiece.curvature2 = 0;
rPiece.midLane = 0;
rPiece.bidirectional = interPattern(contDirection) == '0';
rPiece.lanes = contLanes(contDirection);
rPiece.forwardDrivingPaths = forwardPaths;
rPiece.reverseDrivingPaths = reversePaths;
rPiece.occupiedLanes = zeros(1, (size(reversePaths,1) * bidirectional * (interPattern(contDirection) == '0')) + size(forwardPaths, 1));
rPiece.width = contWidths(contDirection);
rPiece.weather = 0;
rPiece.roadConditions = 0;
rPiece.speedLimit = speedLimit;
rPiece.pedPathWays = pedPathWays;
rPiece.showMarkers = showMarkers;

pieces = [pieces; rPiece];

inPoint = newInPoint;
facing = newFacing;

end