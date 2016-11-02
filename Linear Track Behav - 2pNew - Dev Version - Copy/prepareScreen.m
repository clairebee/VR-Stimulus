function myscreen = prepareScreen(whichScreen,rigInfo,expInfo)
% initializes screen: ltScreenInitialize [Screen('OpenWindow',...)]
% loads calibration: ltLoadCalibration
% asks for screen distance 
% global OFFLINE;
% global REPLAY;


% screen distance
myscreen.Dist = 34;

Dist = input(['Enter screen distance (' num2str(rigInfo.screenDist) ' cm is usual): ']);

% Prompt = {'What is the screen distance in cm [35]:'};
% dlg_title = 'SCREEN DISTANCE';
% num_lines = 1;
% def = {'34'};

% if OFFLINE || REPLAY
%     Dist = 34;
%     Answer = inputdlg(Prompt,dlg_title,num_lines,def);
%     Dist = str2num(Answer{1});
% else
%     Answer = inputdlg(Prompt,dlg_title,num_lines,def);
%     Dist = str2num(Answer{1});
% %     Dist = input('---------------> Screen distance in cm [35] : ');
% end

screens=Screen('Screens');
try
	myscreen = initializeScreen(whichScreen, rigInfo, expInfo);
catch
	Screen('CloseAll');
	psychrethrow(psychlasterror);
	return
end

if ~isnumeric(Dist) || isempty(Dist)
    fprintf('<prepareScreen> Using default screen distance\n');
else
    myscreen.Dist = Dist;
end



% when monitor is calibrated
% load new gamma table, which linearizes monitor luminance
if ~expInfo.OFFLINE & ~strcmp(rigInfo.computerName,'ZOOROPA') & ~strcmp(rigInfo.computerName,'ZURPRISE')
    Calibration.Load(myscreen);
    display('*********** Loaded calibration file ************')
end

fprintf('done\n');