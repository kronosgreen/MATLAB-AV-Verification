classdef (StrictDefaults)AVVerScenarioReader < driving.internal.SimulinkBusUtilities ...
        & matlab.system.mixin.CustomIcon ... 
        & matlab.system.mixin.internal.SampleTime
% helperScenarioReader Read actor poses and road data from a recorded
% driving scenario
%
% This is a helper block for example purposes and may be removed or
% modified in the future.
%
% helperScenarioReader reads actor poses data saved using the record method
% of drivingScenario. The data has the following fields:
%   SimulationTime    the time of simulation 
%   ActorPoses        a struct array containing the pose of each
%                     actor at the corresponding simulation time.
%
% If the actor poses data contains the ego vehicle pose, you can specify
% which index is used for the ego data. In that case, the block will
% convert the poses of all the other actors to the ego vehicle coordinates.
% This allows the actor poses to be used by the visionDetectionGenerator
% and radarDetectionGenerator objects.
%
% If ego vehicle index is not provided, all the actor poses will be
% provided in scenario coordinates. You will then have to convert them to
% ego vehicle coordinates using the driving.scenario.targetsToEgo function
% before generating detections using the visionDetectionGenerator and
% radarDetectionGenerator objects.
%
% In addition to reading actor poses data, if you specify an ego actor, you
% can use this block to read road boundaries data in ego coordinates. Road
% boundaries in scenario coordinates are obtained using the roadBoundaries
% method of drivingScenario. They must be saved to the same file as the
% actor poses using the name RoadBoundaries.
%
% Code generation limitation for road boundaries: concatenate the road
% boundaries matrices in an N-by-3 matrix, where each road matrix (an
% Np-by-3 matrix) is separated from the next by a row of NaNs.
%
% See also: helperSaveScenarioToFile, drivingScenario, drivingScenario/record,
% drivingScenario/roadBoundaries, driving.scenario.targetsToEgo,
% driving.scenario.roadBoundariesToEgo, visionDetectionGenerator,
% radarDetectionGenerator

% Copyright 2017 The MathWorks, Inc.

