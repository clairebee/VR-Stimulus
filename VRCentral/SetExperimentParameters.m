function [exp, exp_out] = SetExperimentParameters(animalName, RIGinfo)

if nargin>1
    dataDir = RIGinfo.dirSave;
    codeDir = RigInfo.dirCode;
else
    dataDir = '\\zserver.ioo.ucl.ac.uk\Data\Ball';
    codeDir = '\\zserver.ioo.ucl.ac.uk\Code\MouseRoom\VRCentral\';
end

VRchoose.numExpt = 1;

MainFig = figure('Name', 'VR Controller',...
    'MenuBar', 'none',...
    'Toolbar', 'none',...
    'NumberTitle', 'off',...
    'Units', 'normalized',...
    'OuterPosition', [0.1 0.1 0.6 0.85]);%...

VRchoose.Panels = uiextras.TabPanel('Parent',MainFig);

VRchoose.All = uiextras.VBox('Parent',VRchoose.Panels,'Spacing',10,'Padding',5);
VRchoose.ExpLive = uiextras.HBox('Parent',VRchoose.Panels,'Spacing',10,'Padding',5);
set(VRchoose.Panels,'FontSize',12)
set(VRchoose.Panels,'TabSize',150)
set(VRchoose.Panels,'FontWeight','bold')
VRchoose.Panels.TabNames = {'New','Live'};
VRchoose.Panels.SelectedChild = 1;

VRchoose.Top = uiextras.HBox('Parent',VRchoose.All,'Spacing',10,'Padding',5);
VRchoose.Bottom = uiextras.Empty('Parent',VRchoose.All);
VRchoose.All.Sizes = [-1 -3];

VRchoose.choosePanel = uiextras.Panel('Parent',VRchoose.Top,...
    'Title','Choose Animal & Maze');%, 'fontsize',12);
VRchoose.chooseAnimal = uiextras.VBox('Parent',VRchoose.choosePanel,'Spacing',10,'Padding',5);
VRchoose.serverPanel  = uiextras.Panel('Parent',VRchoose.Top,...
    'Title','Stimulus server connection');%, 'fontsize',12);
VRchoose.Top.Sizes = [-1 -1];

ca = chooseAnimal;
ca.VRchoose = VRchoose;
ca.dataDir = dataDir;
ca.codeDir = codeDir;
ca.createUI;
animalName = ca.animal;
nCond = ca.numCond;
VRtype = ca.VRType;
VRchoose = ca.VRchoose;

% [animalName, nCond, VRtype, VRchoose] = chooseAnimal_new(dataDir, codeDir, VRchoose);


AnimalDir = fullfile(dataDir, animalName);
if ~exist(AnimalDir); mkdir(AnimalDir); end

try
    load([AnimalDir filesep 'EXP']);
    exp.Meta.AnimalName = animalName;
    exp.StimFix.VRType = ca.VRType;
    %JUL - 27.07.2015
    %Call ChangenTrialTypes to change the number of trial types
    if ~exist('nCond')
        nCond = 24;
    end
    numCond = 1;
    for iStim = 1:length(exp.StimVar)
        if numCond<length(exp.StimVar(iStim).trialVal)
            numCond=length(exp.StimVar(iStim).trialVal);
        end
    end
    if numCond~=nCond
        display('Different number of condition, choosing new number!');
        exp = ChangenTrialTypes(exp, nCond);
    end
    if strcmp(VRtype,'linCirc')
        exp.CircularMaze = 1;
    else
        exp.CircularMaze = 0;
    end
catch
    display('No basic file, loading all the parameters from scratch...');
    display('!!!!! Check parameters carefully !!!!!');
    %     nCond = 9;
    exp = BaseData(nCond);
end

if nargin>1
    XYpos = RIGinfo.dialogueXYPosition;
else
    monSize = (get(0, 'MonitorPositions'))';
    XYpos = [monSize(3)/2 100];
end

VRparameters = createUI(exp, XYpos);

v = VRClientConnector;
v = v.createUI(VRchoose, VRparameters);

client(VRchoose.numExpt) = v.client{v.currExp};
VRchoose = v.VRchoose;

if nargout>1
    send_output = 1;
else
    send_output = 0;
end

uiwait(MainFig);

