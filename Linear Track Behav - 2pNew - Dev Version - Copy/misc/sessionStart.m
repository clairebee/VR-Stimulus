%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%timeOut
%trialEnd
%enOfExperiment
%=========================================================================%

% sessionStart-------------(session initiates with experimenter's input
% this can be modified later for animal initiation

function fhandle = sessionStart

% AS:  line 43, 105, 107: made dateStr 'mmdd' from 'yymmdd'

global EXP;
global TRIAL_COUNT;
global SESSION_NAME;
global rewardStartT;

global STOPrewardStopT;
global BASErewardStopT;
global PASSrewardStopT;
global ACTVrewardStopT;

global oBeepBASE;
global oBeepSTOP;
global oBeepNoise;
global oBeepWrong;
global ZirkusPort;
global EYEPort;
global DIRS;
global OFFLINE;
global animalName;
global REPLAY;
global dateStr;
global sessionName;
global reward_active;
global runTimeOut;

runTimeOut = 0;
reward_active = 1;

% open = 0;
% close = 1;
rewardStartT = timer('TimerFcn', 'reward(0.0)');

STOPrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', EXP.STOPvalveTime );

BASErewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', EXP.BASEvalveTime );
PASSrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', EXP.PASSvalveTime );
ACTVrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', EXP.ACTVvalveTime );

dateStr =  num2str(str2num(datestr(now, 'mmdd')));

if EXP.soundOn 
    beepStop  = 0.5*MakeBeep(3300,0.1);
    oBeepSTOP  = audioplayer(beepStop ,22000);
    beepBase  = 0.5*MakeBeep(6600,0.1);
    oBeepBASE  = audioplayer(beepBase ,22000);
    
    beepNoise = rand(size(MakeBeep(3300,EXP.timeOut)))-0.5;
    oBeepNoise = audioplayer(beepNoise,22000);
    
    oBeepWrong = audioplayer((rand(size(MakeBeep(3300,0.1)))-0.5),22000);
end

%% AS 03-10: saving to directory on zserver
sessionName = 101;

AnimalDir = fullfile(DIRS.ball,animalName);
if ~isdir(AnimalDir), mkdir(AnimalDir); end

TheDir = fullfile(DIRS.ball,animalName,dateStr);
if ~isdir(TheDir), mkdir(TheDir); end

if REPLAY
    sessionName = 201;
end

test = 1;
while test
    if exist([TheDir filesep animalName '_' dateStr '_session_' num2str(sessionName) '_trial001.mat'],'file')
        sessionName = sessionName + 1;
    else
        display(['***********SESSION NUMBER: ' num2str(sessionName) '*************']);
        test = 0;
        sessionName = num2str(sessionName);
    end
end
SESSION_NAME = [TheDir filesep animalName '_' dateStr '_session_' sessionName];

%%
fhandle = @prepareNextTrial;

TRIAL_COUNT = 0;
fprintf('\nStarting MouseBall session %s\n', datestr(now, 'mm-dd'));

dstr = num2str(str2num(datestr(now, 'mmdd')));
fprintf(dstr);


if ~OFFLINE
    pause(1)
    pnet(ZirkusPort, 'write',['ExpStart ' animalName ' ' dateStr ' ' sessionName]);
    pnet(ZirkusPort, 'writePacket');
    %
    pnet(EYEPort, 'write',['ExpStart ' animalName ' ' dateStr ' ' sessionName]);
    pnet(EYEPort, 'writePacket');
    pause(10)
end
return;
end

