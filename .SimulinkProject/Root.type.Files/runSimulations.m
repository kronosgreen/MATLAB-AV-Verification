function [result] = runSimulations(numSimulations, lenRoad, numActors)
%RUNSIMULATIONS 
%   set up parallel running of driving simulations w set parameters
    
    % get testing file
    global fid;

    % Parallel not implemented yet: disp("Runnning " + numSimulations + " simulations.");
    
    % clears previous file, this stores the input to the different 
    % simulations that were run 
    delete('matrixFile.txt');
    
    %[rMatrix, aMatrix] = getRandMatrix(lenRoad, numActors, numSimulations);
    
%      TALTECH PATH - TEST
%      rMatrix = [ 3 30 110 22 0 22.352 0121 0 0 "000:000" "000" 0; ...
%                 3 30 111 22 0 22.352 0121 0 0 "000:000" "000" 0;...
%                 1 30 1 2 0 22.352 0121 -0.033 0 "000:000" "000" 0;...
%                 1 25 1 2 2 22.352 0121 0 0 "000:000" "000" 0;...
%                 4 5 1 2 0 10 0121 0 0 "003:013" "000" 0;...
%                 5 50 1 2 0 22.352 0121 0 0 "000:000" "000" 0;...
%                 1 35 1 2 0 22.352 0121 0 0 "000:000" "000" 0;...
%                 4 5 1 2 0 10 0121 0 0 "003:013" "000" 0;...
%                 1 30 1 2 0 22.352 0121 0 0 "000:000" "000" 0;...
%                 4 5 1 2 0 10 0121 0 0 "003:013" "000" 0;...
%                 1 90 1 2 0 22.352 0121 -0.007 0 "000:000" "000" 0;...
%                 1 80 1 2 0 22.352 0121 0.022 0 "000:000" "000" 0;...
%                 1 70 1 2 0 22.352 0121 -0.015 0 "000:000" "000" 0];
%      aMatrix = [];
    
    %rMatrix = roadMatrix;
    %aMatrix = actorMatrix;
    
    rMatrix = [2 50 1212 1 1 27 0202 0.4 0.0 "000:00" "000" 1];
    %aMatrix = [1 1 5 0 10 10 10 0.2 1 0 0 0.5];
    %aMatrix = ["1", "1", "5", "0", "10", "10", "10", "0.2", "1", "0", "0", "0.5"];
    aMatrix = [1, 1, 5, 0, 10, 10, 10, 0.2, 1, 0, 0, 0.5];
    
    matrix2scen(rMatrix, aMatrix);

    result = true;
   
end