% save([AnimalDir filesep 'EXP'], 'exp');
clear VRparameters VRchoose

    function startloop
        VRchoose.running = 1;
        while VRchoose.running
            VRchoose.running = 0;
            for numExps = 1:length(VRchoose.ev)
                if VRchoose.ev(numExps).isActive
                    VRchoose.ev(numExps).readMsg;
                    VRchoose.ev(numExps).update;
                    VRchoose.running = 1;
                end
            end
            pause(1e-1)
        end
    end

    function VRparameters = createUI(exp, XYpos)
        %         VRparameters.mainFig = figure('Name', 'VR experiment parameters',...
        %             'Position', [XYpos 800 700], ...
        %             'MenuBar', 'none', ...
        %             'ToolBar', 'none', ...
        %             'NumberTitle', 'off');
        %
        VRparameters.mainFig = uiextras.Panel('Parent', VRchoose.Bottom, ...
            'Title','VR Experiment Parameters');%, 'fontsize',12);
        
        % Tabs and save option
        VRparameters.main = uiextras.VBox('Parent',VRparameters.mainFig,'Spacing',10,'Padding',5);
        VRparameters.metaData = uiextras.VBox('Parent',VRparameters.main);
        VRparameters.tabs = uiextras.TabPanel('Parent',VRparameters.main);
        VRparameters.Buttons = uiextras.HBox('Parent',VRparameters.main,'Spacing',10,'Padding',5);
        VRparameters.saveButton = uicontrol('Parent',VRparameters.Buttons,'String','SET','fontsize',12,'Enable','on', 'Callback', @(~,~) setPara, 'FontWeight','bold');
        VRparameters.runButton = uicontrol('Parent',VRparameters.Buttons,'String','RUN','fontsize',12,'Enable','on', 'Callback', @(~,~) runExp, 'FontWeight','bold');
        set(VRparameters.runButton, 'Enable','off','BackgroundColor',[1 0.5 0.5]);
        
        % The Tabs
        VRparameters.StimFixTab   = uiextras.HBox('Parent',VRparameters.tabs,'Spacing',10,'Padding',5);
        VRparameters.StimVarTab   = uiextras.VBox('Parent',VRparameters.tabs,'Spacing',10,'Padding',5);
        VRparameters.TexturesTab  = uiextras.VBox('Parent',VRparameters.tabs,'Spacing',10,'Padding',5);
        VRparameters.RigInfoTab   = uiextras.HBox('Parent',VRparameters.tabs,'Spacing',10,'Padding',5);
        
        VRparameters.StimFixBox   = uiextras.BoxPanel('Parent',VRparameters.StimFixTab, 'Title','Stimuli','FontSize',14);
        VRparameters.MazeBox      = uiextras.BoxPanel('Parent',VRparameters.StimFixTab, 'Title','Maze','FontSize',14);
        VRparameters.RewardBox    = uiextras.BoxPanel('Parent',VRparameters.StimFixTab, 'Title','Reward','FontSize',14);
        VRparameters.RigInfoBox   = uiextras.BoxPanel('Parent',VRparameters.RigInfoTab, 'Title','Rig Info','FontSize',14);
        VRparameters.UserBox      = uiextras.BoxPanel('Parent',VRparameters.RigInfoTab, 'Title','User','FontSize',14);
        
        set(VRparameters.tabs,'FontSize',12)
        set(VRparameters.tabs,'TabSize',150)
        set(VRparameters.tabs,'FontWeight','bold')
        tabNames = fieldnames(exp);
        tabNames = tabNames(2:end);
        VRparameters.tabs.TabNames = {'Fixed Stimuli','Variable Stimuli','Textures','RigInfo'}; %fieldnames(exp);%{'Stimuli','Reward','Maze','Textures','User','Rig info'};
        
        VRparameters.tabs.SelectedChild = 2;
        VRparameters.main.Sizes = [-1 -5 -1];
        
        %% This is displaying the current information
        varNames = fieldnames(exp.Meta);
        varValue = struct2cell(exp.Meta);
        VRparameters.MetaInfo = uitable(...
            'Parent', VRparameters.metaData,...
            'Data',[varNames varValue],...
            'ColumnWidth',{100}, ...
            'RowName', [],...
            'ColumnName', []);%, 'fontsize',12);
        
        nTabs = length(fieldnames(exp));
        for iTab = 2:nTabs
            
            if iTab == 2
                rownames = fieldnames(exp.StimFix);
                data = struct2cell(exp.StimFix);
                colnames = [];
                VRparameters.StimFixInfo = uitable(...
                    'Parent', VRparameters.StimFixBox,...
                    'Data',data,...
                    'RowName', rownames,...
                    'FontSize',10, ...
                    'ColumnName', colnames, ...
                    'ColumnEditable',[true]);
            end
            if iTab == 3
                for iVar = 1:length(exp.StimVar)
                    varNames{iVar} = exp.StimVar(iVar).name;
                    varOrNot(iVar) = exp.StimVar(iVar).variable;
                    baseVal(iVar)  = exp.StimVar(iVar).base;
                    addVal(iVar,:) = round(100*exp.StimVar(iVar).trialVal);
                    %                     mat2cell(cell2mat(exp.StimVar(iVar).trialVal)*100);
                    
                    data1{iVar,1} = exp.StimVar(iVar).variable;
                    data1{iVar,2} = exp.StimVar(iVar).base;
                end
                rownames = [];
                colnames1 = {'Vary?','Base'};
                colformat1 = {'logical','bank'};
                coledit1  = [true,true];
                %                 colwidth = [75 75];
                colformat2 = [];
                coledit2   = [];
                for iTrial = 1:size(addVal,2)
                    % colnames{end+1}  = num2str(iTrial);
                    colformat2{end+1} = 'numeric';
                    coledit2(end+1)   = true;
                    %                     colwidth{end+1} = 50;
                end
                data2 = addVal;
                VRparameters.SeqRandButtons = uiextras.HBox('Parent',VRparameters.StimVarTab,'Spacing',10,'Padding',5);
                VRparameters.StimVarMatrix  = uiextras.HBox('Parent',VRparameters.StimVarTab,'Spacing',10,'Padding',5);
                VRparameters.SeqButton = uicontrol('Parent',VRparameters.SeqRandButtons,'String','Sequential','fontsize',12,'Enable','off', 'Callback', @(~,~) Controller.runSeq,'FontWeight','normal');
                VRparameters.RandButton = uicontrol('Parent',VRparameters.SeqRandButtons,'String',['Random', ' (not active)'],'fontsize',12,'Enable','on', 'Callback', @(~,~) Controller.runRand,'FontWeight','normal');
                
                VRparameters.StimVarInfo1 = uitable(...
                    'Parent', VRparameters.StimVarMatrix,...
                    'Data',data1,...
                    'RowName', varNames,...
                    'ColumnName', colnames1,...
                    'ColumnFormat',colformat1,...
                    'ColumnWidth',{40},...
                    'FontSize',9, ...
                    'ColumnEditable',logical(coledit1));
                VRparameters.StimVarInfo2 = uitable(...
                    'Parent', VRparameters.StimVarMatrix,...
                    'Data',data2,...
                    'RowName', [],...
                    ... 'ColumnName', colnames,...
                    'ColumnFormat',colformat2,...
                    'ColumnWidth',{45},...
                    'FontSize',9, ...
                    'ColumnEditable',logical(coledit2));
                
                set(VRparameters.StimVarTab,'Sizes',[-1 -4]);
                set(VRparameters.StimVarMatrix,'Sizes',[-2 -5]);
            end
            if iTab==4
                rownames = fieldnames(exp.Reward);
                data = struct2cell(exp.Reward);
                colnames = [];
                VRparameters.RewardInfo = uitable(...
                    'Parent', VRparameters.RewardBox,...
                    'Data',data,...
                    'RowName', rownames,...
                    'FontSize',10, ...
                    'ColumnName', colnames, 'ColumnEditable',[true]);
                
            end
            if iTab ==5
                rownames = fieldnames(exp.Maze);
                data = struct2cell(exp.Maze);
                colnames = [];
                VRparameters.MazeInfo = uitable(...
                    'Parent', VRparameters.MazeBox,...
                    'Data',data,...
                    'RowName', rownames,...
                    'FontSize',10, ...
                    'ColumnName', colnames, 'ColumnEditable',[true]);
            end
            if iTab==6
                rownames = fieldnames(exp.Textures);
                data = struct2cell(exp.Textures);
                colnames = [];
                VRparameters.TexturesInfo = uitable(...
                    'Parent', VRparameters.TexturesTab,...
                    'Data',data,...
                    'RowName', rownames,...
                    'FontSize',10, ...
                    'ColumnWidth', {150}, ...
                    'ColumnName', colnames, 'ColumnEditable',[true]);
            end
            if iTab==7
                rownames = fieldnames(exp.User);
                data = struct2cell(exp.User);
                colnames = [];
                VRparameters.UserInfo = uitable(...
                    'Parent', VRparameters.UserBox,...
                    'Data',data,...
                    'RowName', rownames,...
                    'FontSize',10, ...
                    'ColumnWidth', {150}, ...
                    'ColumnName', colnames, 'ColumnEditable',[true]);
            end
            if iTab==8
                rownames = fieldnames(exp.RigInfo);
                data = struct2cell(exp.RigInfo);
                colnames = [];
                VRparameters.RigInfoInfo = uitable(...
                    'Parent', VRparameters.RigInfoBox,...
                    'Data',data,...
                    'RowName', rownames,...
                    'FontSize',10, ...
                    'ColumnWidth', {150}, ...
                    'ColumnName', colnames, 'ColumnEditable',[true]);
                
                % Need to add the following, RigName, NI device, num hosts, screen
                % number, location of file, Calibration file....
            end
        end
    end


