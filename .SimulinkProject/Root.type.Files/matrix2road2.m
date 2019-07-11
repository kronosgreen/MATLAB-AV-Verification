%{
    str2road2 function
        convert string of road piece characters by attaching them one by
        one to a road inside scenario

%}
function [drScn, pieces] = matrix2road2(drScn, roadMatrix)

    close all
    
    global fid;
    
    inPoint = [0 0 0];
    facing = pi/2;
    pieces = [];
    
    rPiece.type = 0;
    rPiece.lineType = 0;
    rPiece.roadPoints = [0 0 0; 0 0 0];
    rPiece.range = [0 0 0; 0 0 0];
    rPiece.facing = facing;
    rPiece.length = 0;
    rPiece.curvature1 = 0;
    rPiece.curvature2 = 0;
    rPiece.midTurnLane = 0;
    rPiece.bidirectional = 0;
    rPiece.lanes = 0;
    rPiece.forwardDrivingPaths = 0;
    rPiece.reverseDrivingPaths = 0;
    rPiece.occupiedLanes = 0; 
    rPiece.width = 0;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = 0;
    rPiece.pedPathWays = 0;
    rPiece.showMarkers = 0;
    
    pieces = rPiece;
    
    % ROAD MATRIX
    %
    %   Assertion : [roadType roadLength lanes bidirectional midLane speedLimit intersectionPattern curvature1 curvature2]
    for i = 1:size(roadMatrix,1)
        
        disp("Road #" + i);
        
        % for data collecting
        switch str2double(roadMatrix(i,1))
            
            case 1
                % multiLaneRoad(drScn, inPoint, facing, pieces, lanes, length, bidirectional, midTurnLane, speedLimit, roadSlickness, curvature)
                % try
                [facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, facing, pieces, roadMatrix(i, :));
                % catch
                %    fprintf(fid,"error: [%d %d %d %d %d %d %d %d %d],",roadMatrix(i,1), roadMatrix(i,2), ...
                %        roadMatrix(i,3),roadMatrix(i,4),roadMatrix(i,5), roadMatrix(i,6), roadMatrix(i,7), ...
                %        roadMatrix(i,8), roadMatrix(i,9));
                % end
            case 2
                % 4-way intersection
                [facing, inPoint, pieces] = fourWayIntersection(drScn, inPoint, facing, pieces, roadMatrix(i, :));
            case 3
                % 3-way Intersection
                [facing, inPoint, pieces] = threeWayIntersection(drScn, inPoint, facing, pieces, roadMatrix(i, :));
            case 4
                % Single Pedestrian Crosswalk
                [facing, inPoint, pieces] = singlePedestrianCrosswalk(drScn, inPoint, facing, pieces, roadMatrix(i, :));
            case 5
                % Side Lot Enter
                [facing, inPoint, pieces] = sideLotEnter(drScn, inPoint, facing, pieces, roadMatrix(i, :));
                
        end % end switch
        
    end % end for loop
   
    
end % end function