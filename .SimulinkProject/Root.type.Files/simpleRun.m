close all
clear
clc

delete("thetas_accuracy_data.txt");

% Set up global variables
setGlobalVars();

% Set Simulation Run Parameters

% Num of simulations to run in parallel
NUM_SIMULATIONS = 5;
% Num of road pieces to place in scenario
LEN_ROAD = 30;
% Num of actors to place in scenario (cars, pedestrians, etc.)
NUM_ACTORS = 0;

runSimulations(NUM_SIMULATIONS, LEN_ROAD, NUM_ACTORS);

disp("Simulations Complete");