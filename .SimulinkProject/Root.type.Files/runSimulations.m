function [result] = runSimulations(numSimulations, lenRoad, numActors)
%RUNSIMULATIONS 
%   set up parallel running of driving simulations w set parameters

    % Some parallel toolbox functions, not in use yet
    %poolobj = gcp;
    %addAttachedFiles(poolobj, {});
    
    disp("Running " + numSimulations + " simulations.")
    
    % clears previous file, this stores the input to the different 
    % simulations that were run 
    delete('matrixFile.txt');
    
    %Load Simulation Simulink Model
    %load_system('AV_Verification_System');
    
    % Runs simulations in parallel by distributing each iteration to
    % pool of workers, uses iterator as rng seed

   % parfor i=1:numSimulations
        % [rMatrix, aMatrix] = getRandMatrix(lenRoad, numActors, i);
        rMatrix = [1 45 2 2 1 1 50 0.06 0; 1 60 3 2 1 1 55 0.06 0];
        aMatrix = [1 2 1 60 1 1 1 0];
        % set_param('AV_Verification_System/Scenario', 'Scene_Description',
        % rMatrix);
        str2scen(rMatrix, aMatrix);
    %end

    result = true;
   
end

