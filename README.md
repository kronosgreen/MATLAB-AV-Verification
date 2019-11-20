# MATLAB-AV-Verification

This project serves as a **Scenario Generation Verification Framework** for the verification of autonomous vehicles (AV), specifically the decision making portion [[1](#sgframework)], and is also a part of the Advanced Mobility Institute at Florida Polytechnic's **FLPolyVF** or Florida Poly Verification Framework, which seeks to fully verify autonomous vehicles as demonstrating Level 5 autonomous driving as defined by the SAE [[3](#moc)]. As the field of AV verification expands, it is continuingly seen to be more and more of an almost impossible task [[2](#verreview)], especially without simulation due to its complex nature, and this is where the **FLPolyVF** comes in. It seeks to provide a solution to this problem by creating a robust framework for AV verification that draws inspiration from chip verification, which is an industry that has been verifying complex systems for much longer.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

To run this project, you will need the latest iteration of MATLAB as well as a few toolboxes, all listed below:

* MATLAB R2019b
 * Automated Driving Toolbox
<!-- * Parallel Computing Toolbox -->

You can get the latest MATLAB from [https://www.mathworks.com/downloads]

The toolboxes can be installed while setting up MATLAB, or you can continue through setting up and running the code which will prompt you to download the required toolboxes and allow you to open the appropriate links from there.

### Setting Up

To set up the project in your own directory, download it into the *MATLAB/Projects* folder. This can either be done by calling `git clone https://github.com/kronosgreen/MATLAB-AV-Verification.git` from inside the folder, or by downloading it from the website and extracting it to said folder.

To open the folder from inside MATLAB, a few options are available. You can use the file explorer on the left bar. Alternatively, you could open a file using the *Open* button (or *Ctrl + O*) on the Home tab which will open a File Explorer so you can open the described project folder.

## Running Simulation

Once in MATLAB, you can run a quick test by going to *.SimulinkProject > Root.type.Files*. That is where all of the scene generator files can be located. If the folders for road pieces and actors are transparent, be sure to right click and add to path, otherwise the functions inside will not be callable.

![Main File Hierarchy](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/file-hierarchy.png)

In order to run a randomly generated simulation, you will interface with the *simpleRun.m* file where you can adjust how many road pieces and actors will be randomly generated in the scenario. That amount may not show up in the actual simulation as some of them can fail to be placed if they logically interfere with any of the previously placed pieces, so these numbers more accurately represent how many random road pieces and actor generations will be attempted. You can press run from this file (*simpleRun.m*) with the default parameters to see how a randomly generated scenario runs.

![Scenario Generation Code](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/root-files.png)

Playing around with these simple parameters can generate repeatable random scenarios given the seed (equal to the NUM_SIMULATIONS parameter). For custom scenarios, you have to create your own matrices to define the roads and actors. Within these matrices, each row defines a new road piece or actor, and each column describes a certain trait of said piece or actor, from curvature to speed limit and from vehicle type to moving behavior. The random matrices are created in *getRandMatrix.m*, so, to limit only a single parameter, you can go in here and adjust the line corresponding with that parameter getting its random value.

## Simulink Demo

![Simulink Demo](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/simulink.png)
By opening Simulink and selecting the simulink_scenario_demo.slx file from the main project folder, you can see an implementation of the scenario generation with a demo model of a lane follower taken from the automated driving example. The button with "Generate Scenario" must be clicked first to initialize all the variables as well as creating the scenario using parameters hardcoded in the generate_scenario.m file which can be changed there.

## Overview

### Road Pieces

![Road Pieces](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/matlabroad.png)

The road pieces that make up the scenarios are made to be as general as possible in order to maximize coverage with the goal of eventually being able to create all possible roads and are found in the *Root.type.Files > roadPiece* folder. Each new piece will bring with it a million new possible roads making the definition of these roads a large ongoing effort. With new pieces, new parameters will have to be defined and old ones redefined, meaning the current parameters may not be totally representative of later iterations. It should also be noted that certain parameters may have different meanings in different road pieces, as each piece will have needs specific to them. Many of the road pieces (Single Pedestrian Crosswalk, Three-way Intersection, Side Lot Enter) were created as part of a collaboration with the Estonian university TalTech and describe parts of an autonomous vehicle track for their autonomous vehicle research. This demonstrates the methodology of breaking down an environment into its characteristic driving components (road pieces and parametrization) as a means of verifying an AV for driving in said environment (Level 4 Autonomous Driving - environment specific).

#### Current Parameters
- Road Type
- Length
- Lanes
- Bidirectional
- Mid-Lane
- Speed Limit
- Intersection Pattern
- Curvature 1
- Curvature 2
- Pedestrian Pathways
- Outlets
- Show Markers

#### Multi-lane Road

![Multilane Road](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/multilane_v1.png)

The multi-lane road piece is one of variable length and width that can take on virtually all geometries with G2 continuity, something that is desired when designing real roads. It achieves this by making permutations of three geometric primitives:  lines, clothoids, and arcs, using the clothoid to transition between different curvatures at a constant rate. The parameters determining the geometry of the road are curvature1 and curvature2. If either of them are zero, the road is made of a line to a clothoid to an arc, where the arc is the non-zero value. If both are zero, a straight line is made. And if both are non-zero values, then either a Clothoid-Arc-Clothoid (0 to curvature1 to curvature2) or an Arc-Clothoid-Arc (curvature1 to curvature2) is generated, the current deciding factor between the two being random. By composing the roads using these three primitives, the permutations should make up most all possible roads. The length of each of the three parts is one third of the total length given from the determining matrix row.

#### 4-Way Intersection

![Intersection](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/fourway.png)

The 4-Way intersection creates a perpendicular intersection where each road can have its own number of lanes and direction of travel. They are placed across from each other around a central rectangle calculated by using the widths of all four roads. Once placed, the paths are determined by distributing the possible directions to each lane, starting with left turns if possible, and following with right, and then forward. This is for the direction on the intersection that connects with the previous road piece, as that is the one that matters most for the ego vehicle.

#### Side Lot Enter

![Side Lot Enter](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/sidelot.png)

The Side Lot Enter is a piece found in the TalTech path that splits the road with a median with an entrance in the middle to a parking lot. A sign on either end of the median points to the side the car ought to be on. This piece was deliberately created to encompass the logic of the TalTech path, as this point in the path is where the most complexity is found, with the most number of actors interacting.

#### 3-Way Intersection

The three-way intersection is similar to the previous piece (Side Lot Enter), but optionally has the median in the middle. A main road has a second road exiting it either to the right or to the left, and is primarily based on those exits to parking lots and buildings found in the TalTech path.

#### Single Pedestrian Crosswalk

![Single Pedestrian Crosswalk](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/pedestriancross.png)

The single pedestrian crosswalk will primarily reflect those found in the TalTech path. They have an elevation parameter to serve as a speed bump as it does in the path, as well as optional signage if the scenario requires it. The frequency at which pedestrians cross is the main property that can be varied, initializing the actors at the beginning and sending them across the road at random points along its length based on the inputted frequency.


### Actors

Randomly generated actors as of yet are purely for demonstration purposes, as defining a language to encompass all potential actor behavior has yet to be elaborated upon in our project. Currently, actors can follow a straight path along the road with the option to have some variability. The files where actors are generated can be found in the *Root.type.Files > actors* folder.

#### Parameters
- Actor Type
- Vehicle Type
- Path Type
- Move Speed
- Dimensions (x, y, z variation from actor body type)
- Start Location
- Forward
- Offset

#### Vehicle

The vehicle actor is generated somewhere along the path (Start Location parameter) and moves forward along some random lane or in the opposite direction given the Forward parameter and the availability of an opposite direction (the road is bidirectional). Its size is determined based on its vehicle type (Car, Truck, Motorcycle) and varies according to the Dimensions parameter; in MATLAB this simply sets the x, y, and z dimensions of the actor as they are all represented by boxes. Its path can be set to simple which follows the lanes exactly or off which will slightly offset it to varying degrees from the lane which also uses the Offset parameter. It moves at the road's speed limit, set in the road pieces parameters, with variation according to the Move Speed parameter.

#### Pedestrian

Pedestrians are set on either side of the road somewhere along the scenario based on Start Location and Forward and move across at an average walking speed varied by the Move Speed parameter. The two path options are walking straight across and walking across with a pause at some point in the middle. The time at which it starts to cross is based on the Offset parameter.

### Example of Matrix-based Scenario

Here, a curving multilane road with a median is constructed as well as a pedestrian actor that crosses said road. The road’s geometry follows an Arc-Clothoid-Arc pattern starting with a curvature of 0.009 and ending with a curvature of -0.014, meaning the road starts off with an arc with a curvature of 0.009 for a third of the length (in this case 150m/3 or 50m), transitions the curvature to -0.014 with a clothoid curve for a third of the length, and finishes by continuing with that curvature in an arc for a third of the length. For the pedestrian actor, a random point along the road is selected, and the point directly to the left is calculated, its path moving across to the right as the forward parameter was given as false. This actor starts moving once the scenario begins, and as you can see, by the time the ego vehicle arrives, it has almost gotten halfway across. The ego vehicle was generated automatically as in the last example.

![Example Scenario](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/example-road.png)
![Matrix](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/example-matrix.png)

* Road Piece : [ 1 200 3 2 3 29.0576 0 0.0098864 -0.014198 “000” “000” 1 ]
  * Road Type: 1 (Multilane Road)
  * Length: 200m
  * Lanes: 3
  * Bidirectional: 2 (Yes, Dashed Yellow Line)
  * MidLane: 3 (Large Median)
  * Speed Limit: 65mph (from mps speed)
  * Intersection Pattern: n/a
  * Curvature 1: 0.0098864
  * Curvature 2: -0.014198
  * Pedestrian PathWays: n/a
  * Outlets: n/a
  * Show Markers: 1 (Yes)
* Actor : [ 2 1 1 0 6 7 5 0.65 0 0.63 ]
  * Actor Type: 2 (Pedestrian)
  * Vehicle Type: n/a
  * Path Type: 1 (Normal)
  * Move Speed: 0 (0mps from regular speed)
  * Dimensions: 6, 7, 5 (x,y,z proportions to regular ped. size)
  * Start Location: 0.65 (Starts ~65% along path)
  * Forward: 0 (Moves left to right)
  * Offset: 0.63 (Offset from main path)


## Deployment

Deployment for verification testing is not available yet. Date TBD

<!--
## Contributing
Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.
-->

## Authors

* **Christopher Medrano** - *Initial work* - [GitHub](https://github.com/kronosgreen)
* **Mohsen Malayjerdi** - *TalTech Partner - Autoware Interface* - [LinkedIn](https://ir.linkedin.com/in/mohsen-malayjerdi)

See also the list of [contributors](https://github.com/kronosgreen/MATLAB-AV-Verification/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Mustafa Ilhan Akbaş - Advisor, and so a large part of the development process - [Website](https://sites.google.com/site/miakbas/)
* Rahul Razdan - Leads Florida Poly's AMI - [AMI Website](http://www.flpolyami.com/)

## References

<a name="sgframework">[1]</a>: [C. Medrano-Berumen, M. I. Akbas, Abstract Simulation Scenario Generation for Autonomous Vehicle  Verification, in: Proceedings of the IEEE SoutheastCon, IEEE.](https://www.researchgate.net/publication/335617277_Abstract_Simulation_Scenario_Generation_for_Autonomous_Vehicle_Verification)

<a name="verreview">[2]</a>: [M. I. Akbas, A. Sargolzaei, A. J. Alnaser, S. Sahawneh, S. Alsweiss,J. Vargas, R. Razdan,  Unsettled technology areas in autonomous vehicle test and validation, Society of Automotive Engineers (SAE) International Journal of Connected and Automated Vehicles (2019).](https://saemobilus.sae.org/content/EPR2019001/)

<a name="moc">[3]</a>: [A. J. Alnaser, M. I. Akbas, A. Sargolzaei, R. Razdan, Autonomous vehicles scenario testing framework and model of computation, Society of Automotive Engineers (SAE) International Journal of Connected and Automated Vehicles (2019).](http://www.flpolyami.com/me/ami/av-sensors-15228.html)
