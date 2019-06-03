# MATLAB-AV-Verification

This project serves as a **Scenario Generation Verification Framework** for the verification of autonomous vehicles (AV), specifically the decision making portion, and is also a part of the Advanced Mobility Institute at Florida Polytechnic's **FLPolyVF** or Florida Poly Verification Framework, which seeks to fully verify autonomous vehicles as demonstrating Level 5 autonomous driving as defined by the SAE. As the field of AV verification expands, it is continuingly seen to be more and more of an almost impossible task, especially without simulation due to its complex nature, and this is where the **FLPolyVF** comes in. It seeks to provide a solution to this problem by creating a robust framework for AV verification that draws inspiration from chip verification, which is an industry that has been verifying complex systems for much longer. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

To run this project, you will need the latest iteration of MATLAB as well as a few toolboxes, all listed below:

* MATLAB 2019a
 * Automated Driving Toolbox
<!-- * Parallel Computing Toolbox -->

You can get the latest MATLAB from [https://www.mathworks.com/downloads]

The toolboxes can be installed while setting up MATLAB, or you can continue through setting up and running the code which will prompt you to download the required toolboxes and allow you to open the appropriate links from there. 

### Setting Up

To set up the project in your own directory, download it into the *MATLAB/Projects* folder. This can either be done by calling `git clone https://github.com/kronosgreen/MATLAB-AV-Verification.git` from inside the folder, or by downloading it from the website and extracting it to said folder. 

To open the folder from inside MATLAB, a few options are available. You can use the file explorer on the left bar. Alternatively, you could open a file using the *Open* button (or *Ctrl + O*) on the Home tab which will open the including folder in said left bar. 

## Running Simulation

Once in MATLAB, go to .SimulinkProject > Root.type.Files. That is where all of the scene generator files can be located. If the folders for road pieces and actors are transparent, be sure to right click and add to path, otherwise the functions inside will not be callable. 

In order to run a randomly generated simulation, you will interface with the simpleRun.m file where you can adjust how many road pieces and actors will be randomly fed into the scene. That amount may not show up in the actual simulation as some of them can fail to be placed if they logically interfere with any of the previously placed pieces. You can press run from this file with the default parameters to see how a randomly generated scenario runs. 

Playing around with these simple parameters can generate completely random scenarios, but for more custom scenarios, you have to create your own matrices to define the roads and actors. Within these matrices, each row defines a new road piece or actor, and each column describes a certain trait of said piece or actor, from curvature to speed limit and from vehicle type to moving behavior. The random matrices are created in *getRandMatrix.m*, so, to limit only a single parameter, you can go in here and adjust the line corresponding with that parameter getting its random value. 

### Road Pieces

![Road Pieces](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/matlabroad.png)

The road pieces that make up the scenarios are made to be as general as possible in order to maximize coverage with the goal of eventually being able to create all possible roads. Each new piece will bring with it a million new possible roads making the definition of these roads a large ongoing effort. With new pieces, new parameters will have to be defined and old ones redefined, meaning the current parameters may not be totally representative of later iterations. It should also be noted that certain parameters may have different meanings in different road pieces, as each piece will have needs specific to them. 

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

#### Multi-lane Road

![Multilane Road](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/multilane_v1.png)

The multi-lane road piece is one of variable length and width that can take on virtually all geometries with G2 continuity, something that is desired when designing real roads. It achieves this by making permutations of three geometric primitives:  lines, clothoids, and arcs, using the clothoid to transition between different curvatures at a constant rate. The parameters determining the geometry of the road are curvature1 and curvature2. If either of them are zero, the road is made of a line to a clothoid to an arc, where the arc is the non-zero value. If both are zero, a straight line is made. And if both are non-zero values, then either a Clothoid-Arc-Clothoid (0 to curvature1 to curvature2) or an Arc-Clothoid-Arc (curvature1 to curvature2) is generated, the current deciding factor between the two being random. By composing the roads using these three primitives, the permutations should make up most all possible roads. The length of each of the three parts is one third of the total length given from the determining matrix row.

#### 4-Way Intersection

![Road Pieces](https://github.com/kronosgreen/MATLAB-AV-Verification/blob/master/images/fourway.png)

The 4-Way intersection creates a perpendicular intersection where each road can have its own number of lanes and direction of travel. They are placed across from each other around a central rectangle calculated by using the widths of all four roads. Once placed, the paths are determined by distributing the possible directions to each lane, starting with left turns if possible, and following with right, and then forward. This is for the direction on the intersection that connects with the previous road piece, as that is the one that matters most for the ego vehicle. 

## Deployment

Deployment for verification testing is not available yet. Date TBD

<!--
## Contributing
Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.
-->

## Authors

* **Christopher Medrano** - *Initial work* - [GitHub](https://github.com/kronosgreen)

See also the list of [contributors](https://github.com/kronosgreen/MATLAB-AV-Verification/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Mustafa Ilhan Akbaş - Advisor, and so a large part of the development process
* Rahul Razdan - Leads Florida Poly's AMI
