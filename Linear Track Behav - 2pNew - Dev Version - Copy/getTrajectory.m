function runInfo = getTrajectory(dbx, X, Y, Z, T, rigInfo, hwInfo, expInfo, runInfo)

global TRIAL
% global TRAJ
% global rewStatus
% global currTrial
% global blank_screen
% global blank_screen_count
% global t1
% global count
% global reset_textures
% global reward_active
% global runTimeOut
% global session

k = expInfo.EXP;
corner = 0;
changeCount = 0;

if strcmp(expInfo.EXP.trajDir,'cw')
    t_start = expInfo.EXP.delta;
    t_end   = expInfo.EXP.l.*TRIAL.trialRL(runInfo.currTrial) - 2*expInfo.EXP.delta;
elseif strcmp(expInfo.EXP.trajDir,'ccw')
    t_start = expInfo.EXP.l.*TRIAL.trialRL(runInfo.currTrial) - 2*expInfo.EXP.delta;
    t_end   = expInfo.EXP.delta;
end

if expInfo.REPLAY
    
    % if replay just get the position parameters and then check for the
    % reward, which is not in the original
    % **** SHOULD CHANGE REWARDING PROCEDURE ***
    %     display(['Curr trial : ' num2str(runInfo.currTrial) ', Time : ' num2str(TRIAL.time(runInfo.currTrial,runInfo.count))]);
    %     (TRIAL.time(runInfo.currTrial,runInfo.count) == 0 && TRIAL.time(runInfo.currTrial+1,2) == 0)
    if strcmp(expInfo.EXP.trajDir,'cw')
        if runInfo.reward_active
            
            if (abs(runInfo.TRAJ - TRIAL.trialRewPos(runInfo.currTrial)) < expInfo.EXP.rew_tol && TRIAL.lick(runInfo.currTrial,runInfo.count))
                if (TRIAL.trialActive(runInfo.currTrial)) || ((~TRIAL.trialActive(runInfo.currTrial)) && expInfo.EXP.PtoA)
                    runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                    runInfo.reward_active = 0;
                    TRIAL.trialOutcome(runInfo.currTrial) = 2;
                end
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if runInfo.TRAJ >= TRIAL.trialRewPos(runInfo.currTrial)
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                    runInfo.reward_active = 0;
                    TRIAL.trialOutcome(runInfo.currTrial) = 1;
                end
            end
        end
    elseif strcmp(expInfo.EXP.trajDir,'ccw') %TRIAL.trialActive(runInfo.currTrial) TRIAL.trialRewPos(runInfo.currTrial)
        if runInfo.reward_active
            
            if (abs(runInfo.TRAJ - TRIAL.trialRewPos(runInfo.currTrial)) < expInfo.EXP.rew_tol && TRIAL.lick(runInfo.currTrial,runInfo.count))
                runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                runInfo.reward_active = 0;
                TRIAL.trialOutcome(runInfo.currTrial) = 2;
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if (runInfo.TRAJ <= (t_end - TRIAL.trialRewPos(runInfo.currTrial)))
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                    runInfo.reward_active = 0;
                    TRIAL.trialOutcome(runInfo.currTrial) = 1;
                end
            end
        end
    end
    
    if (TRIAL.time(runInfo.currTrial,runInfo.count+1) ~= 0)
        runInfo.TRAJ = TRIAL.traj(runInfo.currTrial,runInfo.count);
    else
        display(['Reached traj end on trial: ' num2str(runInfo.currTrial)]);
