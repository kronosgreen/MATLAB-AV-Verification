%{
    str2road2 function
        convert string of road piece characters by attaching them one by
        one to a road inside scenario

%}
function [drScn, pieces] = matrix2road2(drScn, roadMatrix)

    close all
    
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
    
    pieces = rPiece;
    
    % ROAD MATRIX
    %
    %   [roadPiece roadLength lanes egoLane bidirectional speedLimit roadSlickness]
    for i = 1:size(roadMatrix,1)
        switch roadMatrix(i,1)
            case 1
                % multiLaneRoad(drScn, inPoint, facing, pieces, lanes, length, bidirectional, midTurnLane, speedLimit, roadSlickness, curvature)
                [facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, facing, pieces, roadMatrix(i, :));
            case 2
                % 4-way intersection
                [facing, inPoint, pieces] = fourWayIntersection(drScn, inPoint, facing, pieces, roadMatrix(i, :));
        end % end switch
        
    end % end for loop
   
end % end function