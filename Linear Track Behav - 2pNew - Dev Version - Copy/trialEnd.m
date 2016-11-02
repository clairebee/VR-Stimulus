function [fhandle, runInfo] = trialEnd(rigInfo, hwInfo, expInfo, runInfo)

global TRIAL;
% global EXP;
% global SESSION_NAME;
global GL;
% global ZirkusPort;
% global EYEPort;
% global OFFLINE
% global REWARD
% global ROOM;
% global animalName
% global dateStr
% global sessionName
% global MYSCREEN
% global SYNC

if ~expInfo.OFFLINE
    VRmessage = ['BlockEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo.sendUDPmessage(VRmessage);
    VRLogMessage(expInfo, VRmessage);
end
if TRIAL.info.no > 0
    s = sprintf('%s_trial%03d', expInfo.SESSION_NAME, TRIAL.info.no);
    EXP    = expInfo.EXP;
    REWARD = runInfo.REWARD;
%     TRIAL  = runInfo.TRIAL;
    ROOM   = runInfo.ROOM;
    save(s, 'TRIAL', 'EXP', 'REWARD','ROOM');
end

fprintf('TrialEnd\n'); % debug

if TRIAL.nCompTraj > expInfo.EXP.maxTraj
    fhandle = @endOfExperiment;
    return;
end

if TRIAL.info.no == expInfo.EXP.maxNTrials
    fhandle = @endOfExperiment;
    return;
end

if TRIAL.info.abort == 1
    fhandle = @endOfExperiment;
    return;
end

hwInfo;

fhandle = @endOfExperiment;
return;
end