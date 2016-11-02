%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%trialEnd
%enOfExperiment
%=========================================================================%

function fhandle = run

global GL;
global EXP;
global TRIAL;
global MYSCREEN;
global SYNC;
global ROOM;
global SESSION_NAME;
global REWARD;

global UDPPORT;
global ZirkusPort;
global MOUSEXY;
global OFFLINE;

global REPLAY;
global OLD;
global TRAJ;
global SAVE_COUNT;

global animalName
global dateStr
global sessionName

% if ~REPLAY
ListenChar(2);
% end

BALL_TO_DEGREE =1/300;%1/20000*360;
BALL_TO_ROOM = 1/1000;
PI_OVER_180 = pi/180;
REWARD.STOP = 0;
REWARD.BASE = 0;
REWARD.USER = 0;
REWARD.TotalValveOpenTime = 0;
REWARD.STOP_VALVE_TIME = EXP.STOPvalveTime;
REWARD.BASE_VALVE_TIME = EXP.BASEvalveTime;
REWARD.USER_VALVE_TIME = EXP.BASEvalveTime;

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
InitializeMatlabOpenGL;


Screen('BeginOpenGL', MYSCREEN.windowPtr(1));
% Screen('BeginOpenGL', MYSCREEN.windowPtr(2));
% Screen('BeginOpenGL', MYSCREEN.windowPtr(3));

% Get the aspect ratio of the screen:
ar=MYSCREEN.screenRect(1,4)/(MYSCREEN.screenRect(1,3));

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

% 10-03 AS: This loads a texture from file, rather than creating locally.

% 10-06 AA: textureFile contains 2 variables 'textures' and 'tx'
% textures: is an array of structures representing different textures.
%           each item has a 'name' and a 'matrix'(64x64) field
%           (e.g. textures(1,1).name='gray', textures(1,1).matrix)
% tx:    is a structure of indices of different textures (i.e. tx.GRAY = 1,
%        tx.WHITENOISE = 2; tx.COSGRATING =3; )
% both of these structures will be extended as needed

load(EXP.textureFile);

% Enable 2D texture mapping,
glEnable(GL.TEXTURE_2D);

% Generate textures and store their handles in vecotr 'texname'
texname=glGenTextures(length(textures));


% glTexSubImage2D(GL_TEXTURE_2D, 0, 0, w, h, GL_RGB, GL_UNSIGNED, texname)

%% Setup textures for all six sides of cube:
for i=1:length(textures),
    % Enable i'th texture by binding it:
    glBindTexture(GL.TEXTURE_2D,texname(i));
    
    f=max(min(255*(textures(i).matrix),255),0);
    tx=repmat(flipdim(f,1),[ 1 1 3 ]);
    tx=permute(flipdim(uint8(tx),1),[ 3 2 1 ]);
    % Assign image in matrix 'tx' to i'th texture:
    glTexImage2D(GL.TEXTURE_2D,0,GL.RGB,size(f,1),size(f,2),0,GL.RGB,GL.UNSIGNED_BYTE,tx);
    %    glTexImage2D(GL.TEXTURE_2D,0,GL.ALPHA,256,256,1,GL.ALPHA,GL.UNSIGNED_BYTE,noisematrix);
    
    % Setup texture wrapping behaviour:
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);%GL.CLAMP_TO_EDGE);%GL.REPEAT);%
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);%GL.CLAMP_TO_EDGE);
    % Setup filtering for the textures:
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.LINEAR);
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.LINEAR);
    
    % Choose texture application function: It will modulate the light
    % reflection properties of the the cubes face:
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
end

%% Set start position
% switch EXP.trajDir
%     case 'cw'
%         TRIAL.posdata(1,Z) = EXP.a1;            % starting at the corner 1
%         TRIAL.posdata(1,X) = -EXP.b1 - EXP.w;
%         TRIAL.posdata(1,T) = 0;
%     case 'ccw'
%         TRIAL.posdata(1,Z) = EXP.a1 + EXP.w;            % starting at the corner 1, opp direction
%         TRIAL.posdata(1,X) = -EXP.b1;
%         TRIAL.posdata(1,T) = pi/2;
%     otherwise
        TRIAL.posdata(1,Z) = EXP.l;            % starting at the corner 1
        TRIAL.posdata(1,X) = 0;
        TRIAL.posdata(1,T) = 0;