%#codegen
    
    % Public, tunable properties
    properties

    end

    % Public, non-tunable properties
    properties(Nontunable)
        %ScenarioFileName File name for the recorded scenario
        ScenarioFileName = char.empty(1,0);
        %LaneBoundaryDistance  Distances ahead of ego to compute boundaries
        LaneBoundaryDistance = 0:0.5:9.5
        %LaneBoundaryLocation Location of boundaries on lane marking
        LaneBoundaryLocation = 'center'
    end
    
    properties(Constant, Hidden)
       %EgoActorSourceSet Options for ego actor source
       EgoActorSourceSet = matlab.system.StringSet({'Input port','Auto'});
       %LaneBoundaryLocationSet Options for lane boundary location
       LaneBoundaryLocationSet = matlab.system.StringSet({'center','inner'})
       %BusName2SourceSet Options for lane boundaries bus name
       BusName2SourceSet = matlab.system.StringSet({'Auto','Property'})
       %BusName3SourceSet Options for lane markings bus name
       BusName3SourceSet = matlab.system.StringSet({'Auto','Property'})
    end
    
    properties(Nontunable)
        %EgoActorSource   Specify the source of the ego actor
        EgoActorSource = 'Auto'
        %BusName2Source Source of lane boundaries bus name
        BusName2Source = 'Auto'
        %BusName3Source Source of lane markings bus name
        BusName3Source = 'Auto'
        %BusName2 Specify a name for lane boundaries bus
        BusName2 = ''
        %BusName3 Specify a name for lane markings bus
        BusName3 = ''
    end
    
    properties(Nontunable, PositiveInteger)
        %EgoActorID Ego actor index in the recorded data
        EgoActorID = 1
    end
    
    properties(Nontunable, Logical)
        %RoadBoundaries Output road boundaries in ego coordinates
        RoadBoundaries = false
        %LaneMarkings Output lane markings in ego coordinates
        LaneMarkings = false
        %LaneBoundaries Output lane boundaries in ego coordinates
        LaneBoundaries = false
        %AllBoundaries Output all lane boundaries
        AllBoundaries = false
        %CurrentLane Output current lane of ego
        CurrentLane = false
        %NumLanes Output number of lanes
        NumLanes = false
    end
    
    properties(Constant, Access=protected)
        %pBusPrefix Prefix used to create bus names
        %   Buses will be created with the name <pBusPrefix>#, where
        %   <pBusPrefix> is the char array set to pBusPrefix and # is an
        %   integer. Subbuses will be created by appending the name of the
        %   structure field associated with the subbus to the base bus
        %   name. For example: <pBusPrefix>#<fieldName>
        %
        %   To create multiple buses, set pBusPrefix to a cell array of
        %   character arrays defining the bus prefix to be used for each
        %   bus. The number of elements in the cell array determines the
        %   number of buses that will be defined. This first bus prefix is
        %   associated with the BusName property, the second bus prefix is
        %   associated with the BusName2 and BusName2Source properties and
        %   the n-th bus prefix is associated with the BusName<N> and
        %   BusName<N>Source properties. The BusName and BusNameSource
        %   properties are inherited from this class. Additional buses
        %   require definition of the appropriate BusName<k> and
        %   BusName<k>Source properties in the class file where pBusPrefix
        %   is defined.
        %
        pBusPrefix = {'BusActors','BusLaneBoundaries','BusLaneMarkings'}
    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)
        %pActors Contains the loaded actors data
        pActors
        
        %pRoads  Contains the loaded road boundaries data in scenario frame
        pRoads

        %pCurrentTime Current simulation time
        pCurrentTime = 0
        
        %pCurrentIndex Current index into the actors data struct
        pCurrentIndex
        
        %pMaxIndex     Saved the maximum time step index in the data file
        pMaxIndex
        
        %pRoadBoundariesSize Specifies the size of the road boundaries output for codegen
        pRoadBoundariesSize
        
        %pRoadNetwork Contains the loaded road network data
        pRoadNetwork
        
        %pLaneMarkingVertices Contains the loaded lane marking vertices
        pLaneMarkingVertices
        
        %pLaneMarkingFaces Contains the loaded lane marking faces
        pLaneMarkingFaces
    end
    properties(Access = private, Nontunable)
        %pHasEgoActor A logical value. True if the ego actor is in file
        pHasEgoActor
        %pLaneBoundariesSize Specifies the size of lane boundaries output for codegen
        pLaneBoundariesSize = [2 1]
    end

    methods
        % Constructor
        function obj = AVVerScenarioReader(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.pHasEgoActor = strcmpi(obj.EgoActorSource, 'Auto');
            
            % Reread the road boundaries from the file
            if obj.RoadBoundaries
                readRoadBoundriesFromFile(obj);
            end
            
            % Reread the lane markings from the file
            if obj.LaneMarkings
                readLaneMarkingsFromFile(obj);
            end
            
            % Reread the road network from file. Right now, this is needed
            % only if we have to output the lane boundaries relative to an
            % ego position or the current lane of the ego.
            if obj.LaneBoundaries || obj.CurrentLane || obj.NumLanes
                readRoadNetworkFromFile(obj);
            end
            
        end
        
        function flag = checkStructForFields(~, s, expFields)
            % Returns true if the struct s has the expected fields, expFields
            
            flag = true;
            for i = 1:numel(expFields)
                if ~isfield(s,expFields{i})
                    flag = false;
                    return
                end
            end
        end

        function [posesOnBus, varargout] = stepImpl(obj, varargin)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            
            % Find the data index based on the simulation time
            obj.pCurrentTime = obj.pCurrentTime + getSampleTime(obj);
            while abs(obj.pActors(obj.pCurrentIndex).SimulationTime - obj.pCurrentTime) > 1e-4
                if ~obj.isEndOfData()
                    obj.pCurrentIndex = obj.pCurrentIndex + 1;
                else
                    break
                end
            end
            
            % Read the actor poses
            if obj.pHasEgoActor
                egoCar = obj.pActors(obj.pCurrentIndex).ActorPoses(obj.EgoActorID);
                otherActorIndices = (obj.EgoActorID ~= 1:numel(obj.pActors(obj.pCurrentIndex).ActorPoses));
                actors = obj.pActors(obj.pCurrentIndex).ActorPoses(otherActorIndices);
            else
                egoCar = varargin{1};
                actors = obj.pActors(obj.pCurrentIndex).ActorPoses;
            end
            actorPoses = driving.scenario.targetsToEgo(actors, egoCar);
            posesOnBus = sendToBus(obj,actorPoses,1,obj.pCurrentIndex);
            
            oIndx = 1;
            if obj.RoadBoundaries
                roads = driving.scenario.roadBoundariesToEgo(obj.pRoads, egoCar);
                varargout{oIndx} = roads(1:obj.pRoadBoundariesSize(1),1:obj.pRoadBoundariesSize(2));
                oIndx = oIndx + 1;
            end
            
            if obj.LaneBoundaries
                lbStruct = laneBoundaries(obj,egoCar);
                varargout{oIndx} = sendToBus(obj,lbStruct,2,obj.pCurrentIndex);
                oIndx = oIndx + 1;
            end
            
            if obj.CurrentLane || obj.NumLanes
                [currentLane,~,rsIndex] = getCurrentLane(obj,egoCar);
                if obj.CurrentLane
                    varargout{oIndx} = currentLane;
                    oIndx = oIndx + 1;
                end
                if obj.NumLanes
                    numMarkings = reshape(obj.pRoadNetwork.NumMarkings(rsIndex),1,1);
                    varargout{oIndx} = numMarkings-1;
                    oIndx = oIndx + 1;
                end
            end
            
            if obj.LaneMarkings
                lmv = driving.scenario.laneMarkingsToEgo(obj.pLaneMarkingVertices,egoCar);
                lmStruct = struct('LaneMarkingVertices',lmv,...
                                  'LaneMarkingFaces',obj.pLaneMarkingFaces);
                varargout{oIndx} = lmStruct;
            end            
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            
            % Reread the actors data from the file
            readActorsDataFromFile(obj);
            
            % Initialize the time
            if coder.target('MATLAB')
                obj.pCurrentTime = str2double(get_param(bdroot,'StartTime'));
            else
                obj.pCurrentTime = 0;
            end
            obj.pCurrentIndex = 1;
        end

        function validatePropertiesImpl(obj)
            % Validate related or interdependent property values
            validateattributes(obj.LaneBoundaryDistance,{'numeric'}, ...
                {'real','finite','vector','>=',0,'<=',500},'helperScenarioReader','LaneBoundaryDistance');
        end

        function flag = isInactivePropertyImpl(obj,prop)
            % Return false if property is visible based on object 
            % configuration, for the command line and System block dialog
            
            flag = isInactivePropertyImpl@driving.internal.SimulinkBusUtilities(obj,prop);
            hasActor = strcmpi(obj.EgoActorSource,'Input port');
            
            if strcmp(prop,'EgoActorID') && hasActor
                flag = true;
            end
            
            if strcmp(prop,'AllBoundaries')
                flag = ~obj.LaneBoundaries;
            end
            
            if strcmp(prop,'LaneBoundaryDistance')
                flag = ~obj.LaneBoundaries;
            end
            
            if strcmp(prop,'LaneBoundaryLocation')
                flag = ~obj.LaneBoundaries;
            end
            
            if ~isSourceBlock(obj) && ...
                    (strcmp(prop,'BusName2Source') || strcmp(prop,'BusName2') || ...
                    strcmp(prop,'BusName3Source') || strcmp(prop,'BusName3'))
                flag = true;
            else
                if strcmp(obj.BusName2Source,'Auto') && strcmp(prop,'BusName2')
                    flag = true;
                end
                if strcmp(obj.BusName3Source,'Auto') && strcmp(prop,'BusName3')
                    flag = true;
                end
            end
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@driving.internal.SimulinkBusUtilities(obj);

            % Set private and protected properties
            s.pActors               = obj.pActors;
            s.pRoads                = obj.pRoads;
            s.pCurrentTime          = obj.pCurrentTime;
            s.pCurrentIndex         = obj.pCurrentIndex;
            s.pHasEgoActor          = obj.pHasEgoActor;
            s.pMaxIndex             = obj.pMaxIndex;
            s.pRoadBoundariesSize   = obj.pRoadBoundariesSize;
            s.pRoadNetwork          = obj.pRoadNetwork;
            s.pLaneMarkingVertices  = obj.pLaneMarkingVertices;
            s.pLaneMarkingFaces     = obj.pLaneMarkingFaces;
            s.pLaneBoundariesSize   = obj.pLaneBoundariesSize;
        end

        function status = isEndOfData(obj)
            % Return true if end of data has been reached
            status = (obj.pCurrentIndex == obj.pMaxIndex);
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            obj.pActors             = s.pActors;
            obj.pRoads              = s.pRoads;
            obj.pCurrentTime        = s.pCurrentTime;
            obj.pCurrentIndex       = s.pCurrentIndex;
            obj.pHasEgoActor        = s.pHasEgoActor;
            obj.pMaxIndex           = s.pMaxIndex;
            obj.pRoadBoundariesSize = s.pRoadBoundariesSize;
            obj.pRoadNetwork        = s.pRoadNetwork;
            obj.pLaneMarkingVertices= s.pLaneMarkingVertices;
            obj.pLaneMarkingFaces   = s.pLaneMarkingFaces;
            obj.pLaneBoundariesSize = s.pLaneBoundariesSize;

            % Set public properties and states
            loadObjectImpl@driving.internal.SimulinkBusUtilities(obj,s,wasLocked);
        end

        %% Simulink functions
        function ds = getDiscreteStateImpl(~)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function validateInputsImpl(obj,varargin)
            % Validate inputs to the step method at initialization
            if strcmpi(obj.EgoActorSource, 'Input port') % Ego actor comes from input
                egoActor = varargin{1};
                validateattributes(egoActor,{'struct'},{'scalar'},'helperScenarioReader','Ego actor input');
                expectedFields = {'ActorID','Position','Velocity','Roll','Pitch','Yaw','AngularVelocity'};
                expectedNumels = [1,3,3,1,1,1,3];
                for i=1:numel(expectedFields)
                    coder.internal.errorIf(~isfield(egoActor,expectedFields{i}),...
                        ['Expected ego actor to have field ', expectedFields{i}]);
                    validateattributes(egoActor.(expectedFields{i}), {'numeric'},...
                        {'numel',expectedNumels(i)},'helperScenarioReader', ['Ego actor',expectedFields{i}]);
                end
            end
        end

        function flag = isInputSizeLockedImpl(~,~)
            % Return true if input size is not allowed to change while
            % system is running
            flag = true;
        end

        function num = getNumInputsImpl(obj)
            % Define total number of inputs for system with optional inputs
            num = 0;
            if strcmpi(obj.EgoActorSource, 'Input port')
                num = 1;
            end
        end

        function num = getNumOutputsImpl(obj)
            % Define total number of outputs for system with optional
            % outputs
            num = 1;
            if obj.RoadBoundaries
                num = num + 1;
            end
            if obj.LaneBoundaries
                num = num + 1;
            end
            if obj.CurrentLane
                num = num + 1;
            end
            if obj.NumLanes
                num = num + 1;
            end
            if obj.LaneMarkings
                num = num + 1;
            end
        end

        function [out,varargout] = getOutputSizeImpl(obj)
            % Return size for each output port
            out = [1 1];
            varargout = cell(1,sum([obj.RoadBoundaries obj.LaneBoundaries ...
                obj.CurrentLane obj.NumLanes obj.LaneMarkings]));
            oIndx = 1;
            if obj.RoadBoundaries
                readRoadBoundriesFromFile(obj);
                ego = struct('Position',[0 0 0],'Yaw',0,'Pitch',0,'Roll',0);
                rbEgo = driving.scenario.roadBoundariesToEgo(obj.pRoads, ego);
                rbSize = size(rbEgo);
                varargout{oIndx} = rbSize; 
                oIndx = oIndx + 1;
            end
            if obj.LaneBoundaries
                varargout{oIndx} = [1 1];
                oIndx = oIndx + 1;
            end
            if obj.CurrentLane
                varargout{oIndx} = [1 1];
                oIndx = oIndx + 1;
            end
            if obj.NumLanes
                varargout{oIndx} = [1 1];
                oIndx = oIndx + 1;
            end
            if obj.LaneMarkings
                varargout{oIndx} = [1 1];
            end
        end

        function [out, varargout] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            [out,busTypeLaneBoundaries,busTypeLaneMarkings] = getOutputDataTypeImpl@driving.internal.SimulinkBusUtilities(obj);
            
            % Set the simulation to stop at the latest time stamp or
            % earlier while keeping the Dirty flag state
            lastTime = obj.pActors(end).SimulationTime;
            stopTime = str2double(get_param(bdroot,'StopTime'));
            epsilon = 1e-5;
            if lastTime<(stopTime-epsilon)
                Simulink.output.error(['Simulation stop time must not be ',...
                    'greater than the last time stamp of actor poses data ',...
                    'in the recorded file, which is ', num2str(lastTime)]);
            end
            varargout = cell(1,sum([obj.RoadBoundaries obj.LaneBoundaries ...
                obj.CurrentLane obj.NumLanes obj.LaneMarkings]));
            oIndx = 1;
            if obj.RoadBoundaries
                varargout{oIndx} = 'double';
                oIndx = oIndx + 1;
            end
            if obj.LaneBoundaries
                varargout{oIndx} = busTypeLaneBoundaries;
                oIndx = oIndx + 1;
            end
            if obj.CurrentLane
                varargout{oIndx} = 'double';
                oIndx = oIndx + 1;
            end
            if obj.NumLanes
                varargout{oIndx} = 'double';
                oIndx = oIndx + 1;
            end
            if obj.LaneMarkings
                varargout{oIndx} = busTypeLaneMarkings;
            end
        end

        function [out, varargout] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = false;
            varargout = cell(1,sum([obj.RoadBoundaries obj.LaneBoundaries ...
                obj.CurrentLane obj.NumLanes obj.LaneMarkings]));
            oIndx = 1;
            if obj.RoadBoundaries
                varargout{oIndx} = false;
                oIndx = oIndx + 1;
            end
            if obj.LaneBoundaries
                varargout{oIndx} = false;
                oIndx = oIndx + 1;
            end
            if obj.CurrentLane
                varargout{oIndx} = false;
                oIndx = oIndx + 1;
            end
            if obj.NumLanes
                varargout{oIndx} = false;
                oIndx = oIndx + 1;
            end
            if obj.LaneMarkings
                varargout{oIndx} = false;
            end
        end

        function [out, varargout] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = true;
            varargout = cell(1,sum([obj.RoadBoundaries obj.LaneBoundaries ...
                obj.CurrentLane obj.NumLanes obj.LaneMarkings]));
            oIndx = 1;
            if obj.RoadBoundaries
                varargout{oIndx} = false;
                oIndx = oIndx + 1;
            end
            if obj.LaneBoundaries
                varargout{oIndx} = true;
                oIndx = oIndx + 1;
            end
            if obj.CurrentLane
                varargout{oIndx} = true;
                oIndx = oIndx + 1;
            end
            if obj.NumLanes
                varargout{oIndx} = true;
                oIndx = oIndx + 1;
            end
            if obj.LaneMarkings
                varargout{oIndx} = true;
            end
        end
        
        function readActorsDataFromFile(obj)
            % Try to load the file name. Error out if the file does not
            % exist or if it does not contain the expected format of
            % recorded actors data
            s = coder.load(obj.ScenarioFileName);
            
            % Search for the field that has the recorded data format
            validateattributes(s, {'struct'}, {'nonempty'},'ScenarioReader');
            expFields = {'SimulationTime','ActorPoses'};
            flag = checkStructForFields(obj, s, expFields);
            foundActors = false;
            if flag
                foundActors = true;
                obj.pActors = s;
            else % Maybe the actors are a field inside s
                fields = fieldnames(s);
                for i = 1:numel(fields)
                    flag = checkStructForFields(obj, s.(fields{i}), expFields);
                    if flag
                        foundActors = true;
                        obj.pActors = s.(fields{i});
                        break
                    end
                end
            end
            obj.pMaxIndex = numel(obj.pActors);
            if ~foundActors % helper object: no need for a message catalog
                error(['Couldn''t find actor data in the file ', obj.ScenarioFileName])
            end
        end
        
        function readRoadBoundriesFromFile(obj)
            % Try to load the file name. Error out if the file does not
            % exist or if it does not contain the expected format of
            % recorded actors data
            s = coder.load(obj.ScenarioFileName);
            
            % Search for the field that has the recorded data format
            validateattributes(s, {'struct'}, {'nonempty'},'ScenarioReader');
            expFields = {'RoadBoundaries'};
            flag = checkStructForFields(obj, s, expFields);
            foundRoads = false;
            if flag
                foundRoads = true;
                roads = s.RoadBoundaries;
            else % Maybe the actors are a field inside s
                fields = fieldnames(s);
                for i = 1:numel(fields)
                    flag = checkStructForFields(obj, s.(fields{i}), expFields);
                    if flag
                        foundRoads = true;
                        roads = s.(fields{i});
                        break
                    end
                end
            end
            if ~foundRoads % helper object: no need for a message catalog
                error(['Couldn''t find road boundaries data in the file ', obj.ScenarioFileName])
            else
                if isstruct(roads)
                    r = struct2cell(roads);
                    numRoads = numel(r);
                    obj.pRoads = reshape(r,1,numRoads);
                elseif iscell(roads)
                    obj.pRoads = roads;
                else
                    obj.pRoads = {roads};
                end
            end
            egoCar = helperScenarioReader.defaultActorPose;
            roads = driving.scenario.roadBoundariesToEgo(obj.pRoads, egoCar);
            obj.pRoadBoundariesSize = size(roads);
        end
        
        function s = readLaneMarkingsFromFile(obj)
            % Try to load the file name. Error out if the file does not
            % exist or if it does not contain the expected format of
            % recorded actors data
            s = coder.load(obj.ScenarioFileName);
            
            % Search for the field that has the recorded data format
            validateattributes(s, {'struct'}, {'nonempty'},'ScenarioReader');
            expFields = {'LaneMarkingVertices','LaneMarkingFaces'};
            flag = checkStructForFields(obj, s, expFields);
            foundMarkings = false;
            if flag
                foundMarkings = true;
                obj.pLaneMarkingVertices = s.LaneMarkingVertices;
                obj.pLaneMarkingFaces    = s.LaneMarkingFaces;
            end
            if ~foundMarkings % helper object: no need for a message catalog
                error(['Couldn''t find lane markings in the file ', obj.ScenarioFileName])
            end
        end
        
        function readRoadNetworkFromFile(obj)
            % Try to load the file name. Error out if the file does not
            % exist or if it does not contain the expected format of
            % recorded actors data
            s = coder.load(obj.ScenarioFileName);
            
            % Search for the field that has the recorded data format
            validateattributes(s, {'struct'}, {'nonempty'},'ScenarioReader');
            expFields = {'RoadNetwork'};
            flag = checkStructForFields(obj, s, expFields);
            foundMarkings = false;
            if flag
                foundMarkings = true;
                obj.pRoadNetwork = s.RoadNetwork;
                % Road network cannot be empty when outputting lane
                % boundaries, current lane, and number of lanes.
                if isempty(obj.pRoadNetwork)
                    error(['Lanes are not specified for this scenario: ', obj.ScenarioFileName])
                end
                if ~obj.AllBoundaries
                    obj.pLaneBoundariesSize = [2 1];
                else
                    if strcmp(obj.LaneBoundaryLocation,'center')
                        mbLength = size(obj.pRoadNetwork.CenterLaneBoundaryLocation,2);
                    else
                        mbLength = size(obj.pRoadNetwork.InnerLaneBoundaryLocation,2);
                    end
                    obj.pLaneBoundariesSize = [mbLength 1];
                end
            end
            if ~foundMarkings % helper object: no need for a message catalog
                error(['Couldn''t find road network in the file ', obj.ScenarioFileName])
            end
        end
        
        %---------------------------------
        % Simulink bus propagation methods
        %---------------------------------
        function [out, argsToBus] = defaultOutput(obj,busIndx)
        % Default output that will be placed on the bus. argsToBus are any
        % additional inputs that will be passed when sendToBus is called.
            switch busIndx
                case 1
                    readActorsDataFromFile(obj);
                    numActors = numel(obj.pActors(1).ActorPoses) - strcmpi(obj.EgoActorSource, 'Auto');
                    numActors = max(numActors,1);
                    actorStruct = obj.pActors(1).ActorPoses(1);
                    actorPoses = repmat(actorStruct, [numActors,1]);
                    out = actorPoses;
                    argsToBus = {1};
                case 2
                    if obj.LaneBoundaries
                        readRoadNetworkFromFile(obj);
                        out = defaultLaneBoundaries(obj);
                    else
                        numPts = numel(obj.LaneBoundaryDistance);
                        out = struct('Coordinates',NaN(numPts,3),...
                            'Curvature', NaN(numPts,1), ...
                            'CurvatureDerivative', NaN(numPts,1), ...
                            'HeadingAngle', NaN, ...
                            'LateralOffset', NaN, ...
                            'BoundaryType', uint8(0), ...
                            'Strength', NaN, ...
                            'Width', NaN, ...
                            'Length', NaN, ...
                            'Space', NaN);
                    end
                    argsToBus = {};
                case 3
                    if obj.LaneMarkings
                        s = readLaneMarkingsFromFile(obj);
                        out.LaneMarkingVertices = s.LaneMarkingVertices;
                        out.LaneMarkingFaces = s.LaneMarkingFaces;
                    else
                        out.LaneMarkingVertices = [0 0 0];
                        out.LaneMarkingFaces = 1;
                    end
                    argsToBus = {};
            end
        end
        
        function outStruct = sendToBus(obj, inStruct, busIndx, varargin)
        % Converts the output, out, from the defaultOutput method above to
        % a struct or array of structs which will be sent out on the
        % Simulink bus. A typical output struct has the following
        % structure:
        %   Num<Name>:  The number of valid elements in the output, where
        %               Name describes the type of output, such as
        %               "Detections" or "Tracks"
        %   <Name>:     A struct array formed from the output where
        %               output can be a cell array of objects to be
        %               converted to an array of structs to be placed on
        %               the bus.
            switch busIndx
                case 1
                    index = varargin{1};
                    if isempty(inStruct)
                        outActorPoses = helperScenarioReader.defaultActorPose;
                        numActors = 0;
                    else
                        outActorPoses = inStruct;
                        numActors = numel(inStruct);
                    end
                    outStruct = struct('NumActors', numActors, ...
                        'Time', obj.pActors(index).SimulationTime, ...
                        'Actors', outActorPoses);
                case 2
                    outStruct = struct('NumLaneBoundaries', numel(inStruct), ...
                        'Time', obj.pCurrentTime, ...
                        'LaneBoundaries', inStruct);
                case 3
                    outStruct = inStruct;
            end
        end
        
        function icon = getIconImpl(~)
            % Define icon for System block
            icon = {'Scenario';'Reader'};
        end

        function varargout = getInputNamesImpl(obj)
            % Return input port names for System block
            varargout = cell(1,nargout);
            if strcmpi(obj.EgoActorSource,'Input port')
                varargout{1} = sprintf('Ego Actor');
            end
        end

        function [name, varargout] = getOutputNamesImpl(obj)
            % Return output port names for System block
            name = 'Actors';
            varargout = cell(1,sum([obj.RoadBoundaries obj.LaneMarkings]));
            oIndx = 1;
            if obj.RoadBoundaries
                varargout{oIndx} = sprintf('Roads');
                oIndx = oIndx + 1;
            end
            if obj.LaneBoundaries
                varargout{oIndx} = sprintf('Lane Boundaries');
                oIndx = oIndx + 1;
            end
            if obj.CurrentLane
                varargout{oIndx} = sprintf('Current Lane');
                oIndx = oIndx + 1;
            end
            if obj.NumLanes
                varargout{oIndx} = sprintf('Number of Lanes');
                oIndx = oIndx + 1;
            end
            if obj.LaneMarkings
                varargout{oIndx} = sprintf('Lane Markings');
            end
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(...
                'Title', 'ScenarioReader', ...
                'Text', getHeaderText());
        end

        function groups = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            groupScenario = matlab.system.display.Section(...
                'Title','Scenario', ...
                'PropertyList', {'ScenarioFileName', 'EgoActorSource', ...
                    'EgoActorID', 'RoadBoundaries'});
            groupLanes = matlab.system.display.Section(...
                'Title','Lanes', ...
                'PropertyList', {'LaneBoundaries', 'AllBoundaries', ...
                'LaneBoundaryDistance','LaneBoundaryLocation',...
                'CurrentLane','NumLanes','LaneMarkings'});
            busUtil = getPropertyGroupsImpl@driving.internal.SimulinkBusUtilities;
            busPropList = busUtil.PropertyList;
            busPropList = [busPropList {'BusName2Source','BusName2','BusName3Source','BusName3'}];
            busUtil.PropertyList = busPropList;
            groups = [groupScenario,groupLanes,busUtil];
        end
        
        % Default actor pose
        function actorPose = defaultActorPose
            actorPose = struct('ActorID',1, 'Position', [0 0 0], ...
                'Velocity', [0 0 0], 'Roll', 0, 'Pitch', 0, 'Yaw', 0, ...
                'AngularVelocity', [0 0 0]);
        end
    end
    
    methods(Access = protected)
        %% Lanes related functions        
        function lb = defaultLaneBoundaries(obj)
            numPts = numel(obj.LaneBoundaryDistance);
            numBoundaries = obj.pLaneBoundariesSize(1);
            bCoordinates = cell(numBoundaries,1);
            bCurvature = cell(numBoundaries,1);
            bCurvatureDerivative = cell(numBoundaries,1);
            for kndx = 1:numBoundaries
                bCoordinates{kndx} = NaN(numPts,3);
                bCurvature{kndx} = NaN(numPts,1);
                bCurvatureDerivative{kndx} = NaN(numPts,1);
            end
            lb = struct('Coordinates',bCoordinates,...
                'Curvature', bCurvature, ...
                'CurvatureDerivative', bCurvatureDerivative, ...
                'HeadingAngle', NaN, ...
                'LateralOffset', NaN, ...
                'BoundaryType', uint8(0), ...
                'Strength', NaN, ...
                'Width', NaN, ...
                'Length', NaN, ...
                'Space', NaN);
        end
        
        function lb = laneBoundaries(obj,ego)
            % Return the lane boundaries of the ego car
            % Find the current lane and related information
            [currentLane,isAlongRoad,rsIndex,rtIndex,rtv,fwdVector,upVector,AP] = getCurrentLane(obj,ego);
            % Get the lane boundaries
            if ~isnan(currentLane)
                % Distance traveled from the beginning of the road segment to this tile
                rsDistTrav = obj.pRoadNetwork.DistanceTraveled(rsIndex,:);
                dt = rsDistTrav(rtIndex);
                % Add how far the actor is from the bottom of the tile to
                % this distance to get the distance from which to obtain
                % the lane boundaries.
                A = rtv(1,:);
                B = rtv(2,:);
                u = diff([A;B]);
                dt = dt + norm(cross(AP,u))/norm(u);
                dt = max(0,min(rsDistTrav(end),dt));
                lb = getClothoidLaneBoundaryModel(obj,rsIndex,fwdVector,upVector,ego.Position,dt,isAlongRoad,currentLane);
            else
                lb = defaultLaneBoundaries(obj);
            end
        end
        
        function lb = getClothoidLaneBoundaryModel(obj,rsIndex,egoFwdVector,egoUpVector,egoPosition,dist,isAlongRoad,currentLane)
            %GETCLOTHOIDLANEBOUNDARYMODEL Get the clothoid lane boundaries
            distFromEgo = obj.LaneBoundaryDistance;
            isInnerBoundary = strcmp(obj.LaneBoundaryLocation,'inner');
            % Get the yr, marker type, width, and strength.
            numMarkings = obj.pRoadNetwork.NumMarkings(rsIndex);
            colIndex = 1:numMarkings;
            lmType = obj.pRoadNetwork.LaneMarkingType(rsIndex,colIndex);
            lmWidth = obj.pRoadNetwork.LaneMarkingWidth(rsIndex,colIndex);
            lmStrength = obj.pRoadNetwork.LaneMarkingStrength(rsIndex,colIndex);
            lmLength = obj.pRoadNetwork.LaneMarkingLength(rsIndex,colIndex);
            lmSpace = obj.pRoadNetwork.LaneMarkingSpace(rsIndex,colIndex);
            if isInnerBoundary
                colIndex = 1:2*numMarkings-2;
                yr = obj.pRoadNetwork.InnerLaneBoundaryLocation(rsIndex,colIndex);
                leftIndex = 2*currentLane-1;
                rightIndex = 2*currentLane;
                numBoundaries = numel(yr);
                lmTypeExpanded = ones(1,numBoundaries);
                lmWidthExpanded = ones(1,numBoundaries);
                lmStrengthExpanded = ones(1,numBoundaries);
                lmLengthExpanded = ones(1,numBoundaries);
                lmSpaceExpanded = ones(1,numBoundaries);
                % Expand the type, width, and strength for each of the inner
                % boundaries.
                mndx = 1;
                for kndx = 1:numBoundaries/2
                    % Left boundary
                    lmTypeExpanded(mndx) = lmType(kndx);
                    lmWidthExpanded(mndx) = lmWidth(kndx);
                    lmStrengthExpanded(mndx) = lmStrength(kndx);
                    lmLengthExpanded(mndx) = lmLength(kndx);
                    lmSpaceExpanded(mndx) = lmSpace(kndx);
                    mndx = mndx + 1;
                    % Right Boundary
                    lmTypeExpanded(mndx) = lmType(kndx+1);
                    lmWidthExpanded(mndx) = lmWidth(kndx+1);
                    lmStrengthExpanded(mndx) = lmStrength(kndx+1);
                    lmLengthExpanded(mndx) = lmLength(kndx+1);
                    lmSpaceExpanded(mndx) = lmSpace(kndx+1);
                    mndx = mndx + 1;
                end
            else
                yr = obj.pRoadNetwork.CenterLaneBoundaryLocation(rsIndex,colIndex);
                leftIndex = currentLane;
                rightIndex = currentLane+1;
                numBoundaries = numel(yr);
                lmTypeExpanded = lmType;
                lmWidthExpanded = lmWidth;
                lmStrengthExpanded = lmStrength;
                lmLengthExpanded = lmLength;
                lmSpaceExpanded = lmSpace;
            end
            % Report everything relative to the ego.
            if ~isAlongRoad
                lmTypeExpanded = fliplr(lmTypeExpanded);
                lmWidthExpanded = fliplr(lmWidthExpanded);
                lmStrengthExpanded = fliplr(lmStrengthExpanded);
                lmLengthExpanded = fliplr(lmLengthExpanded);
                lmSpaceExpanded = fliplr(lmSpaceExpanded);
            end
                        
            % Create the default boundaries of exact size expected by
            % outputs. Then populate them with what information is
            % available for the current road segment.
            lb = defaultLaneBoundaries(obj);
            if obj.AllBoundaries
                 % We are returning all the boundaries
                 for sndx = 1:numBoundaries
                     lb(sndx).BoundaryType = reshape(uint8(lmTypeExpanded(sndx)),1,1);
                     lb(sndx).Width = reshape(lmWidthExpanded(sndx),1,1);
                     lb(sndx).Strength = reshape(lmStrengthExpanded(sndx),1,1);
                     lb(sndx).Length = reshape(lmLengthExpanded(sndx),1,1);
                     lb(sndx).Space = reshape(lmSpaceExpanded(sndx),1,1);
                 end
            else
                % We are returning only the left and right boundaries
                % Left boundary
                lb(1).BoundaryType = reshape(uint8(lmTypeExpanded(leftIndex)),1,1);
                lb(1).Width = reshape(lmWidthExpanded(leftIndex),1,1);
                lb(1).Strength = reshape(lmStrengthExpanded(leftIndex),1,1);
                lb(1).Length = reshape(lmLengthExpanded(leftIndex),1,1);
                lb(1).Space = reshape(lmSpaceExpanded(leftIndex),1,1);
                
                % Right boundary
                lb(2).BoundaryType = reshape(uint8(lmTypeExpanded(rightIndex)),1,1);
                lb(2).Width = reshape(lmWidthExpanded(rightIndex),1,1);
                lb(2).Strength = reshape(lmStrengthExpanded(rightIndex),1,1);
                lb(2).Length = reshape(lmLengthExpanded(rightIndex),1,1);
                lb(2).Space = reshape(lmSpaceExpanded(rightIndex),1,1);
            end           
            
            % Determine the clothoid lane boundaries
            maxDist = reshape(obj.pRoadNetwork.DistanceTraveled(rsIndex,obj.pRoadNetwork.DistanceTraveledLength(rsIndex)),1,1);
            minDist = reshape(obj.pRoadNetwork.DistanceTraveled(rsIndex,1),1,1);
            % Determine the xr vector for the given dist and forwardOffsets
            distFromEgo = distFromEgo(:); % xr must be a column vector
            % Need to return boundaries only at the specified boundary
            % locations.
            numPoints = length(distFromEgo);
            % Always include the ego position as the first xr value.
            if ~(distFromEgo(1) == 0)
                distFromEgo = [0;distFromEgo];
            end
            
            numRC = obj.pRoadNetwork.NumRoadCenters(rsIndex);
            colIndex = 1:numRC;
            colIndex1 = 1:numRC-1;
            hcd = (obj.pRoadNetwork.hcd(rsIndex,colIndex)).';
            hl = (obj.pRoadNetwork.hl(rsIndex,colIndex1)).';
            hip = (obj.pRoadNetwork.hip(rsIndex,colIndex)).';
            course = (obj.pRoadNetwork.course(rsIndex,colIndex)).';
            k0 = (obj.pRoadNetwork.k0(rsIndex,colIndex1)).';
            k1 = (obj.pRoadNetwork.k1(rsIndex,colIndex1)).';
            
            % Using dist as an initial estimate, hunt for the "true"
            % distance traveled by seeking the local minimum distance to
            % the curve starting at this value.
            idx = discretize(obj, dist, hcd);
            [~,dist] = matlabshared.tracking.internal.scenario.fresnelgcp( ...
                complex(egoPosition(1),egoPosition(2))-hip(idx), ...
                (k1(idx)-k0(idx))/hl(idx),k0(idx),course(idx),dist-hcd(idx));
            dist = dist+hcd(idx);
            
            dist = repmat(dist,size(distFromEgo,1),size(distFromEgo,2));
            if isAlongRoad
                xr = dist+distFromEgo;
            else
                xr = dist-distFromEgo;
            end
            % Trim to valid distances
            coder.varsize('xr');
            xr(xr < minDist) = [];
            xr(xr > maxDist) = [];
            % Initialize model parameter values to NaNs
            coordinates = NaN(numPoints,3,numBoundaries);
            curvature = NaN(numPoints,numBoundaries);
            curvatureDerivative = NaN(numPoints,numBoundaries);
            headingAngle = NaN(1,numBoundaries);
            offset = NaN(1,numBoundaries);
                        
            coder.varsize('vpp');
            vcoefRow = 1:obj.pRoadNetwork.NumRowsVppCoefs(rsIndex);
            vcoefCol = 1:obj.pRoadNetwork.NumColsVppCoefs(rsIndex);
            vpp = struct('form','pp',...
                         'breaks',obj.pRoadNetwork.vppBreaks(rsIndex,colIndex),...
                         'coefs',obj.pRoadNetwork.vppCoefs(vcoefRow,vcoefCol,rsIndex),...
                         'pieces',obj.pRoadNetwork.vppPieces(rsIndex),...
                         'order',obj.pRoadNetwork.vppOrder(rsIndex),...
                         'dim',obj.pRoadNetwork.vppDim(rsIndex));
            coder.varsize('bpp'); 
            bcoefRow = 1:obj.pRoadNetwork.NumRowsBppCoefs(rsIndex);
            bcoefCol = 1:obj.pRoadNetwork.NumColsBppCoefs(rsIndex);
            bpp = struct('form','pp',...
                         'breaks',obj.pRoadNetwork.bppBreaks(rsIndex,colIndex),...
                         'coefs',obj.pRoadNetwork.bppCoefs(bcoefRow,bcoefCol,rsIndex),...
                         'pieces',obj.pRoadNetwork.bppPieces(rsIndex),...
                         'order',obj.pRoadNetwork.bppOrder(rsIndex),...
                         'dim',obj.pRoadNetwork.bppDim(rsIndex));
            
            if ~(dist(1) > maxDist) && ~isempty(xr)
                [center,left,kappa,dkappa,headingVector] = roadDistanceToCenterAndLeft(obj,xr, ...
                    hcd, hl, hip, course, k0, k1, vpp, bpp);
                % Report lane marker heading angle relative to the ego car heading
                courseV = headingVector(1)*conj(complex(egoFwdVector(1),egoFwdVector(2)));
                relativeHeading = rad2deg(atan(imag(courseV)/real(courseV)));
                headingAngle = ones(1,numBoundaries).*relativeHeading;
                numPointsToFill = length(kappa);
                
                % Scenario to Ego Rotator
                egoLeft = cross(egoUpVector,egoFwdVector);
                R = [egoFwdVector; egoLeft; egoUpVector]';
                
                bIndx = 1;
                if isAlongRoad
                    for i=1:numBoundaries
                        % to find (xr, yr) -> (xp, yp, zp) add the unit vector in the left
                        % direction scaled by yr to the road center.
                        curr_b = center + left .* yr(i);
                        % translate and rotate to world coordinates
                        egoPos = egoPosition;
                        curr_b = (curr_b-repmat(egoPos,size(curr_b,1),1)) * R;
                        
                        for gndx = 1:numPointsToFill
                            coordinates(gndx,:,bIndx) = curr_b(gndx,:);
                        end
                        bIndx = bIndx + 1;
                    end
                else
                    for i=numBoundaries:-1:1
                        % to find (xr, yr) -> (xp, yp, zp) add the unit vector in the left
                        % direction scaled by yr to the road center.
                        curr_b = center + left .* yr(i);
                        % translate and rotate to world coordinates
                        egoPos = egoPosition;
                        curr_b = (curr_b-repmat(egoPos,size(curr_b,1),1)) * R;
                        
                        for gndx = 1:numPointsToFill
                            coordinates(gndx,:,bIndx) = curr_b(gndx,:);
                        end
                        bIndx = bIndx + 1;
                    end
                end
                    
                % Determine the offset
                for kndx = 1:numBoundaries
                    bdry_start = coordinates(1,:,kndx);
                    % Offset from the car is the Y value of the boundary
                    offset(kndx) = bdry_start(2);
                end
                radiusOfCurvatureAtCenter = 1./kappa;
                bIndx = 1;
                if isAlongRoad
                    for i=1:numBoundaries
                        curvature(1:numPointsToFill,bIndx) = 1./ (radiusOfCurvatureAtCenter + yr(i));
                        curvatureDerivative(1:numPointsToFill,bIndx) = dkappa./((yr(i).*kappa+1).^2);
                        bIndx = bIndx + 1;
                    end
                else
                    for i=numBoundaries:-1:1
                        curvature(1:numPointsToFill,bIndx) = 1./ (radiusOfCurvatureAtCenter + yr(i));
                        curvatureDerivative(1:numPointsToFill,bIndx) = dkappa./((yr(i).*kappa+1).^2);
                        bIndx = bIndx + 1;
                    end
                end
            end
            
            % Update the coordinates, curvature, curvature derivative,
            % heading angle, and offset.
            if obj.AllBoundaries
                % All boundaries
                for sndx = 1:numBoundaries
                    lb(sndx).Coordinates = reshape(coordinates(:,:,sndx),numPoints,3);
                    lb(sndx).Curvature = reshape(curvature(:,sndx),numPoints,1);
                    lb(sndx).CurvatureDerivative = reshape(curvatureDerivative(:,sndx),numPoints,1);
                    lb(sndx).HeadingAngle = reshape(headingAngle(sndx),1,1);
                    lb(sndx).LateralOffset = reshape(offset(sndx),1,1);
                end
            else
                % Left
                lb(1).Coordinates = reshape(coordinates(:,:,leftIndex),numPoints,3);
                lb(1).Curvature = reshape(curvature(:,leftIndex),numPoints,1);
                lb(1).CurvatureDerivative = reshape(curvatureDerivative(:,leftIndex),numPoints,1);
                lb(1).HeadingAngle = reshape(headingAngle(leftIndex),1,1);
                lb(1).LateralOffset = reshape(offset(leftIndex),1,1);
                % Right
                lb(2).Coordinates = reshape(coordinates(:,:,rightIndex),numPoints,3);
                lb(2).Curvature = reshape(curvature(:,rightIndex),numPoints,1);
                lb(2).CurvatureDerivative = reshape(curvatureDerivative(:,rightIndex),numPoints,1);
                lb(2).HeadingAngle = reshape(headingAngle(rightIndex),1,1);
                lb(2).LateralOffset = reshape(offset(rightIndex),1,1);
            end
        end
        
        function [center, left, kappa, dkappa, dx_y] = roadDistanceToCenterAndLeft(obj,xr, hcd, hl, hip, course, k0, k1, vpp, bpp)       
            % find index/indices into table
            idx = discretize(obj, xr, hcd);

            % fetch clothoid segment at index and initial position.
            dkappa = (k1(idx)-k0(idx))./hl(idx);
            kappa0 = k0(idx);
            theta = course(idx);
            p0 = hip(idx);

            % get length and curvature into clothoid segment
            l = xr-hcd(idx);
            kappa = kappa0 + l.*dkappa;

            % get corresponding points in complex plane and derivative w.r.t. road length
            numL = length(l);
            x_y = zeros(numL,1).*complex(0);
            dx_y = zeros(numL,1).*complex(0);
            for kndx = 1:numL
                x_y(kndx) = matlabshared.tracking.internal.scenario.fresnelg(l(kndx), dkappa(kndx), kappa0(kndx), theta(kndx));
                dx_y(kndx) = matlabshared.tracking.internal.scenario.dfresnelg(l(kndx), dkappa(kndx), kappa0(kndx), theta(kndx));
            end

            % get elevation and derivative w.r.t road length
            zp = ppval(obj,vpp, xr);

            % get banking angles
            bank = ppval(obj,bpp, xr);

            % assemble the 3D positions of the road centers.  This corresponds to (xr, 0) in road coordinates.
            center = [real(x_y(:)+p0(:)) imag(x_y(:)+p0(:)) zp(:)];

            % assemble unit tangent to xy in xy plane (neglecting derivative of elevation)
            forward = [real(dx_y) imag(dx_y) zeros(length(x_y),1)];
            forward = forward ./ repmat(sqrt(sum(forward.^2,2)),1,size(forward,2));
            up = repmat([0 0 1],length(x_y),1);
            left = cross(up,forward,2);
            left = left ./ repmat(sqrt(sum(left.^2,2)),1,size(left,2));

            % apply bank angles
            left = [left(:,1).*cos(bank(:)) left(:,2).*cos(bank(:)) sin(bank(:))];
        end
        
        function [bins, edges] = discretize(~,x, edges)
            % discretize  Group numeric data into bins or categories.
            % BINS = discretize(X,EDGES) returns the indices of the bins that the
            %      elements of X fall into.  EDGES is a numeric vector that contains bin
            %      edges in monotonically increasing order. An element X(i) falls into
            %      the j-th bin if EDGES(j) <= X(i) < EDGES(j+1), for 1 <= j < N where
            %      N is the number of bins and length(EDGES) = N+1. The last bin includes
            %      the right edge such that it contains EDGES(N) <= X(i) <= EDGES(N+1). For
            %      out-of-range values where X(i) < EDGES(1) or X(i) > EDGES(N+1) or
            %      isnan(X(i)), BINS(i) returns NaN.
            bins = ones(length(x),1);
            for kndx = 1:length(x)
                for jndx = 1:length(edges)-1
                    if (x(kndx) >= edges(jndx)) && (x(kndx) < edges(jndx+1))
                        bins(kndx) = jndx;
                        break;
                    end
                end
            end
        end
        
        function v = ppval(~,pp,xx)
            % Evaluate piecewise polynomial
            %  obtain the row vector xs equivalent to XX
            sizexx = size(xx); lx = numel(xx); xs = reshape(xx,1,lx);
            
            % take apart PP
            pp = reshape(pp,1,1);
            l = reshape(pp.pieces,1,1); b = pp.breaks; c = pp.coefs;
            k = reshape(pp.order,1,1);
            
            % for each evaluation site, compute its breakpoint interval
            % (mindful of the possibility that xx might be empty)
            if lx
                [~,index] = histc(xs,[-inf,b(2:l),inf]);
            else
                index = ones(1,lx);
            end
            
            % adjust for troubles, like evaluation sites that are NaN or +-inf
            infxs = find(xs==inf); if ~isempty(infxs), index(infxs) = l; end
            nogoodxs = find(index==0);
            if ~isempty(nogoodxs), xs(nogoodxs) = NaN; index(nogoodxs) = 1; end
            
            % now go to local coordinates ...
            xs = xs-b(index);
            
            if length(sizexx)>1
                dd = []; 
            else
                dd = 1;
            end
            
            % ... and apply nested multiplication:
            v = c(index,1);
            for i=2:k
                v = xs(:).*v + c(index,i);
            end
            v = reshape(v,[dd,sizexx]);
        end
        
        function [currentLane,isAlongRoad,rsIndex,rtIndex,rtv,fwdVector,upVector,AP] = getCurrentLane(obj,ego)
            % Return the current lane information
            % Closest road tile
            [~,tileIndex] = min(sum((repmat(ego.Position,size(obj.pRoadNetwork.RoadTileCentroids,1),1) ...
                - obj.pRoadNetwork.RoadTileCentroids).^2,2));
            currentLane = NaN; % Must return a size [1 1]
            isAlongRoad = true;
            rsIndex = [];
            AP = [];
            rtIndex = [];
            rtv = [];
            fwdVector = [];
            upVector = [];
            % Get road segment of the tile
            tileIDs = obj.pRoadNetwork.TileID;
            for kndx = 1:size(tileIDs,1)
                rsIndex = kndx;
                tID = tileIDs(kndx,:);
                rtIndex = find(tID == tileIndex);
                if ~isempty(rtIndex)
                    break;
                end
            end
            if isempty(rtIndex)
                % Tile not found in the road segments
                return;
            end
            numMarkings = reshape(obj.pRoadNetwork.NumMarkings(rsIndex),1,1);
            numLanes = numMarkings-1;
            loc = reshape(obj.pRoadNetwork.LaneMarkingLocation(rsIndex,1:numMarkings),1,numMarkings);
            hasMarking = obj.pRoadNetwork.RoadTileHasLaneMarking(tileIndex);
            rtv = obj.pRoadNetwork.RoadTileVertices(:,:,tileIndex);
            rtv = rtv(1:4,:);
            R = matlabshared.tracking.internal.fusion.rotZ(ego.Yaw) ...
              * matlabshared.tracking.internal.fusion.rotY(ego.Pitch) ...
              * matlabshared.tracking.internal.fusion.rotX(ego.Roll);
            fwdVector = R(:,1)';
            upVector = R(:,3)';
            if ~isempty(loc) && hasMarking
                % Get distance from the left and right tile edges to the actor. The
                % tile vertices are numbered this way:
                %    (B)4 __ (D)3
                %        |__|
                %    (A)1    (C)2
                P = ego.Position;
                A = rtv(1,:);
                B = rtv(4,:);
                % Direction vector of line connecting A and B
                u = diff([A;B]);
                % Vector connecting A and P
                AP = diff([A;P]);
                % We calculate the distance to the actor by considering area of a
                % parallelogram sitting on the line u. The height of this parallelogram
                % is the perpendicular distance to the actor. This is obtained as:
                % d = |AP x u|/|u|
                distFromLeft = norm(cross(AP,u))/norm(u);
                C = rtv(2,:);
                D = rtv(3,:);
                % Direction vector of line connecting C and D
                u1 = diff([C;D]);
                % Vector connecting C and P
                CP = diff([C;P]);
                distFromRight = norm(cross(CP,u1))/norm(u1);
                % Determine if the car is traveling along the road or in the opposite
                % direction. Dot product is positive for vectors in the same general
                % direction.
                isAlongRoad = true;
                if dot(u,fwdVector) < 0
                    isAlongRoad = false;
                end
                roadWidth = reshape(obj.pRoadNetwork.RoadWidth(rsIndex),1,1);
                % One way to find if actor is off the road is to check its distance
                % from the left and right road edges and compare with road width.
                if distFromLeft > roadWidth || distFromRight > roadWidth
                    return;
                end
                % Get current lane of the actor
                indxLeft = find(loc < distFromLeft);
                if ~isempty(indxLeft)
                    indxLeft = indxLeft(end);
                else
                    return;
                end
                if indxLeft == length(loc)
                    % Return early if the actor is outside the road
                    return;
                end
                currentLane = indxLeft;
                % Report everything relative to the ego.
                if ~isAlongRoad
                    currentLane = numLanes - currentLane + 1;
                end
            end
        end
    end
end

function str = getHeaderText
str = sprintf([...
    'The Scenario Reader reads actor poses data saved using the ',...
    'drivingScenario record method and road boundary data saved as structs ',...
    'from the drivingScenario roadBoundaries method.\n\n', ...
    'For open loop simulation, the ego actor pose must be saved to the ',...
    'scenario file. Choose the ''Auto'' for the source of ego actor pose ',...
    'to specify the ego actor index in the recorded data.\n',...
    'For closed loop simulation, the ego actor pose can be provided from ',...
    'an input port. Choose the ''Input port'' for the source of the ego ',...
    'actor pose and pass a valid actor pose to it.']); 
end