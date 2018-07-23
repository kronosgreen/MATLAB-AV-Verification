function [result] = runSimulations(numSimulations, lenRoad, numActors)
%RUNSIMULATIONS 
%   set up parallel running of driving simulations w set parameters

    % Some parallel toolbox functions, not in use yet
    %poolobj = gcp;
    %addAttachedFiles(poolobj, {});
    
    disp("Runnning " + numSimulations + " simulations.")
    
    % clears previous file, this stores the input to the different 
    % simulations that were run 
    delete('matrixFile.txt');
    
    %Load Simulation Simulink Model
    %load_system('AV_Verification_System');
    
    % Runs simulations in parallel by distributing each iteration to
    % pool of workers, uses iterator as rng seed
    
    %parfor i=1:numSimulations
        [rMatrix, aMatrix] = getRandMatrix(lenRoad, numActors, 2);
        % set_param('AV_Verification_System/Main_Program',
        % 'Scene_Description');
        % sim('AV_Verification_System');
        matrix2scen(rMatrix, aMatrix);
    %end

    result = true;
   
end

