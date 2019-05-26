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

Set up the GitHub project in your own directory by locating the MATLAB/Projects folder, often in the Documents folder and call `git clone https://github.com/kronosgreen/MATLAB-AV-Verification.git` or do so from GitHub by downloading and extracting to the aforementioned folder.

To open the folder from inside MATLAB, a few options are available. You can use the file explorer on the left bar. Alternatively, you could open a file using the *Open* button (or *Ctrl + O*) on the Home tab which will open the including folder in said left bar. 

## Running Simulation

Once in MATLAB, go to .SimulinkProject > Root.type.Files. That is where all of <br/>
the scene generator files can be located. If the folders for road pieces and actors<br/>
are transparent, be sure to right click and add to path. 

In order to run a randomly generated simulation, you will interface with the simpleRun.m file where you can adjust how many road pieces and actors will be randomly fed into the scene. That amount may not show up in the actual simulation as some of them can fail to be placed if they logically interfere with any of the previously placed pieces. You can press run from this file with the default parameters to see how a randomly generated scenario runs. 

<!--
### Road Pieces
The road pieces designed are made to be as general as possible in order to maximize coverage which will ultimately allow the scenario generation framework to create all possible roads. Each new piece will bring with it a million new possible roads, but for all pieces to be de
-->

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