% end
TRIAL.posdata(1,Y) = EXP.c3;

isLazy = 0;
lazyStart = [];
lazyDur = 0;

count = 1;

lastActiveBase=0;


%% open udp port
if ~OFFLINE
    myPort = pnet('udpsocket', UDPPORT);
end

if OFFLINE
    MOUSEXY.dax = 0;
    MOUSEXY.day = 0;
    MOUSEXY.dbx = 0;
    MOUSEXY.dby = 0;
    
end
timeIsUp =0;
TRIAL.info.start = clock;
t1= tic;

% start acquiring data
if ~OFFLINE
    pnet(ZirkusPort, 'write',['BlockStart ' animalName ' ' dateStr ' ' sessionName]);
    pnet(ZirkusPort, 'writePacket');
end

%% The main programme
try
    while (~timeIsUp && ~TRIAL.info.abort)
        %     for numScreens = 1:2
        %         % Set projection matrix: This defines a perspective projection,
        %         % corresponding to the model of a pin-hole camera - which is a good
        %         % approximation of the human eye and of standard real world cameras --
        %         % well, the best aproximation one can do with 3 lines of code ;-)
        %         if numScreens == 1
        %             glViewport(0, 0, 200,200)%MYSCREEN.screenRect(3)/3, MYSCREEN.screenRect(4))
        %         elseif numScreens == 2
        %             glViewport(201,201,200,200)%1+MYSCREEN.screenRect(3)/3, 0, MYSCREEN.screenRect(3)/3, MYSCREEN.screenRect(4))
        %         end
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        % Field of view is 50 degrees from line of sight. Objects closer than
        % 0.1 distance units or farther away than 100 distance units get clipped
        % away, aspect ratio is adapted to the monitors aspect ratio:
        % gluPerspective(25,1/ar,0.1,100);
        switch EXP.roomType
            
            case 'NOWALLS'
                gluPerspective(atan(MYSCREEN.MonitorHeight/(2*MYSCREEN.Dist))*360/pi,1/ar,0.1,100);
            case 'HALF'
                gluPerspective(50,1/ar,0.1,0.5*EXP.roomLength);
            otherwise
                %                 gluPerspective(atan(MYSCREEN.MonitorHeight/(2*MYSCREEN.Dist))*360/pi,1/ar,0.1,1.5*EXP.roomLength);
                gluPerspective(atan(MYSCREEN.MonitorHeight/(2*MYSCREEN.Dist))*360/pi,1/ar,0.1,50);
        end
        
        
        % Setup modelview matrix: This defines the position, orientation and
        % looking direction of the virtual camera:
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;
        
        % Set background color to 'gray':
        glClearColor(0.5,0.5,0.5,1);
        
        
        % % Point lightsource at (1,roomHeight-1,-25)...
        %         glLightfv(GL.LIGHT0,GL.POSITION,[ 1 EXP.roomHeight-1 -EXP.roomLength/2 0 ]);
        
        % Emits white (1,1,1,1) diffuse light:
        %glLightfv(GL.LIGHT0,GL.DIFFUSE, [ 0.0 0.0 0.0 1 ]);
        
        % There's also some white, but weak (R,G,B) = (0.1, 0.1, 0.1)
        % ambient light present:
        glLightfv(GL.LIGHT0,GL.AMBIENT, [ 0.5 0.5 0.5 1 ]);
        
        glShadeModel(GL.SMOOTH);
        
        glClear;
        
        glPushMatrix;
        glRotated (0,1,0,0); % to look a little bit downward
        
        glRotated (TRIAL.posdata(count,T)/pi*180,0,1,0);
        
        glTranslated (-TRIAL.posdata(count,X),-EXP.c3,-TRIAL.posdata(count,Z));
        
        
        %            glTranslated (-dax,0,dbx);
        % implement drawscene
        % DrawScene()
        %         glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0.5 0.5 0.5 1 ]);
        %% Draw textures
        for k=1:ROOM.nOfWalls
            switch k
                case 1
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.farWallText)),ROOM.wrap(k,:));
                case 2
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.nearWallText)),ROOM.wrap(k,:));
                case 3
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.leftWallText)),ROOM.wrap(k,:));
                case 4
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.rightWallText)),ROOM.wrap(k,:));
                case 5
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.ceilingText)),ROOM.wrap(k,:));
                case 6
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.floorText)),ROOM.wrap(k,:));
                otherwise
                    wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex('WHITENOISE')),ROOM.wrap(k,:));
            end
        end
        