%         runInfo.rewStatus = zeros(size(expInfo.EXP.rewCorners));
%         if (TRIAL.traj(runInfo.currTrial,runInfo.count-1)-t_start) > (0.9*(t_end-t_start)) % if greater than
%             runInfo = giveReward(runInfo.count,'BASE' ,runInfo.currTrial, 1);
%         end
        runInfo.currTrial = runInfo.currTrial + 1;
        changeCount = 1;
        runInfo.reset_textures = 1;
        runInfo.reward_active = 1;
        
        runInfo.blank_screen = 1;
        runInfo.blank_screen_count = 1;
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
        
        if ~expInfo.OFFLINE
            VRmessage = ['StimEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' ...
                expInfo.sessionName ' ' num2str(runInfo.currTrial) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
            rigInfo.sendUDPmessage(VRmessage); %%%Check this
            VRLogMessage(expInfo, VRmessage);
            %             pnet(EYEPort, 'write',['StimEnd ' animalName ' ' dateStr ' ' sessionName ' ' num2str(runInfo.currTrial) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))]); %%%Check this
            %             pnet(EYEPort, 'writePacket');
            if rigInfo.sendTTL
                hwInfo.session.outputSingleScan(false);
            end
        end
        runInfo.t1 = tic;
    end
    
else
    switch expInfo.EXP.trajDir
        case 'cw'
            runInfo.TRAJ = runInfo.TRAJ + dbx;
        case 'ccw'
            runInfo.TRAJ = runInfo.TRAJ - dbx;
        otherwise
            runInfo.TRAJ = runInfo.TRAJ + dbx;
    end
    
    
    if strcmp(expInfo.EXP.trajDir,'cw')
        if runInfo.reward_active
            if TRIAL.lick(runInfo.currTrial,runInfo.count)
                if (sum(sum(TRIAL.lick(runInfo.currTrial,:) & TRIAL.traj(runInfo.currTrial,:))) >= expInfo.EXP.maxBadLicks) && (runInfo.TRAJ <= expInfo.EXP.punishZone)
                    % Run the time-out sequence
                    display(['Too many bad licks on trial: ' num2str(runInfo.currTrial)]);
                    TRIAL.trialOutcome(runInfo.currTrial) = -1;
                    runInfo.runTimeOut = 1;
                end
            end
            if (abs(runInfo.TRAJ - TRIAL.trialRewPos(runInfo.currTrial)) < expInfo.EXP.rew_tol && TRIAL.lick(runInfo.currTrial,runInfo.count))
                if (TRIAL.trialActive(runInfo.currTrial)) || ((~TRIAL.trialActive(runInfo.currTrial)) && expInfo.EXP.PtoA)
                    runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                    runInfo.reward_active = 0;
                    TRIAL.trialOutcome(runInfo.currTrial) = 2;
                end
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if runInfo.TRAJ >= TRIAL.trialRewPos(runInfo.currTrial)
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                    runInfo.reward_active = 0;
                    TRIAL.trialOutcome(runInfo.currTrial) = 1;
                end
            end     
        end
        if (runInfo.TRAJ >= t_end || toc(runInfo.t1) > expInfo.EXP.maxTrialDuration || runInfo.runTimeOut)
            if runInfo.reward_active
                TRIAL.trialOutcome(runInfo.currTrial) = 0;
            end
            
            runInfo.runTimeOut = 0;
            runInfo.currTrial = runInfo.currTrial + 1;
            runInfo.reward_active = 1;
            changeCount = 1;
            runInfo.reset_textures = 1;
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
            if expInfo.EXP.bidirec % to go back and forth
                expInfo.EXP.trajDir = 'ccw';
            end
            runInfo.blank_screen = 1;
            runInfo.blank_screen_count = 1;
            %JUL: changed on 02.02.2016 - we removed the variability of the
            %blank period between trials
            TRIAL.trialBlanks(runInfo.currTrial) = expInfo.EXP.pause_frames;%+ 120*rand(1);
            
            if ~expInfo.OFFLINE
                VRmessage = ['StimEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' ...
                    expInfo.sessionName ' ' num2str(runInfo.currTrial) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
                rigInfo.sendUDPmessage(VRmessage); %%%Check this
                VRLogMessage(expInfo, VRmessage);
                if rigInfo.sendTTL
                    hwInfo.session.outputSingleScan(false);
                end
            end
            runInfo.t1 = tic;
            
            TRIAL.nCompTraj = TRIAL.nCompTraj + 1;
            runInfo.rewStatus = zeros(size(expInfo.EXP.rewCorners));
            
        elseif runInfo.TRAJ <= t_start
            runInfo.TRAJ = t_start;
        end
    elseif strcmp(expInfo.EXP.trajDir,'ccw') %TRIAL.trialActive(runInfo.currTrial) TRIAL.trialRewPos(runInfo.currTrial)
%         if (runInfo.TRAJ <= (t_end - TRIAL.trialRewPos(runInfo.currTrial)) && ~TRIAL.trialActive(runInfo.currTrial) && runInfo.reward_active)
%                 runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1);
%                 runInfo.reward_active = 0;
%         end
        if runInfo.reward_active
           if TRIAL.lick(runInfo.currTrial,runInfo.count)
                if (sum(sum(TRIAL.lick(runInfo.currTrial,:))) >= expInfo.EXP.maxBadLicks) && (runInfo.TRAJ <= expInfo.EXP.punishZone)
                    % Run the time-out sequence
                    display(['Too many bad licks on trial: ' num2str(runInfo.currTrial)]);
                    TRIAL.trialOutcome(runInfo.currTrial) = -1;
                    runInfo.runTimeOut = 1;
                end
           end
           if (abs(runInfo.TRAJ - TRIAL.trialRewPos(runInfo.currTrial)) < expInfo.EXP.rew_tol && TRIAL.lick(runInfo.currTrial,runInfo.count))
                runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                runInfo.reward_active = 0;
                TRIAL.trialOutcome(runInfo.currTrial) = 2;
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if (runInfo.TRAJ <= (t_end - TRIAL.trialRewPos(runInfo.currTrial)))
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo);
                    runInfo.reward_active = 0;
                    TRIAL.trialOutcome(runInfo.currTrial) = 1;
                end
            end
        end
        if ((runInfo.TRAJ <= t_end && ~runInfo.blank_screen) || toc(runInfo.t1) > expInfo.EXP.maxTrialDuration)
