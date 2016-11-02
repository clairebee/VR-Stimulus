function [fhandle, runInfo] = run(rigInfo, hwInfo, expInfo, runInfo)

global GL;
global TRIAL;
% global ROOM;
% global REWARD;
% global currTrial
% global MOUSEXY;

% global TRAJ;
% global SAVE_COUNT;
% global count

% global blank_screen
% global t1
% global blank_screen_count
% global reset_textures

runInfo.reset_textures = 1;
ListenChar(2);

%% First trial settings
% if ~REPLAY
%     if ~EXP.randStart
% Start Position
if ~expInfo.EXP.randStart
    if strcmp(expInfo.EXP.trajDir,'cw')
        runInfo.TRAJ = 0.1;
    else
        runInfo.TRAJ = expInfo.EXP.l-0.1;
    end
else
    if strcmp(expInfo.EXP.trajDir,'cw')
        runInfo.TRAJ = expInfo.EXP.l;
    else
        runInfo.TRAJ = expInfo.EXP.l - expInfo.EXP.l*rand(1)*expInfo.EXP.startRegion;
    end
end
TRIAL.trialStart(runInfo.currTrial) = runInfo.TRAJ;

if expInfo.EXP.randContr
    contrLevel = expInfo.EXP.contrLevels(randi(length(expInfo.EXP.contrLevels)));
else
    idxc = runInfo.currTrial;
    if idxc>length(expInfo.EXP.contrLevels)
        idxc = rem(runInfo.currTrial, length(expInfo.EXP.contrLevels));
        if idxc==0
            idxc = length(expInfo.EXP.contrLevels);
        end
    end
    contrLevel = expInfo.EXP.contrLevels(idxc);
end

TRIAL.trialContr(runInfo.currTrial) = contrLevel;

hwInfo.rotEnc.zero;
hwInfo.likEnc.zero;
likCount = 0;

% Scaling of the room
if expInfo.EXP.scaling
    if expInfo.EXP.randScale
        scaling_factor = expInfo.EXP.scaleSet(randi(length(expInfo.EXP.scaleSet)));
    else
        idx = runInfo.currTrial;
        if idx>length(expInfo.EXP.scaleSet)
            idx = rem(runInfo.currTrial, length(expInfo.EXP.scaleSet));
            if idx==0
                idx = length(expInfo.EXP.scaleSet);
            end
        end
        scaling_factor = expInfo.EXP.scaleSet(idx);
    end
else
    scaling_factor = 1;
end
TRIAL.trialGain(runInfo.currTrial) = scaling_factor;

% Active/Passive reward
idx = runInfo.currTrial;
if idx>length(expInfo.EXP.active)
    idx = rem(runInfo.currTrial, length(expInfo.EXP.active));
    if idx==0
        idx = length(expInfo.EXP.active);
    end
end
TRIAL.trialActive(runInfo.currTrial) = expInfo.EXP.active(idx);

% Reward Position
% Active/Passive reward
idx = runInfo.currTrial;
if idx>length(expInfo.EXP.rew_pos)
    idx = rem(runInfo.currTrial, length(expInfo.EXP.rew_pos));
    if idx==0
        idx = length(expInfo.EXP.rew_pos);
    end
end