%         for k=1:ROOM.nOfWalls
%             if k < 17
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.backgroundText)),ROOM.wrap(k,:));
%             elseif k < 18 % leg 1 text 1
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg1Text1)),ROOM.wrap(k,:));
%             elseif k < 19 % leg 1 text 2
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg1Text2)),ROOM.wrap(k,:));
%             elseif k < 20 % leg 1 text 3
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg1Text3)),ROOM.wrap(k,:));
%             elseif k < 21 % leg 1 text 4
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg1Text4)),ROOM.wrap(k,:));
%             elseif k < 22 % leg 2 text 1
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg2Text1)),ROOM.wrap(k,:));
%             elseif k < 23 % leg 2 text 2
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg2Text2)),ROOM.wrap(k,:));
%             elseif k < 24 % leg 2 text 3
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg2Text3)),ROOM.wrap(k,:));
%             elseif k < 25 % leg 2 text 4
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg2Text4)),ROOM.wrap(k,:));
%             elseif k < 26 % leg 3 text 1
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg3Text1)),ROOM.wrap(k,:));
%             elseif k < 27 % leg 3 text 2
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg3Text2)),ROOM.wrap(k,:));
%             elseif k < 28 % leg 3 text 3
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg3Text3)),ROOM.wrap(k,:));
%             elseif k < 29 % leg 3 text 4
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg3Text4)),ROOM.wrap(k,:));
%             elseif k < 30 % leg 4 text 1
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg4Text1)),ROOM.wrap(k,:));
%             elseif k < 31 % leg 4 text 2
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg4Text2)),ROOM.wrap(k,:));
%             elseif k < 32 % leg 4 text 3
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg4Text3)),ROOM.wrap(k,:));
%             elseif k < 33 % leg 4 text 4
%                 wallface (ROOM.v, ROOM.order(k,:),ROOM.normals(k,:),texname(getTextureIndex(EXP.Leg4Text4)),ROOM.wrap(k,:));
%             end
%         end

        glPushMatrix;
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', MYSCREEN.windowPtr(1));
        
        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', MYSCREEN.windowPtr(1));

% drawbases
%         for n = 1: numel(TRIAL.bases)
%             %   fprintf ('trying to draw bases \n');
%             if (TRIAL.bases(n).active == 1)
%                 drawbase(TRIAL.bases(n), 12,texname(getTextureIndex(EXP.baseTexture)),texname(getTextureIndex('GRAY')),EXP.baseType);
%                 TRIAL.basedata(count,1) = n;
%             end
%         end
        glPopMatrix;
        glPopMatrix;
        %     end
        

%% start drawing
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', MYSCREEN.windowPtr(1));
        
        % Show the sync square
        % alternate between black and white with every frame
        Screen('FillRect', MYSCREEN.windowPtr(1), mod(count,2)*255, SYNC.rect);
        
        %         glFlush;
        % Show rendered image at next vertical retrace:
        Screen('Flip', MYSCREEN.windowPtr(1));
        
        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', MYSCREEN.windowPtr(1));
        
        % get new coordinates
        count = count+1;
        
        if REPLAY
            if (count > length(TRIAL.time))
                fhandle = @trialEnd;
                TRIAL.info.abort =1;
                break
            elseif TRIAL.time(count) == 0
                fhandle = @trialEnd;
                TRIAL.info.abort =1;
                break
            end
        end
        TRIAL.time(count) = GetSecs;
        TRIAL.info.epoch = count;
        