%% This is converting the new structure to the old format
    function [exp, exp_out] = runOutput(VRparameters)
        
        exp_out = [];
        exp.StimFix = [];
        exp.RigInfo = [];
        exp.User = [];
        exp.Textures = [];
        exp.Maze = [];
        exp.Reward = [];
        exp.Meta = [];
        
        %         names = get(VRparameters.MetaInfo,'RowName');
        values =get(VRparameters.MetaInfo,'Data');
        for n = 1:size(values,1)
            exp.Meta = setfield(exp.Meta, values{n,1}, values{n,2});
        end
        
        [exp.StimFix, exp_out] = appendDetails(exp.StimFix, exp_out, VRparameters.StimFixInfo);
        [exp.RigInfo, exp_out] = appendDetails(exp.RigInfo, exp_out, VRparameters.RigInfoInfo);
        [exp.User, exp_out] = appendDetails(exp.User, exp_out, VRparameters.UserInfo);
        [exp.Textures, exp_out] = appendDetails(exp.Textures, exp_out, VRparameters.TexturesInfo);
        [exp.Maze, exp_out] = appendDetails(exp.Maze, exp_out, VRparameters.MazeInfo);
        [exp.Reward, exp_out] = appendDetails(exp.Reward, exp_out, VRparameters.RewardInfo);
        
        VarNames = get(VRparameters.StimVarInfo1,'RowName');
        VarDataA = get(VRparameters.StimVarInfo1,'Data');
        VarDataB = get(VRparameters.StimVarInfo2,'Data');
        
        for iVar = 1:length(VarNames)
            exp.StimVar(iVar).name = VarNames{iVar};
            exp.StimVar(iVar).base = VarDataA{iVar,2};
            exp.StimVar(iVar).variable = VarDataA{iVar,1};
            exp.StimVar(iVar).trialVal = VarDataB(iVar,:)./100;
            if VarDataA{iVar,1}==0
                exp_out = setfield(exp_out,  VarNames{iVar}, VarDataA{iVar,2});
            else
                valuesSet = VarDataA{iVar,2}*VarDataB(iVar,:)./100;
                exp_out = setfield(exp_out,  VarNames{iVar}, valuesSet);
            end
        end
        
    end

