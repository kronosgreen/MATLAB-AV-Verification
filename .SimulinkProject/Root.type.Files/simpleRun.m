close all
clear
clc

% Set Simulation Run Parameters

% Num of simulations to run in parallel
NUM_SIMULATIONS = 5;
% Num of road pieces to place in scenario
LEN_ROAD = 5;
% Num of actors to place in scenario (cars, pedestrians, etc.)
NUM_ACTORS = 20;

runSimulations(NUM_SIMULATIONS, LEN_ROAD, NUM_ACTORS);

disp("Simulations Complete");