%             display(['Reached end, traj = ' num2str(runInfo.TRAJ) ', and t_end is: ' num2str(t_end)])
            if runInfo.reward_active
                TRIAL.trialOutcome(runInfo.currTrial) = 0;
            end
            
            runInfo.currTrial = runInfo.currTrial + 1;
            runInfo.reward_active = 1;
            changeCount = 1;
            runInfo.reset_textures = 1;
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
            if expInfo.EXP.bidirec % to go back and forth
                expInfo.EXP.trajDir = 'cw';
            end
            runInfo.blank_screen = 1;
            runInfo.blank_screen_count = 1;
            %JUL: changed on 02.02.2016 - we removed the variability of the
            %blank period between trials
            TRIAL.trialBlanks(runInfo.currTrial) = expInfo.EXP.pause_frames;% + 120*rand(1);
            
            if ~expInfo.OFFLINE
                VRmessage = ['StimEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' ...
                    expInfo.sessionName ' ' num2str(runInfo.currTrial) ' 1 ' num2str(round(expInfo.EXP.maxTrialDuration*10))];
                rigInfo.sendUDPmessage(VRmessage); %%%Check this
                VRLogMessage(expInfo, VRmessage);
                if rigInfo.sendTTL
                    hwInfo.session.outputSingleScan(false);
                end
            end
            runInfo.t1 = tic;
            
            TRIAL.nCompTraj = TRIAL.nCompTraj + 1;
            runInfo.rewStatus = zeros(size(expInfo.EXP.rewCorners));
            
        elseif runInfo.TRAJ > t_start
            runInfo.TRAJ = t_start;
        end
    end
end

if runInfo.blank_screen
    runInfo.TRAJ = -1;
end

if changeCount
    runInfo.count = 1;
end

corner = 0;
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

%JF 07.07.2015
%this part was moved  up so we start over at count = 1 to fill
%the posdata array when currTrial has been incremented
% if changeCount
%     runInfo.count = 1;
% end

% display(runInfo.TRAJ)