%% get movement and draw        
        if ~OFFLINE
            [ballTime, dax, dbx, day, dby] = getBallDeltas(myPort);
        else
            getNonBallDeltas;
            ballTime = TRIAL.time(count);
            dax = MOUSEXY.dax;
            day = MOUSEXY.day;
            dbx = MOUSEXY.dbx;
            dby = MOUSEXY.dby;
        end
        
        TRIAL.balldata(count,:) = [ballTime, dax, dbx, day, dby];
        
%         dax = nansum([dax 0]).*BALL_TO_ROOM.*EXP.xGain;
        dbx = nansum([dbx 0]).*BALL_TO_ROOM.*EXP.zGain;
%         day = nansum([day 0]).*BALL_TO_DEGREE*PI_OVER_180*EXP.aGain;
        
        
            % update x, z positions and viewangle
            getTrajectory(dbx, count, X, Y, Z, T)
        if ~REPLAY
            TRIAL.traj(count) = TRAJ;
        end
        
        if TRIAL.nCompTraj > SAVE_COUNT + 1
            s = sprintf('%s_trial%03d', SESSION_NAME, TRIAL.info.no);
            save(s, 'TRIAL', 'EXP', 'REWARD','ROOM');
            SAVE_COUNT = TRIAL.nCompTraj;
        end
        
        if TRIAL.nCompTraj > EXP.maxTraj
            fhandle = @trialEnd;
            break
%             if ~OFFLINE
%                 pnet( ZirkusPort,'write',['BlockEnd MOUSE ' SESSION_NAME]);
%                 pnet(ZirkusPort, 'writePacket');
%             end
%             s = sprintf('%s_trial%03d', SESSION_NAME, TRIAL.info.no);
%             save(s, 'TRIAL', 'EXP', 'REWARD','ROOM');
%             fhandle = @endOfExperiment;
%             return
        end
            
%         check if out of room
%                 if (abs(TRIAL.posdata(count,X))> (EXP.roomWidth - 3)) 
%                     %|| (abs(TRIAL.bases(lastActiveBase).center(3))> EXP.roomLength )
% %                         
%                     if ~EXP.restrictInRoom 
%                         
%                     elseif TRIAL.posdata(count,X)> (EXP.roomWidth - 3)
%                         TRIAL.posdata(count,X) = EXP.roomWidth - 3;
%                     elseif TRIAL.posdata(count,X)< -EXP.roomWidth + 3
%                         TRIAL.posdata(count,X) = -EXP.roomWidth + 3;
%                     elseif (abs(TRIAL.bases(lastActiveBase).center(3))> EXP.roomLength )
%                         if ~EXP.restrictInRoom
%                             fhandle = @trialEnd;
%                             if REPLAY
%                                 TRIAL.info.abort =1;
%                             end
%                             break
%                         end
%                     end
%                 end
        
%% check if not moved significantly
%         if(count<10)
%             speed = mean(diff(TRIAL.traj(1:count)));
%         else
%             speed = mean(diff(TRIAL.traj(count-9:count)));
%         end
%         if ( speed <= EXP.lazyTolerance)
%             if (isLazy == 1)
%                 lazyDur = toc(lazyStart);
%                 if(lazyDur > EXP.lazyTimeLimit)
%                     fprintf ('lazy for too long');
%                     
%                     if (TRIAL.bases(lastActiveBase).active==1)
%                         TRIAL.bases(lastActiveBase).active=0;
%                         TRIAL.bases(lastActiveBase).outcome='TIME OUT';
%                     end
%                     lazyDur = 0;
%                     lazyStart = [];
%                     isLazy = 0;
%                     
%                     if(~OFFLINE)
%                         timeOut(myPort);
%                     else
%                         timeOut;
%                     end
%                     %fhandle = @timeOut;
%                     %break;
%                 end
%             else
%                 isLazy = 1;
%                 lazyStart = tic;
%             end
%         else % if not lazy reset lazy related parameters
%             lazyDur = 0;
%             lazyStart = [];
%             isLazy = 0;
%         end
%         
        
 %% 
