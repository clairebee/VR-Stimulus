function MouseBallExp(replay_in, param, animal_in, com)
% Old inputs: (replay_in, offline_in, animal_in)
%---------------------------------------
% Usage:    MouseBallExp
%           MouseBallExp(replay_in, offline_in, animal_in)
%           MouseBallExp(1): To replay an experiment, 0: normal
%           MouseBallExp(x,1): To run/debug on computers that not
%           connected, 0: online
%           MouseBallExp(x,x,'animal'): animal name given in the command
%           line
% Adapted from original code written by Asli Ayaz and Aman Saleem
% AA 2009-12: virtual reality for training mice
% AS 2012-15: Current update is of 2015 (Aman Saleem).

% rigInfo : Rig related parameters (is an object)
% hwInfo  : Hardware objects (more related to IO)
% expInfo : Experiment related parameters
% runInfo : Variables that change across multiple functions of the program

% global TEXTURES;    % graphic textures

% global runInfo.TRIAL_COUNT;
% global blank_screen
% global rewardStartT;

% global STOPrewardStopT;
% global BASErewardStopT;
% global PASSrewardStopT;
% global ACTVrewardStopT;

% global oBeepBASE;
% global oBeepSTOP;
% global oBeepNoise;
% global oBeepWrong;

% global reward_active;
% global runTimeOut;

addpath('./data');
addpath('./gen');

runInfo =[];
% tag = checkTag; % User ID
% if strcmp(tag,'test')
%     tag = 'ABS';
% end
% if strcmp(tag,'void')
%     return
% end;
rigInfo = VRRigInfo;
rigInfo.comms = com;

if nargin<1
    expInfo.OFFLINE = 0;
    expInfo.REPLAY = 0;
else
    expInfo.REPLAY = replay_in;
    expInfo.OFFLINE = 0;
    if nargin >1
        expInfo.OFFLINE = 0;%offline_in;
    end
end

if expInfo.REPLAY
    SetDefaultDirs
end

dataDir = rigInfo.dirSave;
InitializeMatlabOpenGL;

Screen('Preference','VisualDebugLevel',3)

if ~expInfo.REPLAY
    if nargin<3
        expInfo.animalName = input('Enter animal name: ', 's');
    else
        expInfo.animalName = animal_in;
    end
else
    if nargin<3
        dir_list = dir(dataDir);
        animal_list = [];
        for n = 3:length(dir_list)
            animal_list = [animal_list, {dir_list(n).name}];
        end
        [index, ok1] = listdlg('PromptString', 'Select the mouse id:',...
            'SelectionMode','single', 'ListString', animal_list);
        if ~ok1
            error('No animal specified.');
            return;
        else
            expInfo.animalName = animal_list{index};
        end
    else
        expInfo.animalName = animal_in;
    end
    dir_list = dir([dataDir filesep expInfo.animalName]);
    date_list = [];
    for n = 3:length(dir_list)
        date_list = [date_list, {dir_list(n).name}];
    end
    [index, ok2] = listdlg('PromptString', 'Select the mouse id:',...
        'SelectionMode','single', 'ListString', date_list);
    if ~ok2
        error('No date specified.');
        return;
    else
        dateName = date_list{index};
        dir_list = dir([dataDir filesep expInfo.animalName filesep dateName]);
        trial_list = [];
        for n = 3:length(dir_list)
            trial_list = [trial_list, {dir_list(n).name}];
        end
        [index, ok3] = listdlg('PromptString', 'Select the mouse id:',...
            'SelectionMode','single', 'ListString', trial_list);
        if ~ok3
            error('No Trial specified.');
            return;
        else
            TrialName = trial_list{index};
            expInfo.OLD = load([dataDir filesep expInfo.animalName filesep dateName filesep TrialName]);
        end
    end
end

%% AS 03-10: saving to directory on zserver
expInfo.sessionName = 101;
expInfo.dateStr =  num2str(str2num(datestr(now, 'mmdd')));

expInfo.AnimalDir = fullfile(dataDir,expInfo.animalName);
if ~isdir(expInfo.AnimalDir), mkdir(expInfo.AnimalDir); end

expInfo.TheDir = fullfile(dataDir,expInfo.animalName,expInfo.dateStr);
if ~isdir(expInfo.TheDir), mkdir(expInfo.TheDir); end

if expInfo.REPLAY
    expInfo.sessionName = 201;
end

test = 1;

while test
    if exist([expInfo.TheDir filesep expInfo.animalName '_' expInfo.dateStr '_session_' num2str(expInfo.sessionName) '_trial001.mat'],'file')
        expInfo.sessionName = expInfo.sessionName + 1;
    else
        display(['***********SESSION NUMBER: ' num2str(expInfo.sessionName) '*************']);
        test = 0;
        expInfo.sessionName = num2str(expInfo.sessionName);
    end
