# MATLAB-AV-Verification
 Scene Generator and Framework that will be used for the Verification of Autonomous Vehicles

## Setup
These files correspond to what is found in a project folder in MATLAB/Projects,
so in the command prompt, `cd` to the MATLAB/Projects folder and call<br/>
`git clone https://github.com/kronosgreen/MATLAB-AV-Verification.git`<br/>
or do so from GitHub by downloading and extracting to the aforementioned folder.

Once in MATLAB, go to .SimulinkProject > Root.type.Files. That is where all of <br/>
the scene generator files can be located. If the folders for road pieces and actors<br/>
are transparent, be sure to right click and add to path. 

## Run Simulation
In order to run a simulation, you will interface with the simpleRun.m file, where <br/>
you can adjust how many road pieces and actors will be in the scene. The number <br/>
of simulations to run currently does nothing, but will be set up once multiple <br/>
parallel runs of the simulation are necessary.

## Simulink (In Progress...)
In order to reach the Simulink project, open Simulink from the home tab and <br/>
click on the button that says Simulink below it. From here you can open the <br/>
AV-Verification-System.slx file in the .SimulinkProject > Root.type.Files folder
