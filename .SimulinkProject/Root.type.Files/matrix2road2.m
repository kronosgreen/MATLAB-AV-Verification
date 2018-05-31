%{
    str2road2 function
        convert string of road piece characters by attaching them one by
        one to a road inside scenario

%}
function [drScn, pieces, ep] = matrix2road2(drScn, roadMatrix)

    close all
    
    inPoint = [0 0 0];
    facing = pi/2;
    ep = [];
    pieces = [];
    
    rPiece.type = 0;
    rPiece.roadPoints = [0 0 0; 0 0 0];
    rPiece.range = [0 0 0; 0 0 0];
    rPiece.facing = facing;
    rPiece.length = 0;
    rPiece.curvature = 0;
    rPiece.midTurnLane = 0;
    rPiece.bidirectional = 0;
    rPiece.lanes = 0;
    rPiece.forwardDrivingPaths = 0;
    rPiece.reverseDrivingPaths = 0;
    rPiece.occupiedLanes = 0; 
    rPiece.width = 0;
    rPiece.egoLane = 0;
    rPiece.weather = 0;
    rPiece.roadConditions = 0;
    rPiece.speedLimit = 0;
    rPiece.slickness = 0;
    
    pieces = rPiece;
    
    % ROAD MATRIX
    %
    %   [roadPiece roadLength lanes egoLane bidirectional speedLimit roadSlickness]
    for i = 1:size(roadMatrix,1)
        if checkAvailability(pieces,roadMatrix(i,:),inPoint, facing)
            switch roadMatrix(i,1)
                case 1
                    %Multi-lane Road (drScn, inPoint, ep, facing, pieces, lanes, egoLane, length, bidirectional, midTurnLane, curvature)
                    [ep, facing, inPoint, pieces] = multiLaneRoad(drScn, inPoint, ep, facing, pieces, roadMatrix(i, 3), roadMatrix(i, 4), roadMatrix(i, 2), roadMatrix(i, 5), roadMatrix(i, 6), roadMatrix(i,7), roadMatrix(i,8), roadMatrix(i,9));
                case 2
                    %roundabout
                    
                case 3
                    %intersection
                    
                case 4
                    %fork
                    
                case 5
                    %idk
            end
        end
    end
   
end