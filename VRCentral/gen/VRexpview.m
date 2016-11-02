classdef VRexpview < handle
    
    properties
        client;
        isActive = 0;
        isMessageAvailable = 0;
        currentMessage = [];
        data = [];
        
        animalName;
        sessionNum;
        expNum;
        
        currentTrial = 0;
        trialTime = tic;
        trialParam = [];
        
        totalReward = 0;
        rewardTime = tic;
        
        figRef;
    end
    
    methods
        function createUI(v,f) %,figRef)
%             f = figure;
            v.isActive = 1;
            figRef.mainPanel = uiextras.Panel('Parent',f);
            figRef.main = uiextras.VBox('Parent',figRef.mainPanel,'Spacing',10,'Padding',5);
            
            % 1. active bar
            figRef.activeBar = uicontrol('Style','text',...
                'String', 'ACTIVE',...
                'fontsize', 14, 'BackgroundColor', [.5 1 .5],...
                'HorizontalAlignment','right',...
                'Parent',figRef.main);
            
            % 2. Animal bar
            figRef.animalBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.animalTxt = uicontrol('Style','text',...
                'String', 'Animal: ',...
                'HorizontalAlignment','left',...
                'Parent',figRef.animalBar);
            figRef.animalName = uicontrol('Style','text',...
                'String', v.animalName,...
                'HorizontalAlignment','left',...
                'Parent',figRef.animalBar);
%             uiextras.Empty('Parent',figRef.animalBar);
            figRef.animalBar.Sizes = [-1 -2];
            
            % 3.Session bar
            figRef.sessionBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.sessionTxt = uicontrol('Style','text',...
                'String', 'Session: ',...
                'HorizontalAlignment','left',...
                'Parent',figRef.sessionBar);
            figRef.sessionName = uicontrol('Style','text',...
                'String', v.sessionNum,...
                'HorizontalAlignment','left',...
                'Parent',figRef.sessionBar);
%             uiextras.Empty('Parent',figRef.sessionBar);
            figRef.expBar.Sizes = [-1 -2];
            
            % 4.Exp bar
            figRef.expBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.expTxt = uicontrol('Style','text',...
                'String', 'Exp: ',...
                'HorizontalAlignment','left',...
                'Parent',figRef.expBar);
            figRef.expName = uicontrol('Style','text',...
                'String', v.expNum,...
                'HorizontalAlignment','left',...
                'Parent',figRef.expBar);
%             uiextras.Empty('Parent',figRef.expBar);
            figRef.expBar.Sizes = [-1 -2];
            
            % 5.Current trial bar
            figRef.currTrialBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.currTrialTxt = uicontrol('Style','text',...
                'String', 'Current trial: ',...
                'HorizontalAlignment','left',...
                'Parent',figRef.currTrialBar);
            figRef.currTrialNum = uicontrol('Style','text',...
                'String', v.currentTrial,...
                'Background', 'white',...
                'HorizontalAlignment','left',...
                'Parent',figRef.currTrialBar);
%             uiextras.Empty('Parent',figRef.currTrialBar);
            figRef.currTrialBar.Sizes = [-1 -2];
            
            % 6.Trial param bar
            figRef.trialParamBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.trialParamTxt = uicontrol('Style','text',...
                'String', 'Trial parameters: ',...
                'HorizontalAlignment','left',...
                'Parent',figRef.trialParamBar);
            figRef.trialParamData = uicontrol('Style','text',...
                'String', v.trialParam,...
                'HorizontalAlignment','left',...
                'Parent',figRef.trialParamBar);
%             uiextras.Empty('Parent',figRef.trialParamBar);
            figRef.trialParamBar.Sizes = [-1 -2];
            
            % 7.Reward bar
            figRef.rewBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.rewTxt = uicontrol('Style','text',...
                'String', 'Reward so far: ',...
                'HorizontalAlignment','left',...
                'Parent',figRef.rewBar);
            figRef.rewName = uicontrol('Style','text',...
                'String', v.totalReward,...
                'HorizontalAlignment','left',...
                'Parent',figRef.rewBar);
%             uiextras.Empty('Parent',figRef.rewBar);
            figRef.rewBar.Sizes = [-1 -2];
            
            % 8.Button bar
            figRef.buttonBar = uiextras.HBox('Parent',figRef.main,'Spacing',10,'Padding',5);
            figRef.topUpRew = uicontrol('Style','pushbutton',...
                'String', 'Top up reward',...
                ...'HorizontalAlignment','center',...
                'Parent',figRef.buttonBar, 'Enable','on', 'Callback', @(~,~) giveWater(v));
            figRef.quitExp = uicontrol('Style','pushbutton',...
                'String', 'Quit',...
                ...'HorizontalAlignment','center',...
                'Parent',figRef.buttonBar, 'Enable','on', 'Callback', @(~,~) quitExp(v));
            figRef.buttonBar.Sizes = [-1 -1];
           
            figRef.main.Sizes = [-1 -3 -3 -3 -3 -3 -3 -6];
            
            v.figRef = figRef;
        end
        
        function readMsg(v)
            [msgId, data] = v.client.checkMessages;
            if ~isempty(msgId)
                v.isMessageAvailable = 1;
                v.currentMessage = msgId;
                v.data = data;
            end
        end
        
        function giveWater(v)
            v.client.send('Reward', 'TopUp');
        end
        
        function quitExp(v)
            v.client.send('Quit', 'Bye');
            v.client.close;
            v.isActive = 0;
            set(v.figRef.activeBar, 'BackgroundColor',[1 .5 .5], 'String','Done');
            set(v.figRef.quitExp, 'Enable','off');
            set(v.figRef.topUpRew, 'Enable','off');
        end
        
        function update(v)
%             if toc(v.trialTime) > 1
%                 set(v.figRef.currTrialNum ,'BackgroundColor','white')
%             end
%             if toc(v.rewardTime) > 1
%                 set(v.figRef.rewName ,'BackgroundColor','white')
%             end
            if v.isMessageAvailable
                switch v.currentMessage
                    case 'animalName'
                        v.animalName = v.data;
                        set(v.figRef.animalName ,'String', v.data);
                    case 'sessionNum'
                        v.sessionNum = v.data;
                        set(v.figRef.sessionName ,'String', v.data);
                    case 'expNum'
                        v.expNum = v.data;
                        set(v.figRef.expName ,'String', v.data);
                    case 'currentTrial'
                        v.currentTrial = v.data;
                        v.trialTime = tic;
                        set(v.figRef.currTrialNum,...
                            'String', v.data, 'BackgroundColor','Green')
                    case 'trialParam'
                        v.trialParam = v.data;
                        set(v.figRef.trialParamData ,'String', v.data);
                    case 'reward'
                        v.totalReward = v.data;
                        v.rewardTime = tic;
                        set(v.figRef.rewName,...
                            'String', v.totalReward, 'BackgroundColor','Green')
                    case 'Bye'
                        v.client.close;
                        v.isActive = 0;
                        set(v.figRef.activeBar, 'BackgroundColor',[1 .5 .5], 'String','Done');
                end
            end
        end
    end
end