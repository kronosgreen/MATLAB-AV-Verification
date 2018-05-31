function varargout = AVVerScenAuth(sceneStats, fileName, toDisplay)
% Edited from helperScenarioAuthoring from ACCTestBench example
% "
% helperScenarioAuthoring Author a curved road scenario
%
%   This is a helper function for example purposes and may be removed or
%   modified in the future.
%
% helperScenarioAuthoring(radius, fileName, toDisplay) creates driving
% scenario that contains a road with radius of curvature, radius, and saves
% it to the file defined by fileName. You can set the flag toDisplay to
% true in order to visualize the scenario.
%
% scenario = helperScenarioAuthoring(...), in addition, allows you to
% output the driving scenario object.
%
%   Inputs:                                                     Defaults
%       R         - Radius of curvature (in meters)             760
%       fileName  - the fileName used for saving the scenario   scenario1
%       toDisplay - a logical flag. True for scenario display   false
%
%   Output:
%       scenario  - the generated driving scenario
%
% Copyright 2017 The MathWorks, Inc.
% "

%% Inputs and defaults
if nargin < 3
    toDisplay = false;
    if nargin < 2
        fileName = 'scenario1';
    end
end
validateattributes(fileName, {'char','string'}, {}, mfilename, 'fileName')
validateattributes(toDisplay, {'numeric','logical'}, {'binary', 'scalar'}, mfilename, 'toDisplay')


%% Define a scenario
% Set Simulation Run Parameters

% Num of road pieces to place in scenario
LEN_ROAD = sceneStats(1);
% Num of actors to place in scenario (cars, pedestrians, etc.)
NUM_ACTORS = sceneStats(2);
% Rng Seed
RNG_SEED = sceneStats(3);

[roadMatrix, actorMatrix] = getRandMatrix(LEN_ROAD, NUM_ACTORS, RNG_SEED);
scenario = matrix2scen(roadMatrix, actorMatrix);
scenario.SampleTime = 0.1;

%% Define Scenario Plots 
if toDisplay
    hFigure = figure;
    hAxes = axes(hFigure);
    plot(scenario,'Parent',hAxes,'Centerline','on','Waypoints','off','RoadCenters','off');
end

%% Save the Scenario to a File
vehiclePoses = record(scenario);

% Obtain road boundaries from the scenario and convert them from cell to
% struct for saving
roads = roadBoundaries(scenario);
RoadBoundaries = cell2struct(roads, 'RoadBoundaries',1);
save(fileName, 'vehiclePoses', 'RoadBoundaries')

if nargout
    varargout = {scenario};
else
    varargout = {};
end