%% AA 2009-12: virtual reality for training mice

function MouseBallSpont(animal_in, spont_time_in, record_in)
%---------------------------------------
% Usage:    MouseBallExp
%           MouseBallExp(replay_in, offline_in, animal_in)
%           MouseBallExp(1): To replay an experiment, 0: normal
%           MouseBallExp(x,1): To run/debug on computers that not
%           connected, 0: online
%           MouseBallExp(x,x,'animal'): animal name given in the command
%           line
% Adapted from original code written by Asli Ayaz and Aman Saleem
% Current update is @ end of 2012.

blank_screen = 0;

% SetDefaultDirs

serverName    = 'zserver'; % or Znetgear1 or zserver2
serverDataDir = [filesep filesep serverName filesep 'Data' filesep];
DIRS.ball = [serverDataDir 'ball'];

Screen('Preference','VisualDebugLevel',3)


if nargin<1
    animalName = input('Enter animal name: ', 's');
else
    animalName = animal_in;
end

% initialize DIO-----------------------------------------------------------

if record_in
    % define the UDP port
    BALLPort = 9999;
    
    % open udp port
    ZirkusPort  = pnet('udpsocket', 1001);
    pnet(ZirkusPort,'udpconnect','144.82.135.38',1001);
    
    % open udp port
    EYEPort  = pnet('udpsocket', 1002);
    pnet(EYEPort,'udpconnect','144.82.135.102',1001); %%%Check the IP and port
end

% prepare screen----q-------------------------------------------------------

% AA: implement calibration and initialization of the screen

screens=Screen('Screens');

CurrentDir = pwd;
cd 'C:/';

[foo,hostname] = system('hostname'); %#ok<ASGLU>

fprintf('Host name is %s\n', hostname);

hostname = hostname(1:end-1);
switch upper(hostname)
    case 'ZUPERVISION'
        thisScreen = 2;
    otherwise
        thisScreen=max(screens);
end
cd(CurrentDir);

% thisScreen=screens(2);

fprintf('preparing screen\n');
MYSCREEN = prepareScreen(thisScreen); %prepareScreen(thisScreen);
%Screen('BlendFunction', MYSCREEN.windowPtr, GL.SRC_ALPHA, GL.ONE);
HideCursor; % usually done in ltScreenInitialize


pause(1)

dateStr =  num2str(str2num(datestr(now, 'mmdd')));
%
%% AS 03-10: saving to directory on zserver
sessionName = 101;

AnimalDir = fullfile(DIRS.ball,animalName);
if ~isdir(AnimalDir), mkdir(AnimalDir); end

TheDir = fullfile(DIRS.ball,animalName,dateStr);
if ~isdir(TheDir), mkdir(TheDir); end

sessionName = 301;

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

dstr = num2str(str2num(datestr(now, 'mmdd')));
fprintf(dstr);

if record_in
    pnet(ZirkusPort, 'write',['ExpStart ' animalName ' ' dateStr ' ' sessionName]);
    pnet(ZirkusPort, 'writePacket');
end

pause(spont_time_in*60)

if record_in
    pnet( ZirkusPort,'write',['BlockEnd ' animalName ' ' dateStr ' ' sessionName]);
    pnet(ZirkusPort, 'writePacket');
    pause(1)
    pnet(ZirkusPort,'write',['VR_ExpEnd ' animalName ' ' dateStr ' ' sessionName]);
    pnet(ZirkusPort, 'writePacket');
    pause(1);
    pnet(ZirkusPort,'write',['ExpEnd ' animalName ' ' dateStr ' ' sessionName]);
    pnet(ZirkusPort, 'writePacket');
    pnet(ZirkusPort,'close');
end
save([SESSION_NAME '_trial001'],'spont_time_in');

clear all; clear global; sca; close all
end
