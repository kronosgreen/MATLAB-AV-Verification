function [result] = runSimulations(numSimulations, lenRoad, numActors)
%RUNSIMULATIONS 
%   set up parallel running of driving simulations w set parameters
    
    % get testing file
    global fid;

    % Parallel not implemented yet: disp("Runnning " + numSimulations + " simulations.");
    
    % clears previous file, this stores the input to the different 
    % simulations that were run 
    delete('matrixFile.txt');
    
    [rMatrix, aMatrix] = getRandMatrix(lenRoad, numActors, 2);

    matrix2scen(rMatrix, aMatrix);

    result = true;
   
end