TRIAL.trialRewPos(runInfo.currTrial) = expInfo.EXP.rew_pos(idx);
expInfo.EXP.punishZone = TRIAL.trialRewPos(runInfo.currTrial) - expInfo.EXP.punishLim;
% end
VRMessage = ['Trial ' num2str(runInfo.currTrial) ...
    ', C: ' num2str(TRIAL.trialContr(runInfo.currTrial)) ...
    ', G: ' num2str(TRIAL.trialGain(runInfo.currTrial)) ...
    ', RL: ' num2str(TRIAL.trialRL(runInfo.currTrial)) ...
    ', S: ' num2str(TRIAL.trialStart(runInfo.currTrial)) ...
    ', B: ' num2str(TRIAL.trialBlanks(runInfo.currTrial)) ...
    ', A: ' num2str(TRIAL.trialActive(runInfo.currTrial)) ...
    ', RP: ' num2str(TRIAL.trialRewPos(:,runInfo.currTrial)') ...
    ', PZ: ' num2str(expInfo.EXP.punishZone') ...
    ];
display(VRMessage);
rigInfo.send('trialParam',VRMessage);

%% shit to initialise so that we can load textures later
textures = []; y1 = [];Imf = [];ans = [];filt1 = [];filt2 = [];
filtSize = [];n = [];sf = [];sigma = [];sigma1 = [];texsize = [];
textures = [];x = [];x2= [];
% end

BALL_TO_DEGREE =1/300;%1/20000*360;

BALL_TO_ROOM = 1.11; %1.11 calculated to equate the cm and the distance travelled

PI_OVER_180 = pi/180;

runInfo.REWARD.TRIAL = [];
runInfo.REWARD.count = [];
runInfo.REWARD.TYPE  = [];
runInfo.REWARD.TotalValveOpenTime = 0;
runInfo.REWARD.STOP_VALVE_TIME = expInfo.EXP.STOPvalveTime;
runInfo.REWARD.BASE_VALVE_TIME = expInfo.EXP.BASEvalveTime;
runInfo.REWARD.PASS_VALVE_TIME = expInfo.EXP.PASSvalveTime;
runInfo.REWARD.ACTV_VALVE_TIME = expInfo.EXP.ACTVvalveTime;
runInfo.REWARD.USER_VALVE_TIME = expInfo.EXP.BASEvalveTime;

X=1; %x coordinate
Y=2; %y coordinate
Z=3; %z coordinate
T=4; %T: theta (viewangle)
% S=5; %S: speed

STOP = 1;
BASE = 1;


% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:


Screen('BeginOpenGL', hwInfo.MYSCREEN.windowPtr(1));
% Screen('BeginOpenGL', MYSCREEN.windowPtr(2));
% Screen('BeginOpenGL', MYSCREEN.windowPtr(3));

% Get the aspect ratio of the screen:
ar=hwInfo.MYSCREEN.screenRect(1,4)/(hwInfo.MYSCREEN.screenRect(1,3));

display(['Monitor aspect ratio is: ' num2str(1/ar) ', and fov is: ' ...
    num2str(atan(hwInfo.MYSCREEN.MonitorHeight/(2*hwInfo.MYSCREEN.Dist))*360/pi) ...
    ' vertical and ' num2str((1/ar)*atan(hwInfo.MYSCREEN.MonitorHeight/(2*hwInfo.MYSCREEN.Dist))*360/pi) ...
    ' horizontal']);

% Turn on OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.
glEnable(GL.LIGHTING);

% Enable the first local light source GL.LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources.
glEnable(GL.LIGHT0);

% Enable two-sided lighting - Back sides of polygons are lit as well.
% glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);
glLightModelfv(GL.LIGHT_MODEL_AMBIENT,[0.5 0.5 0.5 1]);
% glLightModelfv(GL.LIGHT_MODEL_LOCAL_VIEWER,0.0);

% glShadeModel(GL.SMOOTH);
% Enable proper occlusion handling via depth tests:
glEnable(GL.DEPTH_TEST);

% Define the walls light reflection properties by setting up reflection
% coefficients for ambient, diffuse and specular reflection:
glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 1 1 1 1 ]);
% glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT_AND_DIFFUSE, [ .5 .5 .5 1 ]);
% glMaterialfv(GL.FRONT_AND_BACK,GL.SPECULAR, [ .5 .5 .5 1 ]);
load(expInfo.EXP.textureFile);

% setupTextures(textures)
% 10-03 AS: This loads a texture from file, rather than creating locally.

% 10-06 AA: textureFile contains 2 variables 'textures' and 'tx'
% textures: is an array of structures representing different textures.
%           each item has a 'name' and a 'matrix'(64x64) field
%           (e.g. textures(1,1).name='gray', textures(1,1).matrix)
% tx:    is a structure of indices of different textures (i.e. tx.GRAY = 1,
%        tx.WHITENOISE = 2; tx.COSGRATING =3; )
% both of these structures will be extended as needed

% glTexSubImage2D(GL_TEXTURE_2D, 0, 0, w, h, GL_RGB, GL_UNSIGNED, texname)

%% Set start position
% switch expInfo.EXP.trajDir
%     case 'cw'
%         TRIAL.posdata(1,Z) = expInfo.EXP.a1;            % starting at the corner 1
%         TRIAL.posdata(1,X) = -expInfo.EXP.b1 - expInfo.EXP.w;
%         TRIAL.posdata(1,T) = 0;
%     case 'ccw'
%         TRIAL.posdata(1,Z) = expInfo.EXP.a1 + expInfo.EXP.w;            % starting at the corner 1, opp direction
%         TRIAL.posdata(1,X) = -expInfo.EXP.b1;
%         TRIAL.posdata(1,T) = pi/2;
%     otherwise
TRIAL.posdata(runInfo.currTrial,1,Z) = 0;            % starting at the corner 1: (or) expInfo.EXP.l
TRIAL.posdata(runInfo.currTrial,1,X) = 0;
TRIAL.posdata(runInfo.currTrial,1,T) = 0;
% end
TRIAL.posdata(runInfo.currTrial,1,Y) = expInfo.EXP.c3;

