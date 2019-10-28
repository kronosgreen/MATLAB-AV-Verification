function [result] = runSimulations(numSimulations, lenRoad, numActors)
%RUNSIMULATIONS 
%   set up parallel running of driving simulations w set parameters
    
    % get testing file
    global fid;

    % Parallel not implemented yet: disp("Runnning " + numSimulations + " simulations.");
    
    % clears previous file, this stores the input to the different 
    % simulations that were run 
    delete('matrixFile.txt');
    
    [rMatrix, aMatrix] = getRandMatrix(lenRoad, numActors, numSimulations);
    
    % Debug Ped. 
    rMatrix = [ "1"    "160"    "4"      "2"     "1"    "17.8816"    "0"    "-0.015097"    "0.013027"      "019"            "000"    "1"; ...
   "5"    "150"    "4"      "2"     "1"    "35.7632"    "0"    "0.010729"     "0.0021272"     "0"              "000"    "1";...
   "3"    "160"    "341"    "21"    "3"    "24.5872"    "0"    "0.020432"     "-0.0090382"    "0"              "000"    "0";...
   "5"    "80"     "4"      "2"     "2"    "33.528"     "0"    "-0.015053"    "0.017843"      "708:303"        "000"    "1";...
   "1"    "120"    "5"      "2"     "3"    "24.5872"    "0"    "0.016306"     "-0.012431"     "915:000:307"    "000"    "0"];

    aMatrix = [...
       1.0000    2.0000    2.0000   -3.0000    9.0000    8.0000    9.0000    0.4200    1.0000    0.5200;...
       2.0000    1.0000    1.0000   -3.0000    4.0000    3.0000    6.0000    0.5700         0    0.3000;...
       1.0000    3.0000    2.0000         0   10.0000    5.0000    4.0000    0.5200    1.0000    0.8600;...
       1.0000    2.0000    3.0000    2.0000    6.0000    1.0000    4.0000    0.5700         0    0.5200;...
       2.0000    1.0000    1.0000   -1.0000    2.0000    2.0000    9.0000    0.3700         0    0.7600];
  
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
%                 1 70 1 2 0 22.352 0121 -0.015 0 "000:000" "000" 0]
    
    matrix2scen(rMatrix, aMatrix);

    result = true;
   
end