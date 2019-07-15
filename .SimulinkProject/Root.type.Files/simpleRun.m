close all
clear
clc

% Set up global variables
setGlobalVars();

global fid;

% Set Simulation Run Parameters

% Num of simulations to run in parallel
NUM_SIMULATIONS = 10;
% Num of road pieces to place in scenario
LEN_ROAD = 5; 
% Num of actors to place in scenario (cars, pedestrians, etc.)
NUM_ACTORS = 0;
% runSimulations(NUM_SIMULATIONS, LEN_ROAD, NUM_ACTORS);

% testing

% for data collection
%for i=1:100
runSimulations(21, LEN_ROAD, NUM_ACTORS);
%end
fclose(fid);
disp("Simulations Complete");