isLazy = 0;
lazyStart = [];
lazyDur = 0;

runInfo.count = 1; % This is a counter per trial
gcount = 1; % This is a global counter
lastActiveBase=0;


%% open udp port
if ~expInfo.OFFLINE
    myPort = pnet('udpsocket', hwInfo.BALLPort);
end

if expInfo.OFFLINE
    runInfo.MOUSEXY.dax = 0;
    runInfo.MOUSEXY.day = 0;
    runInfo.MOUSEXY.dbx = 0;
    runInfo.MOUSEXY.dby = 0;
    
end
timeIsUp =0;
TRIAL.info.start = clock;
runInfo.t1= tic;

% start acquiring data
if ~expInfo.OFFLINE
    VRmessage = ['BlockStart ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo.sendUDPmessage(VRmessage);
    VRLogMessage(expInfo, VRmessage);
    VRmessage = ['StimStart ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName ' 1 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
    rigInfo.sendUDPmessage(VRmessage); %%% Check this
    VRLogMessage(expInfo, VRmessage);
    if rigInfo.sendTTL
        hwInfo.session.outputSingleScan(true);
         pause(1);
    end
end

%% The main programme
try
    while (~timeIsUp && ~TRIAL.info.abort)
        if runInfo.reset_textures
            setupTextures(textures);
        end
        if ~runInfo.blank_screen
            
            
            glMatrixMode(GL.PROJECTION);
            glLoadIdentity;
            % Field of view is 50 degrees from line of sight. Objects closer than
            % 0.1 distance units or farther away than 100 distance units get clipped
            % away, aspect ratio is adapted to the monitors aspect ratio:
            % gluPerspective(25,1/ar,0.1,100);
            gluPerspective(atan(hwInfo.MYSCREEN.MonitorHeight/(2*hwInfo.MYSCREEN.Dist))*360/pi,1/ar,0.1,expInfo.EXP.visibleDepth);
            
            
            
            % Setup modelview matrix: This defines the position, orientation and
            % looking direction of the virtual camera:
            glMatrixMode(GL.MODELVIEW);
            glLoadIdentity;
            
            % Set background color to 'gray':
        end
        glClearColor(0.5,0.5,0.5,1);
        
        
        % % Point lightsource at (1,roomHeight-1,-25)...
        %         glLightfv(GL.LIGHT0,GL.POSITION,[ 1 expInfo.EXP.roomHeight-1 -expInfo.EXP.roomLength/2 0 ]);
        
        % Emits white (1,1,1,1) diffuse light:
        %glLightfv(GL.LIGHT0,GL.DIFFUSE, [ 0.0 0.0 0.0 1 ]);
        
        % There's also some white, but weak (R,G,B) = (0.1, 0.1, 0.1)
        % ambient light present:
        glLightfv(GL.LIGHT0,GL.AMBIENT, [ 0.5 0.5 0.5 1 ]);
        
        glShadeModel(GL.SMOOTH);
        
        glClear;
        
        glPushMatrix;
        %         if runInfo.blank_screen
        
        glRotated (0,1,0,0); % to look a little bit downward
        
        glRotated (TRIAL.posdata(runInfo.currTrial,runInfo.count,T)/pi*180,0,1,0);
        glTranslated (-TRIAL.posdata(runInfo.currTrial,runInfo.count,X),-expInfo.EXP.c3,-TRIAL.posdata(runInfo.currTrial,runInfo.count,Z));
        
        
        %            glTranslated (-dax,0,dbx);
        % implement drawscene
        % DrawScene()
        %         glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0.5 0.5 0.5 1 ]);
        DrawTextures
        
        
        glPushMatrix;
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', hwInfo.MYSCREEN.windowPtr(1));
        %     end
        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', hwInfo.MYSCREEN.windowPtr(1));
        
        glPopMatrix;
        glPopMatrix;
        %     end
        
        
        %% start drawing
        if runInfo.blank_screen
            glClear;
        end
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', hwInfo.MYSCREEN.windowPtr(1));
        
        
        if expInfo.EXP.speckleNoise
            numSpeckle = round((expInfo.EXP.speckleLevel/100)*(hwInfo.MYSCREEN.Xmax*hwInfo.MYSCREEN.Ymax)/((2*expInfo.EXP.speckleSize+1).^2));
            speckCentres = [ceil((hwInfo.MYSCREEN.Xmax - 2*expInfo.EXP.speckleSize)*rand(numSpeckle,1))+expInfo.EXP.speckleSize ...
                ceil((hwInfo.MYSCREEN.Ymax - 2*expInfo.EXP.speckleSize)*rand(numSpeckle,1))+expInfo.EXP.speckleSize];
            SPECKLE = struct('rect', [0 0 1 1], 'colorOn', [1 1 1], 'colorOff', [0 0 0]);
            for iSpeck = 1:numSpeckle
                SPECKLE.rect = [speckCentres(iSpeck,1)-expInfo.EXP.speckleSize speckCentres(iSpeck,2)-expInfo.EXP.speckleSize ...
                    speckCentres(iSpeck,1)+expInfo.EXP.speckleSize speckCentres(iSpeck,2)+expInfo.EXP.speckleSize];
                switch expInfo.EXP.speckleType
                    case 'RAND'
                        Screen('FillRect', hwInfo.MYSCREEN.windowPtr(1), ceil(rand(1)*255), SPECKLE.rect);
                    case 'GRAY'
                        Screen('FillRect', hwInfo.MYSCREEN.windowPtr(1), 128, SPECKLE.rect);
                end
            end
        end
        
        % Show the sync square
        % alternate between black and white with every frame
        
        Screen('FillRect', hwInfo.MYSCREEN.windowPtr(1), mod(gcount,2)*255, rigInfo.photodiodeRect.rect);
        
        %         glFlush;
        % Show rendered image at next vertical retrace:
        Screen('Flip', hwInfo.MYSCREEN.windowPtr(1));
        
        %         %% TO comment out: It is to get screenshots of the
        %         environment
        %         if ~exist('idx','var')
        %             idx = 2*[1:75];
        %         end
        %
        %         [sc_val sc_idx] = min(abs(runInfo.TRAJ-idx));
        %
        %         if sc_val<1
        %             idx(sc_idx) = [];
        %
        % %             This code is to get screenshots of the stimulus.
        %             %GetImage call. Alter the rect argument to change the location of the screen shot
        %             imageArray = Screen('GetImage', hwInfo.MYSCREEN.windowPtr(1),...
        %                   [0 0 hwInfo.MYSCREEN.Xmax hwInfo.MYSCREEN.Ymax]);% [0 0 2400 600]); %Change this for the screen resolution
        %
        %             %imwrite is a Matlab function, not a PTB-3 function
        %            SaveDir = 'C:\Users\Experiment\Documents\Matlab';
        %            imwrite(imageArray, fullfile(SaveDir,['screen_shots_' num2str(round(runInfo.TRAJ)) '.jpg']));
        %
        %             display(['Traj is: ' num2str(runInfo.TRAJ) ' idx is ' num2str(idx)]);
        %             WaitSecs(.5);
        %         end
        
        %%
        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', hwInfo.MYSCREEN.windowPtr(1));
        
        % get new coordinates
        runInfo.count = runInfo.count + 1;
        gcount = gcount + 1;
        
        if runInfo.blank_screen
            runInfo.blank_screen_count = runInfo.blank_screen_count + 1;
            %             Screen('EndOpenGL', MYSCREEN.windowPtr(1));
        end
        
        if expInfo.REPLAY
            endExpt = 0;
            if (runInfo.currTrial>=expInfo.EXP.maxTraj)
                endExpt = 1;
            elseif (TRIAL.time(runInfo.currTrial,runInfo.count) == 0 && TRIAL.time(runInfo.currTrial+1,2) == 0)
                endExpt = 1;
                display(['Reached global end @ trial: ' num2str(runInfo.currTrial)]);
            end
            if endExpt
                display('Reached global end');
                if ~expInfo.OFFLINE
                    VRmessage = ['StimStart ' expInfo.animalName ' ' expInfo.dateStr ...
                        ' ' expInfo.sessionName ' ' num2str(TRIAL.nCompTraj) ' 1 ' ...
                        num2str(round(expInfo.EXP.maxTrialDuration*10))];
                    rigInfo.sendUDPmessage(VRmessage); %%%
                    VRLogMessage(expInfo, VRmessage);
                    if rigInfo.sendTTL
                        session.outputSingleScan(true);
                        pause(1);
                    end
                end
                runInfo.currTrial = runInfo.currTrial + 1;
                fhandle = @trialEnd;
                TRIAL.info.abort =1;
                break
            end
        end
        if expInfo.REPLAY
            TRIAL.currTime(runInfo.currTrial,runInfo.count) = GetSecs;
        else
            TRIAL.time(runInfo.currTrial,runInfo.count) = GetSecs;
        end
        TRIAL.info.epoch = runInfo.count;
        
        %% get movement and draw
        %         if ~runInfo.blank_screen
        if ~expInfo.OFFLINE
            switch expInfo.EXP.wheelType
                case 'BALL'
                    [ballTime, dax, dbx, day, dby] = getBallDeltas(myPort);
                    TRIAL.balldata(runInfo.currTrial,runInfo.count,:) = [ballTime, dax, dbx, day, dby];
                    %         dax = nansum([dax 0]).*BALL_TO_ROOM.*expInfo.EXP.xGain;
                    feedback_gain = expInfo.EXP.zGain*scaling_factor;
                    dbx = nansum([dbx 0]).*BALL_TO_ROOM.*feedback_gain;
                    
                case 'WHEEL'
                    ballTime = TRIAL.time(runInfo.currTrial,runInfo.count);
                    dax = 0; day = 0; dby = 0;
                    scan_input = (hwInfo.rotEnc.readPosition);
                    if ~strcmp(rigInfo.rotEncPos,'right')
                        dbx = -scan_input(1);
                    else
                        dbx = scan_input(1);
                    end
                    % convert to cm
                    dbx = dbx*((2*pi*expInfo.EXP.wheelRadius)./(1024*4)); % (cm)% because it is a 4 x 1024 unit encoder
                    % dbx = 50*dbx; % to be removed when the room is better calibrated
                    hwInfo.rotEnc.zero;
                    TRIAL.balldata(runInfo.currTrial,runInfo.count,:) = [ballTime, dax, dbx, day, dby];
                    dbx = nansum([dbx 0]).*scaling_factor.*expInfo.EXP.wheelToVR;
                    % Remove 'BALL_TO_ROOM' after this set of animals (28th
                    % Feb)
                    currLikStatus = scan_input(2);
                    if currLikStatus
                        TRIAL.lick(runInfo.currTrial,runInfo.count) = 1;
                    else
                        TRIAL.lick(runInfo.currTrial,runInfo.count) = 0;
                    end
                case 'KEYBRD'
                    getNonBallDeltas;
                    ballTime = TRIAL.time(runInfo.currTrial,runInfo.count);
                    dax = runInfo.MOUSEXY.dax;
                    day = runInfo.MOUSEXY.day;
                    dbx = runInfo.MOUSEXY.dbx;
                    dby = runInfo.MOUSEXY.dby;
            end
        else
            getNonBallDeltas;
            ballTime = TRIAL.time(runInfo.currTrial,runInfo.count);
            dax = runInfo.MOUSEXY.dax;
            day = runInfo.MOUSEXY.day;
            dbx = runInfo.MOUSEXY.dbx;
            dby = runInfo.MOUSEXY.dby;
        end
        
        runInfo = getTrajectory(dbx, X, Y, Z, T, rigInfo, hwInfo, expInfo, runInfo);
        
        if ~runInfo.blank_screen
            % update x, z positions and viewangle
            
            if ~expInfo.REPLAY
                TRIAL.traj(runInfo.currTrial,runInfo.count) = runInfo.TRAJ;
                %                 disp(['Traj is ' num2str(runInfo.TRAJ*10)]);
            end
            
            if TRIAL.nCompTraj > expInfo.EXP.maxTraj
                if ~expInfo.OFFLINE
                    VRmessage = ['StimStart ' expInfo.animalName ' ' expInfo.dateStr ' ' ...
                        expInfo.sessionName ' ' num2str(TRIAL.nCompTraj) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
                    rigInfo.sendUDPmessage(VRmessage); %%%
                    VRLogMessage(expInfo, VRmessage);
                    if rigInfo.sendTTL
                        hwInfo.session.outputSingleScan(true);
                    end
                end
                fhandle = @trialEnd;
                break
            end
            
            currentPos = [TRIAL.posdata(runInfo.currTrial,runInfo.count,X) TRIAL.posdata(runInfo.currTrial,runInfo.count,Y) TRIAL.posdata(runInfo.currTrial,runInfo.count,Z)];
            
        end
        
        if runInfo.blank_screen_count > TRIAL.trialBlanks(runInfo.currTrial)
            runInfo.blank_screen = 0;
            runInfo.blank_screen_count = 1;
            
            %             if ~REPLAY
            %% Set trial parameters
            % Room Length
            if length(expInfo.EXP.lengthSet)>1
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
            
            % Start Position
            if ~expInfo.EXP.randStart
                if strcmp(expInfo.EXP.trajDir,'cw')
                    runInfo.TRAJ = 0.1;
                else
                    runInfo.TRAJ = expInfo.EXP.l-0.1;
                end
            else
                if strcmp(expInfo.EXP.trajDir,'cw')
                    runInfo.TRAJ = expInfo.EXP.l;
                else
                    runInfo.TRAJ = expInfo.EXP.l - expInfo.EXP.l*rand(1)*expInfo.EXP.startRegion;
                end
            end
            TRIAL.trialStart(runInfo.currTrial) = runInfo.TRAJ;
            
            % Room scaling
            if length(expInfo.EXP.scaleSet)>1
                if expInfo.EXP.randScale
                    scaling_factor = expInfo.EXP.scaleSet(randi(length(expInfo.EXP.scaleSet)));
                else
                    idx = runInfo.currTrial;
                    if idx>length(expInfo.EXP.scaleSet)
                        idx = rem(runInfo.currTrial, length(expInfo.EXP.scaleSet));
                        if idx==0
                            idx = length(expInfo.EXP.scaleSet);
                        end
                    end
                    scaling_factor = expInfo.EXP.scaleSet(idx);
                end
            else
                scaling_factor = 1;
            end
            runInfo.ROOM = getRoomData(expInfo.EXP,TRIAL.trialRL(runInfo.currTrial));
            
            % Active/Passive reward
            idx = runInfo.currTrial;
            if idx>length(expInfo.EXP.active)
                idx = rem(runInfo.currTrial, length(expInfo.EXP.active));
                if idx==0
                    idx = length(expInfo.EXP.active);
                end
            end
            TRIAL.trialActive(runInfo.currTrial) = expInfo.EXP.active(idx);
            
            % Reward Position
            idx = runInfo.currTrial;
            if idx>length(expInfo.EXP.rew_pos)
                idx = rem(runInfo.currTrial, length(expInfo.EXP.rew_pos));
                if idx==0
                    idx = length(expInfo.EXP.rew_pos);
                end
            end
            
            TRIAL.trialRewPos(runInfo.currTrial) = expInfo.EXP.rew_pos(idx).*TRIAL.trialRL(runInfo.currTrial);
            expInfo.EXP.punishZone = TRIAL.trialRewPos(runInfo.currTrial) - expInfo.EXP.punishLim;
            %             end TRIAL.trialActive(runInfo.currTrial) TRIAL.trialRewPos(runInfo.currTrial)
            p = runInfo.TRAJ;
            
            if ~expInfo.REPLAY
                TRIAL.posdata(runInfo.currTrial,runInfo.count,Z) = -p;
                TRIAL.posdata(runInfo.currTrial,runInfo.count,X) = 0;
                TRIAL.posdata(runInfo.currTrial,1,Y) = expInfo.EXP.c3;
                TRIAL.posdata(runInfo.currTrial,runInfo.count,T) = 0;
            end
            
            TRIAL.trialIdx(runInfo.currTrial,runInfo.count) = TRIAL.nCompTraj;
            
            if ~expInfo.REPLAY
                switch expInfo.EXP.trajDir
                    case 'ccw'
                        TRIAL.posdata(runInfo.currTrial,runInfo.count,T) =  TRIAL.posdata(runInfo.currTrial,runInfo.count,T) + pi;
                    otherwise
                        TRIAL.posdata(runInfo.currTrial,runInfo.count,T) =  TRIAL.posdata(runInfo.currTrial,runInfo.count,T);
                end
            end
            
            TRIAL.trialGain(runInfo.currTrial) = scaling_factor;
            display(['Trial ' num2str(runInfo.currTrial) ...
                ', C: ' num2str(TRIAL.trialContr(runInfo.currTrial)) ...
                ', G: ' num2str(TRIAL.trialGain(runInfo.currTrial)) ...
                ', RL: ' num2str(TRIAL.trialRL(runInfo.currTrial)) ...
                ', S: ' num2str(TRIAL.trialStart(runInfo.currTrial)) ...
                ', B: ' num2str(TRIAL.trialBlanks(runInfo.currTrial)) ...
                ', A: ' num2str(TRIAL.trialActive(runInfo.currTrial)) ...
                ', RP: ' num2str(TRIAL.trialRewPos(runInfo.currTrial)) ...
                ', PZ: ' num2str(expInfo.EXP.punishZone) ...
                ]);
            runInfo.t1 = tic;
            if ~expInfo.OFFLINE
                VRmessage = ['StimStart ' expInfo.animalName ' ' expInfo.dateStr ' ' ...
                    expInfo.sessionName ' ' num2str(TRIAL.nCompTraj) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
                rigInfo.sendUDPmessage(VRmessage); %%%
                rigInfo.send('currentTrial',num2str(TRIAL.nCompTraj));
                VRLogMessage(expInfo, VRmessage);
                if rigInfo.sendTTL
                    hwInfo.session.outputSingleScan(true);
                    pause(1);
                end
            end
            
            if TRIAL.nCompTraj > runInfo.SAVE_COUNT + 5
                s = sprintf('%s_trial%03d', expInfo.SESSION_NAME, TRIAL.info.no);
                EXP    = expInfo.EXP;
                REWARD = runInfo.REWARD;
%                 TRIAL  = runInfo.TRIAL;
                ROOM   = runInfo.ROOM;
                save(s, 'TRIAL', 'EXP', 'REWARD','ROOM');
                runInfo.SAVE_COUNT = TRIAL.nCompTraj;
            end
            
            hwInfo.rotEnc.zero;
        end
        
        keyPressed = checkKeyboard(rigInfo);
        if keyPressed == 1
            TRIAL.info.abort =1;
            if ~expInfo.OFFLINE
                VRmessage = ['StimEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' ...
                    expInfo.sessionName ' ' num2str(TRIAL.nCompTraj) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
                rigInfo.sendUDPmessage(VRmessage); %%%Check this
                VRLogMessage(expInfo, VRmessage);
                if rigInfo.sendTTL
                    hwInfo.session.outputSingleScan(false);
                end
            end
            fhandle = @trialEnd;
        elseif keyPressed == 2
            runInfo = giveReward(runInfo.count,'USER',runInfo.currTrial,1, expInfo, runInfo, hwInfo, rigInfo);
        end
        
        
    end
    
catch ME
    fprintf(['exception : ' ME.message '\n']);
    fprintf(['line #: ' num2str(ME.stack(1,1).line)]);
    TRIAL.info.abort = 1;
    fhandle = @trialEnd;
    
end


%% close udp port and reset priority level
if ~expInfo.OFFLINE
    pnet(myPort,'close');
end

ListenChar(0);
Priority(0);

%% Delete all allocated OpenGL textures:
if ~runInfo.blank_screen
    glDeleteTextures(length(texname),texname);
    Screen('EndOpenGL', hwInfo.MYSCREEN.windowPtr(1));
end

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end
%% Setup textures for all six sides of cube:
    function setupTextures(textures)
        
        runInfo.reset_textures = 0;
        %         if ~REPLAY
        if expInfo.EXP.randContr
            contrLevel = expInfo.EXP.contrLevels(randi(length(expInfo.EXP.contrLevels)));
        else
            idxc = runInfo.currTrial;
            if idxc>length(expInfo.EXP.contrLevels)
                idxc = rem(runInfo.currTrial, length(expInfo.EXP.contrLevels));
                if idxc==0
                    idxc = length(expInfo.EXP.contrLevels);
                end
            end
            contrLevel = expInfo.EXP.contrLevels(idxc);
        end
        
        TRIAL.trialContr(runInfo.currTrial) = contrLevel;
        %         else
        %             contrLevel = TRIAL.trialContr(runInfo.currTrial);
        %         end
        
        % Enable 2D texture mapping,
        glEnable(GL.TEXTURE_2D);
        
        % Generate textures and store their handles in vecotr 'texname'
        texname=glGenTextures(length(textures));
        
        for i=1:length(textures),
            % Enable i'th texture by binding it:
            glBindTexture(GL.TEXTURE_2D,texname(i));
            
            f=max(min(255*(textures(i).matrix),255),0);
            %             f=round(contrLevel.*(f-128) + 128);
            if i>5 % change to 5
                f=round(contrLevel.*(f-128) + 128);
                tx=repmat(flipdim(f,1),[ 1 1 3 ]);
            else
                if expInfo.EXP.contrWalls
                    f=round(contrLevel.*(f-128) + 128);
                end
                tx=repmat(flipdim(f',1),[ 1 1 3 ]);
            end
            
            if i==9;
                tx(:,:,2:3) = 128;
            elseif i ==10
                tx(:,:,1:2) = 128;
            end
            tx=permute(flipdim(uint8(tx),1),[ 3 2 1 ]);
            % Assign image in matrix 'tx' to i'th texture:
            glTexImage2D(GL.TEXTURE_2D,0,GL.RGB,size(f,1),size(f,2),0,GL.RGB,GL.UNSIGNED_BYTE,tx);
            %    glTexImage2D(GL.TEXTURE_2D,0,GL.ALPHA,256,256,1,GL.ALPHA,GL.UNSIGNED_BYTE,noisematrix);
            
            % Setup texture wrapping behaviour:
            glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.CLAMP);%GL.CLAMP_TO_EDGE);%GL.REPEAT);%
            glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.CLAMP);%GL.CLAMP_TO_EDGE);
            glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_R,GL.CLAMP);%GL.CLAMP_TO_EDGE);
            
            %     % Setup filtering for the textures:
            glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.NEAREST);
            glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.NEAREST);
             % Choose texture application function: It will modulate the light
            % reflection properties of the the cubes face:
            glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
        end
    end
