function [fhandle, runInfo] = prepareNextTrial(rigInfo, hwInfo, expInfo, runInfo)
% prepareNextTrial
% initializes trial specific information such us initializing base
% information

global TRIAL; % save trial specific info here
% global TRIAL_COUNT; % necessary to keep track of TRIAL count and set it for next trial;
% global EXP;
% global ROOM;
% global OLD;
% global SESSION_NAME;
% global REPLAY;
% global TRAJ;
% global SAVE_COUNT
% global rewStatus
% global currTrial



runInfo.currTrial = 1;
switch expInfo.EXP.trajDir
    case 'cw'
        runInfo.TRAJ = expInfo.EXP.delta;
    case 'ccw'
        runInfo.TRAJ = expInfo.EXP.l - expInfo.EXP.delta;
    otherwise 
        runInfo.TRAJ = round(expInfo.EXP.a1/10);
end


runInfo.TRIAL_COUNT = runInfo.TRIAL_COUNT + 1;
runInfo.SAVE_COUNT = 0;

info = [];

info.no = runInfo.TRIAL_COUNT;
info.epoch = 0; %number of steps within a run loop
info.abort = 0;
info.start = -1; % it will be set at the beginning of run.m

TRIAL.info = info;
TRIAL.trialContr = [expInfo.EXP.contrLevels(1) NaN.*ones(1,expInfo.EXP.maxTraj-1)];
TRIAL.trialStart = NaN.*ones(1,expInfo.EXP.maxTraj);
TRIAL.trialGain  = NaN.*ones(1,expInfo.EXP.maxTraj);
TRIAL.trialBlanks  = NaN.*ones(1,expInfo.EXP.maxTraj);
TRIAL.trialActive = ones(1,expInfo.EXP.maxTraj);
TRIAL.trialRewPos = repmat(expInfo.EXP.rew_pos(:,1),[1 expInfo.EXP.maxTraj]);
TRIAL.trialOutcome = NaN.*ones(expInfo.EXP.nbRewSites,expInfo.EXP.maxTraj);

TRIAL.trialActive(1) = expInfo.EXP.active(1);
%JUL: change to allow multiple reward sites
TRIAL.trialRewPos(:,1) = expInfo.EXP.rew_pos(:,1);
TRIAL.trialStart(1) = 0;
TRIAL.trialGain(1)  = 1;
TRIAL.trialBlanks(1) = expInfo.EXP.pause_frames;

fprintf('PrepareNextTrial\n'); % debug
fprintf('*** trial %4d of %4d ***\n', TRIAL.info.no, expInfo.EXP.maxNTrials); % debug

TRIAL.posdata = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70*expInfo.EXP.nTrialChange,6,'double'); % x,y,z,theta,speed,inRoom
TRIAL.posdata(:,:,1) = 0;
TRIAL.traj      = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70*expInfo.EXP.nTrialChange,1,'double'); % 

TRIAL.pospars   = {'X','Y','Z','theta','speed','inRoom'};
TRIAL.time      = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70,'double');
TRIAL.balldata  = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70,5,'double');
TRIAL.lick      = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70,'double');
%JUL: change to allow multiple reward sites
TRIAL.badlick   = zeros(expInfo.EXP.nbRewSites, 'double');
TRIAL.goodlick  = zeros(expInfo.EXP.maxTraj, expInfo.EXP.nbRewSites, 'double');

%JUL: same as traj but in angular coordinates
TRIAL.angle      = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70*expInfo.EXP.nTrialChange,1,'double'); % 



TRIAL.trialIdx = zeros(expInfo.EXP.maxTraj, expInfo.EXP.maxTrialDuration*70*expInfo.EXP.nTrialChange,'double'); %

% if ~REPLAY
    if expInfo.EXP.changeLength
        if expInfo.EXP.randScale
            roomLength = expInfo.EXP.lengthSet(randi(length(expInfo.EXP.lengthSet)));
        else
            idx = runInfo.currTrial;
            if idx>length(expInfo.EXP.lengthSet)
                idx = rem(runInfo.currTrial, length(expInfo.EXP.lengthSet));
                if idx==0
                    idx = length(expInfo.EXP.lengthSet);
                end
            end
            roomLength = expInfo.EXP.lengthSet(idx);
        end
    else
        roomLength = 1;
    end
    TRIAL.trialRL(runInfo.currTrial) = roomLength;
% end

%% *** LOAD THE ROOM HERE ***
if ~expInfo.REPLAY
    runInfo.ROOM = getRoomData(expInfo.EXP,TRIAL.trialRL(runInfo.currTrial));
else
    runInfo.ROOM = expInfo.OLD.ROOM;
end
%%

runInfo.rewStatus = zeros(size(expInfo.EXP.rewCorners));
TRIAL.nCompTraj = 1; % number of completed trajectories
TRIAL.CompCircle = 1; % number of completed full circle

if expInfo.REPLAY
    TRIAL = expInfo.OLD.TRIAL;
    TRIAL.info.abort = 0;
    TRIAL.currTime = zeros(size(TRIAL.time));
    runInfo.currTrial = 1;
    TRIAL.nCompTraj = 1;
end

rigInfo;
hwInfo;
expInfo;

fhandle =  @run;
return
end