%         if( isLazy && lazyDur > EXP.stopTime)
%             if(lastActiveBase == 0 || ...
%                     (lastActiveBase ~= 0 && TRIAL.bases(lastActiveBase).visited ~= 0 && TRIAL.bases(lastActiveBase).active == 0))
%                 lastActiveBase = lastActiveBase +1;
%                 if(lastActiveBase == ROOM.nOfBases)
%                     fhandle = @trialEnd;
%                     TRIAL.info.abort =1;
%                     break;
%                 else
%                     TRIAL.bases(lastActiveBase).center(3) = TRIAL.posdata(count,Z)-(EXP.baseDistance*...
%                         cos(TRIAL.posdata(count,T)+ deg2rad(TRIAL.bases(lastActiveBase).center(4))));
%                     TRIAL.bases(lastActiveBase).center(1) = TRIAL.posdata(count,X)+(EXP.baseDistance*...
%                         sin(TRIAL.posdata(count,T)+ deg2rad(TRIAL.bases(lastActiveBase).center(4))));
%                     
%                     TRIAL.bases(lastActiveBase).mirrorCenter(3) = TRIAL.posdata(count,Z)-(EXP.baseDistance*...
%                         cos(TRIAL.posdata(count,T)+ deg2rad(TRIAL.bases(lastActiveBase).mirrorCenter(4))));
%                     TRIAL.bases(lastActiveBase).mirrorCenter(1) = TRIAL.posdata(count,X)+(EXP.baseDistance*...
%                         sin(TRIAL.posdata(count,T)+ deg2rad(TRIAL.bases(lastActiveBase).mirrorCenter(4))));
%                     %Check if out of room
%                     if ((abs(TRIAL.bases(lastActiveBase).center(3))+EXP.baseRadius)> EXP.roomLength ||...
%                             ((abs(TRIAL.bases(lastActiveBase).center(1))+EXP.baseRadius)> EXP.roomWidth && ~EXP.restrictInRoom)||...
%                             (abs(TRIAL.bases(lastActiveBase).mirrorCenter(3))+EXP.baseRadius)> EXP.roomLength ||...
%                             ((abs(TRIAL.bases(lastActiveBase).mirrorCenter(1))+EXP.baseRadius)> EXP.roomWidth && ~EXP.restrictInRoom))
% %                         if ~EXP.restrictInRoom
%                             fhandle = @trialEnd;
%                             if REPLAY
%                                 TRIAL.info.abort =1;
%                             end
%                             break
% %                         end
%                         
%                     end
%                     TRIAL.bases(lastActiveBase).active = 1;
%                     TRIAL.bases(lastActiveBase).visited = 1;
%                     
%                     TRIAL.bases(lastActiveBase).stopPosition = [TRIAL.posdata(count,X),0 ,TRIAL.posdata(count,Z)];
%                     TRIAL.bases(lastActiveBase).stopViewAngle = TRIAL.posdata(count,T);
%                     TRIAL.bases(lastActiveBase).activationTime = getSecs;
%                     TRIAL.bases(lastActiveBase).activationCount = count;
%                     
%                     giveReward(TRIAL.time(count)-TRIAL.time(2), 'STOP', lastActiveBase);
%                     TRIAL.bases(lastActiveBase).rewardCount = 1+TRIAL.bases(lastActiveBase).rewardCount;
%                     TRIAL.basedata(count,2) = STOP;
%                     TRIAL.bases(lastActiveBase).rewardTime = [TRIAL.bases(lastActiveBase).rewardTime GetSecs];
%                 end
%                 if  ~OFFLINE
%                     pnet( ZirkusPort,'write',['TrialStart MOUSE ' int2str(1) ' '  int2str(TRIAL.info.no) ' ' int2str(lastActiveBase)]);
%                     pnet(ZirkusPort, 'writePacket');
%                 end
%                 
%             end
%         end
        
        currentPos = [TRIAL.posdata(count,X) TRIAL.posdata(count,Y) TRIAL.posdata(count,Z)];
        
        
