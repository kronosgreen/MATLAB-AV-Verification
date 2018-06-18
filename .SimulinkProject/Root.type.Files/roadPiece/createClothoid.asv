function [curvePoints, forwardPaths, reversePaths, inPoint, facing, curvature] = createClothoid(inPoint, facing, length, lanes, bidirectional, midTurnLane, startCurvature, endCurvature)
%CREATECLOTHOID Creates a clothoid line given a starting point, start and
%end curvature, and a facing direction. Returns points for driving paths as
%well

% Create empty matrices for lane paths
forwardPaths = zeros(lanes, 18);
% flip correction for when a left turning road has its points
% flipped, used only for paths on road

fc = (curvature < 0);

%
% Set up Clothoid Curve based on given curvature
%

% First Point

% End Curvature
k_c = abs(endCurvature - startCurvature) / 3;

% End circular arc (Radius) - 1 / curvature
R_c = 1 / k_c;

% Arc length or length of road
s_c = length / 3;

% a - scaling ratio to improve robustness while maintaining geometric
% equivalence to Euler curve
a = sqrt( s_c / (pi * k_c) );

% theta - radians by which the line turned
theta = (s_c/a)^2;

% set up first point of the curve at a third of the road length
x1 = a * fresnels(s_c/a);
y1 = a * fresnelc(s_c/a);

% set up lane paths up to this point & establish reverse paths 
if bidirectional
    reversePaths = zeros(lanes, 18);
    for i=1:lanes
        startPoint = [-(fc*2-1)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0 0];
        firstCurvePoint = 2 * forwardVec + [x1 y1 0] + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        forwardPaths(i,1:9) = [startPoint, startPoint + 2 * forwardVec, firstCurvePoint];

        startPoint = [(fc*2-1)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0 0];
        firstCurvePoint = 2 * forwardVec + [x1 y1 0] + [cos(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        reversePaths(i,10:18) = [firstCurvePoint, startPoint + 2 * forwardVec, startPoint];
    end
else
    reversePaths = 0;
    for i=1:lanes
        startPoint = [(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0 0];
        firstCurvePoint = 2 * forwardVec + [x1 y1 0] + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
        forwardPaths(i,1:9) = [startPoint, startPoint + 2 * forwardVec, firstCurvePoint];
    end
end

% Second Point

% Change in Curvature
k_c = 2 * abs(endCurvature - startCurvature) / 3;

% End circular arc (Radius) - 1 / curvature
R_c = 1 / k_c;

% Arc length or length of road
s_c = 2 * length / 3;

% a - scaling ratio to improve robustness while maintaining geometric
% equivalence to Euler curve
a = sqrt( s_c / (pi * k_c) );

% theta - radians by which the line turned
theta = (s_c/a)^2;

% set up mid-point at half the road length
x2 = a * fresnels(s_c/a);
y2 = a * fresnelc(s_c/a);

% add second curve point to lane paths
if bidirectional
    for i=1:lanes
        forwardPaths(i,10:12) = 2 * forwardVec + [x2 y2 0] + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        reversePaths(i,7:9) = 2 * forwardVec + [x2 y2 0] + [cos(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
    end
else
    for i=1:lanes
        forwardPaths(i,10:12) = 2 * forwardVec + [x2 y2 0] + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(-theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
    end
end

%Third Point

% End Curvature
k_c = abs(endCurvature - startCurvature);

% End circular arc (Radius) - 1 / curvature
R_c = 1 / k_c;

% Arc length or length of road
s_c = length;

% a - scaling ratio to improve robustness while maintaining geometric
% equivalence to Euler curve
a = sqrt( s_c / (pi * (endCurvature - startCurvature)) );

% theta - radians by which the line turned
theta = (s_c/a)^2;

% set up final point of curve at full length
x3 = a * fresnels(s_c/a);
y3 = a * fresnelc(s_c/a);

% add last curve points to the lane paths
curveFacing = [cos(pi/2 - theta) sin(pi/2 - theta) 0];
if bidirectional
    for i=1:lanes
        lastCurvePoint = 2 * forwardVec + [x3 y3 0] + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        forwardPaths(i,13:18) = [lastCurvePoint, lastCurvePoint + 2 * curveFacing];

        lastCurvePoint = 2 * forwardVec + [x3 y3 0] + [cos(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) sin(fc * pi +pi-theta)*(LANE_WIDTH * (1/2 + midTurnLane/2 + (i-1))) 0];
        reversePaths(i,1:6) = [lastCurvePoint + 2 * curveFacing, lastCurvePoint];
    end
else
    for i=1:lanes
        lastCurvePoint = 2 * forwardVec + [x3 y3 0] + [cos(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) sin(fc * pi -theta)*(LANE_WIDTH * (1/2 + (i-1) - lanes/2)) 0];
        forwardPaths(i,13:18) = [lastCurvePoint, lastCurvePoint + 2 * curveFacing];
    end
end

% Rotate path points and road points to orient to facing
% Flip over y axis if necessary (negative curvature)
% Add inPoint to place it in the correct location
R = [cos(facing - pi/2) sin(facing - pi/2); -sin(facing - pi/2) cos(facing - pi/2)];

if curvature >= 0
    curvePoints = [0 0 0; [x1 y1]*R 0; [x2 y2]*R 0; [x3 y3]*R 0] + inPoint + 2 * dirVec;
    for i=1:lanes
        for n=1:3:16
            forwardPaths(i,n:n+2) = [[forwardPaths(i,n) forwardPaths(i,n+1)]*R forwardPaths(i,n+2)] + inPoint;
            if bidirectional
                reversePaths(i,n:n+2) = [[reversePaths(i,n) reversePaths(i,n+1)]*R reversePaths(i,n+2)] + inPoint;
            end
        end
    end
else

    curvePoints = [0 0 0; [-x1 y1]*R 0; [-x2 y2]*R 0; [-x3 y3]*R 0] + inPoint + 2 * dirVec;
    theta = -1 * theta;
    for i=1:lanes
        for n=1:3:16
            if bidirectional
                reversePaths(i,n:n+2) = [[-reversePaths(i,n) reversePaths(i,n+1)]*R reversePaths(i,n+2)] + inPoint;
                forwardPaths(i,n:n+2) = [[-forwardPaths(i,n) forwardPaths(i,n+1)]*R forwardPaths(i,n+2)] + inPoint;
            else
                if n <= 4
                    % don't flip first two points, for some reason
                    % get flipped twice (one-way road)
                    forwardPaths(i,n:n+2) = [ [forwardPaths(i,n) forwardPaths(i,n+1)]*R forwardPaths(i,n+2)] + inPoint;
                else
                    forwardPaths(i,n:n+2) = [ [-forwardPaths(i,n) forwardPaths(i,n+1)]*R forwardPaths(i,n+2)] + inPoint;
                end
            end
        end
    end

end



end

