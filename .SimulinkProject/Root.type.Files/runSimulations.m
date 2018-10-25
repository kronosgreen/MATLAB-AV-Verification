function [result] = runSimulations(numSimulations, lenRoad, numActors)
%RUNSIMULATIONS 
%   set up parallel running of driving simulations w set parameters

    % Some parallel toolbox functions, not in use yet
    %poolobj = gcp;
    %addAttachedFiles(poolobj, {});
    
    disp("Runnning " + numSimulations + " simulations.");
    
    % clears previous file, this stores the input to the different 
    % simulations that were run 
    delete('matrixFile.txt');
    
    %Load Simulation Simulink Model
    %load_system('AV_Verification_System');
    
    % Runs simulations in parallel by distributing each iteration to
    % pool of workers, uses iterator as rng seed
    
    %parfor i=1:numSimulations
        [rMatrix, aMatrix] = getRandMatrix(lenRoad, numActors, 3);
        % rMatrix = [ 2.0, 100.0, 4223.0, 1.0,   0, 26.8224,   11.0,  -0.010451999999999999485522650388702, -0.0032913000000000000415389944663502]

        disp(vpa(rMatrix))
        % set_param('AV_Verification_System/Main_Program',
        % 'Scene_Description');
        % sim('AV_Verification_System');
        matrix2scen(rMatrix, aMatrix);
    %end

    result = true;
   
end