%% Basic setting up
    function [exp_other, exp_out] = appendDetails(exp_other, exp_out, inputs)
        names = get(inputs,'RowName');
        values =get(inputs,'Data');
        for n = 1:length(names)
            exp_out   = setfield(exp_out,   names{n}, values{n});
            exp_other = setfield(exp_other, names{n}, values{n});
        end
    end

%% Output functions
    function setPara
        % Just save in the appropriate folder.
        [exp, exp_out] = runOutput(VRparameters);
        client(VRchoose.numExpt).close
        %         uiresume(MainFig);
    end

    function runExp
        % Save in the appropriate folder and start running the experiment.
        [exp, exp_out] = runOutput(VRparameters);
        replay_in = 0;
        
        VRchoose.ev(VRchoose.numExpt) = VRexpview;
        VRchoose.ev(VRchoose.numExpt).client = client(VRchoose.numExpt);
        VRchoose.ev(VRchoose.numExpt).animalName = ca.animal;
        VRchoose.ev(VRchoose.numExpt).createUI(VRchoose.ExpLive);
        VRchoose.Panels.SelectedChild = 2;
        
        set(VRchoose.clientUI.textB,...
                'BackgroundColor',[1 0.5 0.5],...
                'String','Disconnected',...
                'fontsize',14,'Enable','off');
            
        if VRchoose.numExpt == 1;
            uiextras.Empty('Parent',VRchoose.ExpLive);
        end
        
        client(VRchoose.numExpt).startExperiment(ca.animal, ca.replay, exp_out);
        
        VRchoose.numExpt = VRchoose.numExpt + 1;
        set(VRchoose.clientUI.StatusButton,'Enable','on')
        set(VRchoose.clientUI.popup,'Enable','on')
        
        v.addExp;
        VRchoose.numExpt = v.currExp
        client(VRchoose.numExpt) = v.client{v.currExp};
        
