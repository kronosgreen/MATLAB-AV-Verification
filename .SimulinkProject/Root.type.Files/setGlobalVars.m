%{
    Global Variables will be stored here
%}

function setGlobalVars

global LANE_WIDTH;
LANE_WIDTH = 3;

global TRANSITION_PIECE_LENGTH;
TRANSITION_PIECE_LENGTH = 12;

global fid;
fid = fopen("placedRoadNet.txt", "a");

global MINUTE_LIMIT;
MINUTE_LIMIT = 15;

global PED_FACTOR;
PED_FACTOR = 1;

end