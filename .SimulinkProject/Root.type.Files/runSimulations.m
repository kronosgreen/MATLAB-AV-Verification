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
    
    %ID1
    %rMatrix = [1 50 2 0 0 30 0 0.0 0.0 "000:00" "000" 1;...
    %          1 25 3 0 0 30 0 0.0 0.0 "000:00" "000" 1;...
    %         1 25 4 0 0 30 0 0.002 0.004 "000:00" "000" 1;...
    %         1 50 5 0 0 30 0 0.004 0.006 "000:00" "000" 1];
    %aMatrix = [2 0 1 5 3 3 3 0.45 1 0];
    %ID1
    
    %ID2
    %rMatrix = [2 75 2224 0 0 27 0002 0 0 "000:000" "000" 1];
    %aMatrix = [1 2 1 -27 10 20 10 0.20 0 0];
    %ID2
        
    %ID3
    
    %ID3
    
    %ID4
    %rMatrix = [2 75 2224 1 2 27 0002 0 0 "000:000" "000" 1];
    %aMatrix = [1 2 3 -26 8 9 10 0.40 1 1];
    %ID 4
    
    
    %ID22
    rMatrix = [1 100 3 0 0 27 0 0 0 "000:000" "000" 1];
    aMatrix = [1 2 4 -1 9 9 9 0 0 0 0.35];
    %aMatrix = [1 2 1 -15 9 9 9 0 0 0 0.5];
    %ID22
    
    
    matrix2scen(rMatrix, aMatrix);

    result = true;
   
end