%         ca.isChosen = 1;
        set(ca.VRchoose.animalChoice.popup, 'Enable','on')
        set(ca.VRchoose.animalChoice.editA, 'Enable','on')
        set(ca.VRchoose.animalChoice.popup2, 'Enable','on')
        set(ca.VRchoose.animalChoice.editB, 'Enable','on')
        
        set(VRparameters.runButton, 'Enable','off')
        set(VRparameters.saveButton, 'Enable','off')
        
        startloop;
        %         uiresume(MainFig);
    end

%% function to change the number of trial types
    function exp = ChangenTrialTypes(exp, nCond)
        exp.StimFix.nTrialTypes = nCond;
        oldnCond = size(exp.StimVar(1).trialVal,2);
        
        exp.StimVar(1).trialVal = [exp.StimVar(1).trialVal(1,1:min(oldnCond,nCond)) ones(1,max(0,nCond - oldnCond))];
        exp.StimVar(2).trialVal = [exp.StimVar(2).trialVal(1,1:min(oldnCond,nCond)) ones(1,max(0,nCond - oldnCond))];
        exp.StimVar(3).trialVal = [exp.StimVar(3).trialVal(1,1:min(oldnCond,nCond)) ones(1,max(0,nCond - oldnCond))];
        exp.StimVar(4).trialVal = [exp.StimVar(4).trialVal(1,1:min(oldnCond,nCond)) ones(1,max(0,nCond - oldnCond))];
        exp.StimVar(5).trialVal = [exp.StimVar(5).trialVal(1,1:min(oldnCond,nCond)) ones(1,max(0,nCond - oldnCond))];
    end