%% Draw textures
    function DrawTextures
        for k=1:runInfo.ROOM.nOfWalls
            switch k
                case 1
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.farWallText)),runInfo.ROOM.wrap(k,:));
                case 2
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.nearWallText)),runInfo.ROOM.wrap(k,:));
                case 3
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.leftWallText)),runInfo.ROOM.wrap(k,:));
                case 4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.rightWallText)),runInfo.ROOM.wrap(k,:));
                case 5
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.ceilingText)),runInfo.ROOM.wrap(k,:));
                case 6
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.floorText)),runInfo.ROOM.wrap(k,:));
                    ... Texture 1
                case 7
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg1Text1)),runInfo.ROOM.wrap(k,:));
                case 8
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg1Text2)),runInfo.ROOM.wrap(k,:));
                case 9
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg1Text3)),runInfo.ROOM.wrap(k,:));
                case 10
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg1Text4)),runInfo.ROOM.wrap(k,:));
                    ... Texture 2
                case 11
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg2Text1)),runInfo.ROOM.wrap(k,:));
                case 12
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg2Text2)),runInfo.ROOM.wrap(k,:));
                case 13
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg2Text3)),runInfo.ROOM.wrap(k,:));
                case 14
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg2Text4)),runInfo.ROOM.wrap(k,:));
                    ... Texture 3
                case 15
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg3Text1)),runInfo.ROOM.wrap(k,:));
                case 16
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg3Text2)),runInfo.ROOM.wrap(k,:));
                case 17
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg3Text3)),runInfo.ROOM.wrap(k,:));
                case 18
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg3Text4)),runInfo.ROOM.wrap(k,:));
                    ... Texture 4
                case 19
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg4Text1)),runInfo.ROOM.wrap(k,:));
                case 20
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg4Text2)),runInfo.ROOM.wrap(k,:));
                case 21
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg4Text3)),runInfo.ROOM.wrap(k,:));
                case 22
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.Leg4Text4)),runInfo.ROOM.wrap(k,:));
                    ... End Texture 1
                case 19+4
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End1Text1)),runInfo.ROOM.wrap(k,:));
                case 20+4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End1Text2)),runInfo.ROOM.wrap(k,:));
                case 21+4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End1Text3)),runInfo.ROOM.wrap(k,:));
                case 22+4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End1Text4)),runInfo.ROOM.wrap(k,:));
                    ... End Texture 2
                case 23+4
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End2Text1)),runInfo.ROOM.wrap(k,:));
                case 24+4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End2Text2)),runInfo.ROOM.wrap(k,:));
                case 25+4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End2Text3)),runInfo.ROOM.wrap(k,:));
                case 26+4
                    wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex(expInfo.EXP.End2Text4)),runInfo.ROOM.wrap(k,:));
                    ...
                otherwise
                wallface (runInfo.ROOM.v, runInfo.ROOM.order(k,:),runInfo.ROOM.normals(k,:),texname(getTextureIndex('WHITENOISE')),runInfo.ROOM.wrap(k,:));
            end
        end
    end
end