%         if(lastActiveBase ~=0 && ~isLazy && TRIAL.bases(lastActiveBase).active==1)
%             
%             [direction distance perf] = whereIsItGoing(currentPos,...
%                 lastActiveBase);
%             
%             if (distance > EXP.minDistance)
%                 TRIAL.bases(lastActiveBase).performance = perf;
%                 switch direction
%                     case 'TIME OUT' % wrong direction out of tolerance limit
%                         %if( distance > 15 )
%                         if(~OFFLINE)
%                             timeOut(myPort);
%                         else
%                             timeOut;
%                         end
%                         TRIAL.bases(lastActiveBase).active=0;
%                         TRIAL.bases(lastActiveBase).visited=2;
%                         TRIAL.bases(lastActiveBase).outcome='TIME OUT';
%                         TRIAL.bases(lastActiveBase).resultCount = count;
%                         %end
%                         %break;
%                     case 'CORRECT' % right direction towards the right cue
%                         TRIAL.bases(lastActiveBase).visited=2;
% %                         giveReward(TRIAL.time(count)-TRIAL.time(2), 'BASE', lastActiveBase);
%                         TRIAL.bases(lastActiveBase).rewardCount = 1+TRIAL.bases(lastActiveBase).rewardCount;
%                         TRIAL.basedata(count,2) = BASE;
%                         TRIAL.bases(lastActiveBase).rewardTime = [TRIAL.bases(lastActiveBase).rewardTime GetSecs];
%                         TRIAL.bases(lastActiveBase).active=0;
%                         TRIAL.bases(lastActiveBase).outcome='CORRECT';
%                         TRIAL.bases(lastActiveBase).resultCount = count;
%                         s = sprintf('%s_trial%03d', SESSION_NAME, TRIAL.info.no);
%                         %                         save(s, 'TRIAL', 'EXP',
%                         'REWARD','ROOM');
%                         
%                     case 'WRONG' % wrong direction towards the wrong cue
%                         
%                         TRIAL.bases(lastActiveBase).active=0;
%                         TRIAL.bases(lastActiveBase).outcome='WRONG';
%                         TRIAL.bases(lastActiveBase).resultCount = count;
%                         playSound('WRONG');
%                         s = sprintf('%s_trial%03d', SESSION_NAME, TRIAL.info.no);
%                         save(s, 'TRIAL', 'EXP', 'REWARD','ROOM');
%                         
%                         %                     case 'NO CHOICE'
%                         %                         if(GetSecs-TRIAL.bases(lastActiveBase).activationTime >15 || distance > 15 )
%                         %                             TRIAL.bases(lastActiveBase).active=0;
%                         %                             TRIAL.bases(lastActiveBase).outcome='NO CHOICE';
%                         %                             s = sprintf('%s_trial%03d', SESSION_NAME, TRIAL.info.no);
%                         %                             save(s, 'TRIAL', 'EXP');
%                         %
%                         %                         end
%                 end
%             end
%         end
        
        
        
%         if (toc(t1)>EXP.maxTrialDuration)
%             fhandle = @trialEnd;
%             timeIsUp = 1;
%             fprintf('Time is up \n')
%         end
        
        if checkKeyboard
            TRIAL.info.abort =1;
            fhandle = @trialEnd;
%             if(TRIAL.bases(lastActiveBase).active==1)
%                 TRIAL.bases(lastActiveBase).outcome='USER ABORT';
%             end
        end
        
        
    end
    
catch ME
    fprintf(['exception : ' ME.message '\n']);
    fprintf(['line #: ' num2str(ME.stack(1,1).line)]);
    TRIAL.info.abort = 1;
    fhandle = @trialEnd;
    %           glDeleteTextures(length(texname),texname);
    
    %           Screen('EndOpenGL', MYSCREEN.windowPtr);
%     Screen('CloseAll');
%     ListenChar(0);
%     psychrethrow(psychlasterror);
    
end %try..catch..


%% close udp port and reset priority level
if ~OFFLINE
    pnet(myPort,'close');
end

ListenChar(0);
Priority(0);

%% Delete all allocated OpenGL textures:
glDeleteTextures(length(texname),texname);

Screen('EndOpenGL', MYSCREEN.windowPtr(1));


heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end


end