%% function to load basic parameters if its a new file
    function exp = BaseData(nCond)
        if nargin<1
            nCond = 9;
        end
        exp.Meta = ...
            struct(...
            'AnimalName', 'test', ...
            'Species', 'C57BL6J', ...
            'SurgeryDate', '1 Jan 2014', ...
            'BaseWeight', '25g' ...
            );
        
        exp.StimFix = ...
            struct(...
            'CircularMaze', 0,...
            'maxTraj', 120, ...
            'pause_frames', 60*3, ...       %  ~2 secs pause between trials
            ... room related parameters that change on every trial
            'visibleDepth',     [150], ... % Generally ~ same distance in cm, check each distance (previously 500) *9.5/8
            ...
            'maxBadLicks', 15,...
            'punishLim', 6.5,...
            'PtoA', [0],...
            'rew_tol', 6.5, ...             % +/- extent of reward position
            ...
            'scaling', 0, ...
            'randScale', 0,...
            ...
            'changeLength', 0, ...
            'randLength', 0,...
            ...
            'randStart', 0, ...
            'startRegion', 0.01, ...
            ...
            'contrWalls', 1,...              % Change contrast on only textures (0) or on walls as well (1)
            'randContr', 0 ...
            ...
            );
        %modify # trial types here
        exp.StimFix.nTrialTypes = nCond;%9;
        
        exp.StimVar(1).name = 'contrLevels';
        exp.StimVar(1).variable = true;
        exp.StimVar(1).base = 0.6;
        exp.StimVar(1).trialVal = ones(1, exp.StimFix.nTrialTypes);%[1 1 1 0 1 1 1 0 1];%[1 1 1  1 0 1 1 1 1 1 1 1];
        
        exp.StimVar(2).name = 'lengthSet';
        exp.StimVar(2).variable = false;
        exp.StimVar(2).base = 1;
        exp.StimVar(2).trialVal = ones(1, exp.StimFix.nTrialTypes);%[1  1   1    0.75 1   1   1  1    1.25 1 1 1];
        
        exp.StimVar(3).name = 'scaleSet';
        exp.StimVar(3).variable = false;
        exp.StimVar(3).base = 1;
        exp.StimVar(3).trialVal = ones(1, exp.StimFix.nTrialTypes);%[1 0.7 0.7 1 1 1.3 1.3 1 1 1 1 1];
        
        exp.StimVar(4).name = 'active';
        exp.StimVar(4).variable = false;
        exp.StimVar(4).base = 1;
        exp.StimVar(4).trialVal = ones(1, exp.StimFix.nTrialTypes);%[0  1   1    1    1   1   1  1    1    1 1 1];
        
        exp.StimVar(5).name = 'rew_pos';
        exp.StimVar(5).variable = false;
        exp.StimVar(5).base = 70;
        exp.StimVar(5).trialVal = ones(1, exp.StimFix.nTrialTypes);%[1  1   1    1    -1  1   1  1    1    1 1 1];
        %         ...
        %             struct(...
        %             'contrLevels',  0.6*[1 1 1  1 0 1 1 1 1],...[1  1   0.3  1    0   1   1  1.2  1   ],...[1.25 1 1 0.75 1 1 0   1 1 1.25 0.75 1 1],...0.75*[1 1 1 1 0 1 1],...0.75*[1 1 1 1 1 1 1 0 1 1],...0.85*[1 1 1 1 1 0 0 0 1 1 1],...[1],...[1 1 1 1 0],...[1 1 1 1 1 0 1 1 1 0],...[1],...[1 1 1 0],... % List the levels of contrast to be used, contrast on any trial will be picked at random
        %             'lengthSet',        [1],...%[1  1   1    0.75 1   1   1  1    1.25],...[1 0.75 1 1 1.25 1 1    1 0.75 1 1 1 1.25],...[1],...[1],...[1 1 1.2 1 1 1 1 1 1 0.8](range 0.1 to 2)
        %             'scaleSet',         [1.0],...[1 0.7 0.7 1 1 1.3 1.3],...%[1  0.7 1    1    1   1.3 1  1    1   ],...[1],...[1 1 1.2 1 1 1 1 1 0.8 1],...[1],... (1: gives room size 1m, as room length is 100)
        %             'active',           [0 0 0  1 1 1 1 1 1],...  %[0  1   1    1    1   1   1  1    1   ],... 1   1    1    1   1   1  1    1   ],...[0 1 0 1 1 0 1    0 1 1 1 0 1],...[0 1 0 1 1 1 0],...[0 0 0 1 0  1 0 1 1 0],...[0 ones(1,4) ones(1,5) 0 ones(1,4) 0 ones(1,4) 0 ones(1,4) 0*ones(1,5) ones(1,5) 0 ones(1,4) 0 ones(1,4) 0 ones(1,4) 0*ones(1,5) ones(1,5) 0 ones(1,4) 0 ones(1,4) 0 ones(1,4)],... 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 1 1 1 1 0 1 1 1 1],...1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1],...                % 0: passive reward at centre, 1: active reward in region
        %             'rew_pos',       90*[1 1 1  1 -1 1 1 1 1]...[1  1   1    1    -1  1   1  1    1   ],...[50*ones(1,30) 70*ones(1,30) 50*ones(1,30)], ... [50],...            % centre of reward position
        %             );
        
        exp.Reward = ...
            struct(...
            ... reward related parameters
            'punishZone', 60,...
            ...
            ... 'rew_vis', 1, ...              % 1:rewards visual position, 0: rewards run position
            'maxNRewards', 2,...               % max number of rewards on a single base
            'rewardGap', 0.7, ...              % time in between two rewards on a single base
            'rewardDelay', 0.7, ...            % delay for the first reward
            ...
            'STOPvalveTime',0.00,...
            ...
            'rewCorners', 1,...
            'BASEvalveTime',3.0,...         % Reward for user , old ones
            'PASSvalveTime',3.5,...           % Reward for passive trial
            'ACTVvalveTime',3.5...           % Reward for active  trial
            );
        
        
        exp.Maze = ...
            struct(...
            'vh', 2,...    % -(h/2) + 'c3' is the viewing height
            'tw', 8, ...    % texture width
            'l', 100.0, ...
            'b', 8, ...     %
            'h', 8, ...     %
            'tc1', 20,...
            'tc2', 40,...
            'tc3', 60,...6
            'tc4', 80,...
            'delta', 0.05, ...
            'etw1', 0, ...
            'etw2', 0, ...
            ...
            'bidirec', 0, ...               % to go back and forth on the track
            'VRType', 'lin',...
            'trajDir', 'cw'...               %  'cw' clockwise, 'ccw' counter clockwise
            );
        
        exp.Textures = ...
            struct(...
            'textureFile','textures_hf_MiK4',... 'textures_hf_new',...       % WHITENOISE, COSGRATING, GRAY
            ...
            'backgroundText','WHITENOISE',...
            ...
            'leftWallText', 'WHITENOISE2',...
            'rightWallText', 'WHITENOISE',...
            'floorText', 'WHITENOISE3',...
            'farWallText','GRAY',...
            'ceilingText', 'WHITENOISE4',...
            'nearWallText','GRAY',...
            ...
            'Leg1Text1', 'VCOSGRATING',...
            'Leg1Text2', 'VCOSGRATING',...
            'Leg1Text3', 'VCOSGRATING',...
            'Leg1Text4', 'VCOSGRATING',...
            ...
            'Leg2Text1', 'PLAIDS',...
            'Leg2Text2', 'PLAIDS',...
            'Leg2Text3', 'PLAIDS',...
            'Leg2Text4', 'PLAIDS',...
            ...
            'Leg4Text1', 'PLAIDS',...
            'Leg4Text2', 'PLAIDS',...
            'Leg4Text3', 'PLAIDS',...
            'Leg4Text4', 'PLAIDS',...
            ...
            'Leg3Text1', 'VCOSGRATING',...
            'Leg3Text2', 'VCOSGRATING',...
            'Leg3Text3', 'VCOSGRATING',...
            'Leg3Text4', 'VCOSGRATING',...
            ...
            'end_walls', 0,...                      % Do you want to have extra ends
            ...
            'End1Text1', 'GRAY',...'RED',...
            'End1Text2', 'GRAY',...'RED',...
            'End1Text3', 'GRAY',...'RED',...
            'End1Text4', 'GRAY',...'RED',...
            ...
            'End2Text1', 'GRAY',...'BLUE',...
            'End2Text2', 'GRAY',...'BLUE',...
            'End2Text3', 'GRAY',...'BLUE',...
            'End2Text4', 'GRAY',...'BLUE',...
            ...
            'speckleNoise', 0,...           % Add speckle noise
            'speckleSize', 20,...            % (centre +- speckleSize) will be coloured
            'speckleLevel', 5,...           % fraction of pixels in with speckle noise
            'speckleType', 'RAND'...       % 'GRAY' give gray squares, 'RAND' gives rand grayscale
            ...
            );
        
        exp.User = ...
            struct(...
            'username','aman'...
            );
        
        exp.RigInfo = ...
            struct(...
            'wheelType', 'WHEEL', ... % This can be either 'BALL', 'WHEEL', 'KEYBRD'
            'wheelRadius', 17.78/2, ...   % Mainly for the rotary encoder (WHEEL), which then uses it to get the units right
            'wheelToVR', 1.1, ...
            'soundOn', 0, ...
            'maxNTrials', 120,...
            'maxTrialDuration', 30,...
            'syncSquareSize', 75,...          % size of synchroniztation square read by photodiode
            'syncSquareSizeX', 250 ...          % size of synchroniztation square read by photodiode
            ...
            );
        
    end
end