end

expInfo.SESSION_NAME = [expInfo.TheDir filesep expInfo.animalName '_' expInfo.dateStr '_session_' expInfo.sessionName];

%% setting experimental params----------------------------------------------

if ~expInfo.REPLAY
    expInfo.EXP = param;
%     [~, expInfo.EXP] = SetExperimentParameters(expInfo.animalName, rigInfo);
    expInfo.EXP.w = (expInfo.EXP.b)*2; % should be the same as Ex..b2 - EXP.b1/2
         expInfo.EXP.b = expInfo.EXP.b*(1/3); % This is because of the geometric correction made       
         expInfo.EXP.h = expInfo.EXP.h/2;
         expInfo.EXP.tw = expInfo.EXP.tw/2;
         expInfo.EXP.c3 = expInfo.EXP.vh-expInfo.EXP.h;
         
    %JUL:to be moved where appropriate
    expInfo.EXP.CircularMaze = false;%true;
    if expInfo.EXP.CircularMaze
        expInfo.EXP.nbRewSites = 2;
        expInfo.EXP.BadLicksTimeOut = true;        
        expInfo.EXP.nTrialChange = 5;
        expInfo.EXP.rew_tol = 5;
        expInfo.EXP.rew_pos = (30/360 + [0/360;(0+180)/360])*expInfo.EXP.l;
        expInfo.EXP.textureFile = 'textures_hf_JuL';
        expInfo.EXP.CamCorrection = 10;
        expInfo.EXP.FpostRewardCue = false;
    else
        expInfo.EXP.nbRewSites = 1;
        expInfo.EXP.BadLicksTimeOut = false;
        expInfo.EXP.nTrialChange = 2;
        expInfo.EXP.CamCorrection = 0;
    end
    
%     EXP = eval(['setExperimentPars_' tag]);
else
    expInfo.EXP = expInfo.OLD.EXP;
    expInfo.EXP.replay = 1;
    expInfo.EXP.replayed_filename = TrialName;
end

%% Log file info

expInfo.centralLogName = [rigInfo.dirSave filesep 'centralLog'];
expInfo.animalLogName  = [expInfo.AnimalDir filesep expInfo.animalName '_log'];

%% AA: implement calibration and initialization of the screen

screens=Screen('Screens');

thisScreen = rigInfo.screenNumber;

fprintf('preparing screen\n');
hwInfo.MYSCREEN = prepareScreen(thisScreen,rigInfo,expInfo); %prepareScreen(thisScreen);
%Screen('BlendFunction', MYSCREEN.windowPtr, GL.SRC_ALPHA, GL.ONE);
% HideCursor; % usually done in ltScreenInitialize

% define synchronization square read by photodiode
rigInfo.photodiodeRect = struct('rect',[0 (hwInfo.MYSCREEN.Ymax - rigInfo.photodiodeSize(2) + 1) ...
                        rigInfo.photodiodeSize(1)-1            hwInfo.MYSCREEN.Ymax], ...
                         'colorOn', [1 1 1], 'colorOff', [0 0 0]);

Screen('FillRect', hwInfo.MYSCREEN.windowPtr(1), 0, rigInfo.photodiodeRect.rect);
Screen('Flip', hwInfo.MYSCREEN.windowPtr(1));

% pause(1)

%
% fhandle = @sessionStart;


runInfo.runTimeOut = 0;
runInfo.reward_active = ones(expInfo.EXP.nbRewSites,1);

% open = 0;
% close = 1;
runInfo.rewardStartT = timer('TimerFcn', 'reward(0.0)');

runInfo.STOPrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.STOPvalveTime );
runInfo.BASErewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.BASEvalveTime );
runInfo.PASSrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.PASSvalveTime );
runInfo.ACTVrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.ACTVvalveTime );

if expInfo.EXP.soundOn 
    beepStop  = 0.5*MakeBeep(3300,0.1);
    runInfo.oBeepSTOP  = audioplayer(beepStop ,22000);
    beepBase  = 0.5*MakeBeep(6600,0.1);
    runInfo.oBeepBASE  = audioplayer(beepBase ,22000);
    
    beepNoise = rand(size(MakeBeep(3300,expInfo.EXP.timeOut)))-0.5;
    runInfo.oBeepNoise = audioplayer(beepNoise,22000);
    
    runInfo.oBeepWrong = audioplayer((rand(size(MakeBeep(3300,0.1)))-0.5),22000);
end

