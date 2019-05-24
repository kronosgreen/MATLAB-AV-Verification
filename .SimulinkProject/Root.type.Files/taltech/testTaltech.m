%
%   Taltech Grabbing Roads
%

%% LOAD
% Load All Roads
roads = cell(41);
for i = 0 : 41
    roads{i+1} = struct2cell(load("road_" + i + ".mat"));
end

%%  SCATTER PLOT

roadsInWay = [];

hold on
for i=1:42
    if max(roads{i}{1}(:,2)) > 59.396, continue; end
    if min(roads{i}{1}(:,2)) < 59.395, continue; end
    if max(roads{i}{1}(:,1)) > 24.6721, continue; end
    roadsInWay = [roadsInWay i];
    scatter(roads{i}{1}(:,1), roads{i}{1}(:,2))
end
hold off

%% Create Road

roadPoints = [];

for i = 1:length(roadsInWay)
    roadPoints = [roadPoints; 50000 * roads{roadsInWay(i)}{1}];
end

newOrigin = roadPoints(1,:);
for i = 1:length(roadPoints)
    roadPoints(i,:) = roadPoints(i,:) - newOrigin;
end

plot(roadPoints(:,1), roadPoints(:,2))

scenario = drivingScenario();

laneWidth = 3;
road(scenario, roadPoints, laneWidth * 3)

%% Create Actors

pedStart = [roadPoints(20,1) roadPoints(20,2)] + 4*[cos(pi/4) sin(pi/4)];
pedEnd = [roadPoints(20,1) roadPoints(20,2)] - 4*[cos(pi/4) sin(pi/4)];

for i = 1 : 7
   offsetAngle = rand() * 2*pi;
   offset = [cos(offsetAngle) sin(offsetAngle)];
   ped = actor(scenario, 'Length', 0.2, 'Width', 0.2, 'Height', 1.7);
   trajectory(ped, [pedStart+offset; pedEnd+offset; pedEnd], [offsetAngle; offsetAngle; 0.001]);
end


%% Create Ego Vehicle

% Initialize Vehicle in scenario w/ basic dimensions of a sedan
egoCar = vehicle(scenario, 'Length', 5, 'Width', 2, 'Height', 1.6);

% Set Trajectory to main road points w/ speed of 25 mph (param in mps)
trajectory(egoCar, roadPoints, ones(length(roadPoints),1) * 10);

radarSensor = radarDetectionGenerator( ...
    'SensorIndex', 1, ...
    'UpdateInterval', 0.1, ...
    'SensorLocation', [egoCar.Wheelbase+egoCar.FrontOverhang 0], ...
    'Height', 0.2, ...
    'FieldOfView', [20 5], ...
    'MaxRange', 150, ...
    'AzimuthResolution', 4, ...
    'RangeResolution', 2.5, ...
    'ActorProfiles', actorProfiles(scenario));

%% Run Scenario

hFigure = figure;
hFigure.Position(3) = 900;

hPanel1 = uipanel(hFigure,'Units','Normalized','Position',[0 1/4 1/2 3/4],'Title','Scenario Plot');
hPanel2 = uipanel(hFigure,'Units','Normalized','Position',[0 0 1/2 1/4],'Title','Chase Plot');
hPanel3 = uipanel(hFigure,'Units','Normalized','Position',[1/2 0 1/2 1],'Title','Bird''s-Eye Plot');

hAxes1 = axes('Parent',hPanel1);
hAxes2 = axes('Parent',hPanel2);
hAxes3 = axes('Parent',hPanel3);

plot(scenario, 'Parent', hAxes1, 'Waypoints', 'off', 'Centerline','off');

chasePlot(egoCar, 'Parent', hAxes2,'Centerline','off');

egoCarBEP = birdsEyePlot('Parent',hAxes3,'XLimits',[-200 200],'YLimits',[-240 240]);
fastTrackPlotter = trackPlotter(egoCarBEP,'MarkerEdgeColor','red','DisplayName','target','VelocityScaling',.5);
egoTrackPlotter = trackPlotter(egoCarBEP,'MarkerEdgeColor','blue','DisplayName','ego','VelocityScaling',.5);
egoLanePlotter = laneBoundaryPlotter(egoCarBEP);
plotTrack(egoTrackPlotter, [0 0]);
egoOutlinePlotter = outlinePlotter(egoCarBEP);

while advance(scenario)
    %t = targetPoses(egoCar);
    %plotTrack(fastTrackPlotter, t.Position, t.Velocity);
    pause(0.001)
    rbs = roadBoundaries(egoCar);
    plotLaneBoundary(egoLanePlotter, rbs);
    [position, yaw, length, width, originOffset, color] = targetOutlines(egoCar);
    plotOutline(egoOutlinePlotter, position, yaw, length, width, 'OriginOffset', originOffset, 'Color', color);
end