%%
% initialize DIO-----------------------------------------------------------
if ~expInfo.OFFLINE % Dev2 - Dev1 swapped for ZUPERVISION
%     DIO = digitalio('nidaq', 'Dev2');
%     addline(DIO, 0, 1, 'out', {'SOL1'});
%     start(DIO);
%     putvalue(DIO.Line(1), 1);
    % define the UDP port
    hwInfo.BALLPort = 9999;
    
%     % open udp port
%     ZirkusPort  = pnet('udpsocket', 1001);
%     pnet(ZirkusPort,'udpconnect','144.82.135.38',1001);
%     
%     % open udp port
%     EYEPort  = pnet('udpsocket', 1002);
%     pnet(EYEPort,'udpconnect','144.82.135.51',1001); %%%Check the IP and port
    rigInfo.initialiseUDPports;

    if strcmp(expInfo.EXP.wheelType, 'WHEEL')
       hwInfo.session = daq.createSession('ni');
       hwInfo.session.Rate = rigInfo.NIsessRate;
       
       hwInfo.rotEnc = DaqRotaryEncoder;
       hwInfo.rotEnc.DaqSession = hwInfo.session;
       hwInfo.rotEnc.DaqId = rigInfo.NIdevID;
       hwInfo.rotEnc.DaqChannelId = rigInfo.NIRotEnc;
       hwInfo.rotEnc.createDaqChannel;
       hwInfo.rotEnc.zero;
       
       hwInfo.likEnc = DaqLickEncoder;
       hwInfo.likEnc.DaqSession = hwInfo.session;
       hwInfo.likEnc.DaqId = rigInfo.NIdevID;
       hwInfo.likEnc.DaqChannelId = rigInfo.NILicEnc;
       hwInfo.likEnc.createDaqChannel;
       
       hwInfo.sessionVal = daq.createSession('ni');
       hwInfo.sessionVal.Rate = rigInfo.NIsessRate;
       
       hwInfo.rewVal = DaqRewardValve;
       load('rewCalib');
       hwInfo.rewVal.DaqSession = hwInfo.sessionVal;
       hwInfo.rewVal.DaqId = rigInfo.NIdevID;
       hwInfo.rewVal.DaqChannelId = rigInfo.NIRewVal;
       hwInfo.rewVal.createDaqChannel;
       hwInfo.rewVal.MeasuredDeliveries = rewardCalibrations(end).measuredDeliveries;
       hwInfo.rewVal.OpenValue = rigInfo.valveOpen;
       hwInfo.rewVal.ClosedValue = rigInfo.valveClose;
       hwInfo.rewVal.close;
       
       if rigInfo.sendTTL
           hwInfo.session.addDigitalChannel(...
               'Dev1', 'Port0/Line0', 'OutputOnly');
           hwInfo.session.outputSingleScan(false);
       end
%        ValveClosed = 5;
%        ValveOpen = 0;
%        % defining the Analog Output object for the valve (for precise timing)
%        session.addAnalogOutputChannel(aoDeviceID, aoValveChannel, 'Voltage');
%        session.outputSingleScan(ValveClosed);
    end
end

%%
if rigInfo.sendTTL
    expRef = getfield(dat.mpepMessageParse(['blah ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName]),'expRef');
    tl.start(expRef, 'rotaryEncoder');
end

fhandle = @prepareNextTrial;

runInfo.TRIAL_COUNT = 0;
fprintf('\nStarting MouseBall session %s\n', datestr(now, 'mm-dd'));

dstr = num2str(str2num(datestr(now, 'mmdd')));
fprintf(dstr);
runInfo.blank_screen = 0;
runInfo.blank_screen_count = 0;

if ~expInfo.OFFLINE
    pause(1)
    VRLogMessage(expInfo);
    VRmessage = ['Starting new experiment with animal ' expInfo.animalName ':'];
    VRLogMessage(expInfo, VRmessage);
    VRLogMessage(expInfo);
    
    VRmessage = ['ExpStart ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo.sendUDPmessage(VRmessage);
    VRLogMessage(expInfo, VRmessage);
    
    rigInfo.send('animalName',expInfo.animalName);
    rigInfo.send('sessionNum',expInfo.dateStr);
    rigInfo.send('expNum',expInfo.sessionName);
    
    pause(1)
end

while ~isempty(fhandle) % main loop, active during experiment
    
    [fhandle, runInfo] = feval(fhandle, rigInfo, hwInfo, expInfo, runInfo);
    
end
tl.stop()
fprintf(['delivered Reward = ' num2str(runInfo.REWARD.TotalValveOpenTime) ' uL\n']);
clear all; clear mex;