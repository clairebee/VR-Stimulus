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

%JUL
MazeRadius = expInfo.EXP.l.*TRIAL.trialRL(runInfo.currTrial)/(2*pi);
RealRoomLength = expInfo.EXP.l.*TRIAL.trialRL(runInfo.currTrial);

if strcmp(expInfo.EXP.trajDir,'cw')
    t_start = expInfo.EXP.delta;
    t_end   = expInfo.EXP.l.*TRIAL.trialRL(runInfo.currTrial);% - expInfo.EXP.delta;
elseif strcmp(expInfo.EXP.trajDir,'ccw')
    t_start = expInfo.EXP.l.*TRIAL.trialRL(runInfo.currTrial);% - expInfo.EXP.delta;
    t_end   = expInfo.EXP.delta;
end

if expInfo.REPLAY
    
    % if replay just get the position parameters and then check for the
    % reward, which is not in the original
    % **** SHOULD CHANGE REWARDING PROCEDURE ***
    %     display(['Curr trial : ' num2str(runInfo.currTrial) ', Time : ' num2str(TRIAL.time(runInfo.currTrial,runInfo.count))]);
    %     (TRIAL.time(runInfo.currTrial,runInfo.count) == 0 && TRIAL.time(runInfo.currTrial+1,2) == 0)
    if strcmp(expInfo.EXP.trajDir,'cw')
        if expInfo.EXP.nbRewSites>1
            dist2Rew = (TRIAL.trialRewPos(:,runInfo.currTrial)+expInfo.EXP.punishLim - runInfo.TRAJ);
            dist2Rew = dist2Rew - RealRoomLength.*(dist2Rew>RealRoomLength/2) + RealRoomLength.*(dist2Rew<-RealRoomLength/2);
            [Dmin,~] = min(dist2Rew(dist2Rew>=0));
            Rew_closest = find(dist2Rew == Dmin);
        else
            Rew_closest = 1;
        end
        if runInfo.reward_active(Rew_closest)>0
            %JUL TESTING PURPOSE
            if (mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol)...
                && TRIAL.lick(runInfo.currTrial,runInfo.count)
                if (TRIAL.trialActive(runInfo.currTrial)) || ((~TRIAL.trialActive(runInfo.currTrial)) && expInfo.EXP.PtoA)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);
                    disp(['active reward delivery at ' num2str(runInfo.TRAJ)])
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 2;
                end
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if runInfo.TRAJ >= TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);
                    disp('passive reward delivery')
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 1;
                end
            end     
        end
    elseif strcmp(expInfo.EXP.trajDir,'ccw') %TRIAL.trialActive(runInfo.currTrial) TRIAL.trialRewPos(runInfo.currTrial)
        if expInfo.EXP.nbRewSites>1
            dist2Rew = -(TRIAL.trialRewPos(:,runInfo.currTrial)-expInfo.EXP.punishLim - runInfo.TRAJ);
            dist2Rew = dist2Rew - RealRoomLength.*(dist2Rew>RealRoomLength/2) + RealRoomLength.*(dist2Rew<-RealRoomLength/2);
            [Dmin,~] = min(dist2Rew(dist2Rew>=0));
            Rew_closest = find(dist2Rew == Dmin);
        else
            Rew_closest = 1;
        end
        if runInfo.reward_active
            %JUL TESTING PURPOSE
            if (mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol)... 
                && TRIAL.lick(runInfo.currTrial,runInfo.count)
                if (TRIAL.trialActive(runInfo.currTrial)) || ((~TRIAL.trialActive(runInfo.currTrial)) && expInfo.EXP.PtoA)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);                    
                    disp(['active reward delivery at ' num2str(runInfo.TRAJ)])
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 2;
                end
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if (runInfo.TRAJ <= (t_end - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)))
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);
                    disp('passive reward delivery')
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 1;
                end
            end
        end
    end
    
    if (TRIAL.time(runInfo.currTrial,runInfo.count+1) ~= 0)
        runInfo.TRAJ = TRIAL.traj(runInfo.currTrial,runInfo.count);
        %JUL
        runInfo.ANGLE = TRIAL.angle(runInfo.currTrial,runInfo.count);
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
        %JUL:changes to allow multiple reward sites
        dist2Rew = (TRIAL.trialRewPos(:,runInfo.currTrial)+expInfo.EXP.punishLim - runInfo.TRAJ);
        if expInfo.EXP.nbRewSites>1            
            dist2Rew = dist2Rew - RealRoomLength.*(dist2Rew>RealRoomLength/2) + RealRoomLength.*(dist2Rew<-RealRoomLength/2);
            [Dmin,~] = min(dist2Rew(dist2Rew>=0));
            Rew_closest = find(dist2Rew == Dmin);
        else
            Rew_closest = 1;
        end
        if TRIAL.lick(runInfo.currTrial,runInfo.count)
            %                 if (mod(abs(TRIAL.trialRewPos(Rew_closest,runInfo.currTrial) - runInfo.TRAJ),RealRoomLength) > expInfo.EXP.punishLim)
            if sum(abs(dist2Rew) > expInfo.EXP.punishLim) == expInfo.EXP.nbRewSites && ...
                    mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) > 1.3*expInfo.EXP.rew_tol
                TRIAL.badlick(Rew_closest) = TRIAL.badlick(Rew_closest) + 1;
            elseif mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol
                TRIAL.goodlick(runInfo.currTrial,Rew_closest) = TRIAL.goodlick(runInfo.currTrial,Rew_closest) + 1;
            end
            if (TRIAL.badlick(Rew_closest) >= expInfo.EXP.maxBadLicks)
                display(['Too many bad licks on trial: ' num2str(runInfo.currTrial)]);
                runInfo.reward_active(Rew_closest) = 0; 
                TRIAL.badlick(Rew_closest) = 0;
                if expInfo.EXP.BadLicksTimeOut
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 0;
                    runInfo.runTimeOut = 1;
                    TRIAL.badlick(Rew_closest) = 0;
                end
            end
        end
        if runInfo.reward_active(Rew_closest)>0
            %JUL: we make optional the time-out when there were too many
            %bad licks            
            %JUL TESTING PURPOSE
            try
            if (mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol)...
                && TRIAL.lick(runInfo.currTrial,runInfo.count)
                if (TRIAL.trialActive(runInfo.currTrial)) || ((~TRIAL.trialActive(runInfo.currTrial)) && expInfo.EXP.PtoA)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);                    
                    disp(['active reward delivery at ' num2str(runInfo.TRAJ)])
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.badlick(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 2;
                end
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if (mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);
                    disp('passive reward delivery')
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.badlick(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 1;
                end
            end   
            catch
                keyboard
            end
        end        
        %JUL TESTING PURPOSE
        if (runInfo.TRAJ >= t_end || toc(runInfo.t1) > expInfo.EXP.maxTrialDuration || runInfo.runTimeOut)
            if runInfo.TRAJ >= t_end
                TRIAL.CompCircle = TRIAL.CompCircle + 1;
            end
            runInfo.currTrial = runInfo.currTrial + 1;
            runInfo.reward_active(:) = 1;
            changeCount = 1;
            if expInfo.EXP.changeLength
                if expInfo.EXP.randScale
                    roomLength = expInfo.EXP.lengthSet(randi(length(expInfo.EXP.lengthSet)));
                else
                    %JUL: changed so that VR changes are done every
                    %nTrialChange # of trials
                    idx = max(1,TRIAL.CompCircle);%runInfo.currTrial;
                    if idx>length(expInfo.EXP.lengthSet)
                        idx = rem(idx, length(expInfo.EXP.lengthSet));
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
            
            if length(expInfo.EXP.scaleSet)>1
                if expInfo.EXP.randScale
                    scaling_factor = expInfo.EXP.scaleSet(randi(length(expInfo.EXP.scaleSet)));
                else
                    idx = max(1,TRIAL.CompCircle);%runInfo.currTrial;
                    if idx>length(expInfo.EXP.scaleSet)
                        idx = rem(idx, length(expInfo.EXP.scaleSet));
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
            
            if expInfo.EXP.randContr
                contrLevel = expInfo.EXP.contrLevels(randi(length(expInfo.EXP.contrLevels)));
            else
                idxc =  max(1,TRIAL.CompCircle);%runInfo.currTrial;
                if idxc>length(expInfo.EXP.contrLevels)
                    idxc = rem(idxc, length(expInfo.EXP.contrLevels));
                    if idxc==0
                        idxc = length(expInfo.EXP.contrLevels);
                    end
                end
                contrLevel = expInfo.EXP.contrLevels(idxc);
            end
            TRIAL.trialContr(runInfo.currTrial) = contrLevel;
            
            disp(mod(TRIAL.CompCircle-1,expInfo.EXP.nTrialChange))
            if mod(max(1,TRIAL.CompCircle-1),expInfo.EXP.nTrialChange)==0 || toc(runInfo.t1) > expInfo.EXP.maxTrialDuration || runInfo.runTimeOut
                runInfo.runTimeOut = 0;
                if expInfo.EXP.bidirec % to go back and forth
                    expInfo.EXP.trajDir = 'ccw';
                end
                
                runInfo.reset_textures = 1; 
                
                runInfo.blank_screen = 1;
                runInfo.TRAJbeforeblank = mod(runInfo.TRAJ,RealRoomLength);
                runInfo.blank_screen_count = 1;
                TRIAL.trialBlanks(runInfo.currTrial) = expInfo.EXP.pause_frames + 120*rand(1);
            else
                runInfo.reset_textures = 0;
                runInfo.blank_screen = 0;
                runInfo.blank_screen_count = 2;
                TRIAL.trialBlanks(runInfo.currTrial) = 1;
%                 TRIAL.trialRL(runInfo.currTrial) = TRIAL.trialRL(runInfo.currTrial-1);
%                 TRIAL.trialContr(runInfo.currTrial) = TRIAL.trialContr(runInfo.currTrial-1);
                runInfo.TRAJ = mod(runInfo.TRAJ,RealRoomLength);
            end
            
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
        %JUL:changes to allow multiple reward sites
        dist2Rew = -(TRIAL.trialRewPos(:,runInfo.currTrial)-expInfo.EXP.punishLim - runInfo.TRAJ);
        if expInfo.EXP.nbRewSites>1            
            dist2Rew = dist2Rew - RealRoomLength.*(dist2Rew>RealRoomLength/2) + RealRoomLength.*(dist2Rew<-RealRoomLength/2);
            [Dmin,~] = min(dist2Rew(dist2Rew>=0));
            Rew_closest = find(dist2Rew == Dmin);
        else
            Rew_closest = 1;
        end
        if TRIAL.lick(runInfo.currTrial,runInfo.count)
            %                 if (mod(abs(TRIAL.trialRewPos(Rew_closest,runInfo.currTrial) - runInfo.TRAJ),RealRoomLength) > expInfo.EXP.punishLim)
            if sum(abs(dist2Rew) > expInfo.EXP.punishLim) == expInfo.EXP.nbRewSites && ...
                    mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) > 1.3*expInfo.EXP.rew_tol
                TRIAL.badlick(Rew_closest) = TRIAL.badlick(Rew_closest) + 1;
            elseif mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol
                TRIAL.goodlick(runInfo.currTrial,Rew_closest) = TRIAL.goodlick(runInfo.currTrial,Rew_closest) + 1;
            end
            if (TRIAL.badlick(Rew_closest) >= expInfo.EXP.maxBadLicks)
                display(['Too many bad licks on trial: ' num2str(runInfo.currTrial)]);
                runInfo.reward_active(Rew_closest) = 0;
                TRIAL.badlick(Rew_closest) = 0;
                if expInfo.EXP.BadLicksTimeOut
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 0;
                    TRIAL.badlick(Rew_closest) = 0;
                    runInfo.runTimeOut = 1;
                end
            end
        end
        if runInfo.reward_active(Rew_closest)>0
            %JUL: we make optional the time-out when there were too many
            %bad licks
            
            %JUL TESTING PURPOSE
            if (mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol)...
                && TRIAL.lick(runInfo.currTrial,runInfo.count)
                if (TRIAL.trialActive(runInfo.currTrial)) || ((~TRIAL.trialActive(runInfo.currTrial)) && expInfo.EXP.PtoA)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'ACTIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);
                    disp(['active reward delivery at ' num2str(runInfo.TRAJ)])
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.badlick(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 2;
                end
            elseif (~TRIAL.trialActive(runInfo.currTrial))
                if (mod(abs(runInfo.TRAJ - TRIAL.trialRewPos(Rew_closest,runInfo.currTrial)),RealRoomLength) < expInfo.EXP.rew_tol)
                    %JUL REMOVE FOR TESTING PURPOSE
                    runInfo = giveReward(runInfo.count,'PASSIVE' ,runInfo.currTrial, 1, expInfo, runInfo, hwInfo, rigInfo);
                    disp('passive reward delivery')
                    runInfo.reward_active(Rew_closest) = 0;
                    TRIAL.badlick(Rew_closest) = 0;
                    TRIAL.trialOutcome(Rew_closest,runInfo.currTrial) = 1;
                end
            end     
        end
        if ((runInfo.TRAJ <= t_end && ~runInfo.blank_screen) || toc(runInfo.t1) > expInfo.EXP.maxTrialDuration || runInfo.runTimeOut)
%             display(['Reached end, traj = ' num2str(runInfo.TRAJ) ', and t_end is: ' num2str(t_end)])
            if runInfo.TRAJ >= t_end
                TRIAL.CompCircle = TRIAL.CompCircle + 1;
            end            
            runInfo.currTrial = runInfo.currTrial + 1;
            runInfo.reward_active(:) = 1;
            changeCount = 1;
            
            if expInfo.EXP.changeLength
                if expInfo.EXP.randScale
                    roomLength = expInfo.EXP.lengthSet(randi(length(expInfo.EXP.lengthSet)));
                else
                    %JUL: changed so that VR changes are done every
                    %nTrialChange # of trials
                    idx = Tmax(1,TRIAL.CompCircle);%runInfo.currTrial;
                    if idx>length(expInfo.EXP.lengthSet)
                        idx = rem(idx, length(expInfo.EXP.lengthSet));
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
            
            if length(expInfo.EXP.scaleSet)>1
                if expInfo.EXP.randScale
                    scaling_factor = expInfo.EXP.scaleSet(randi(length(expInfo.EXP.scaleSet)));
                else
                    idx = max(1,TRIAL.CompCircle);%runInfo.currTrial;
                    if idx>length(expInfo.EXP.scaleSet)
                        idx = rem(idx, length(expInfo.EXP.scaleSet));
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
            
            runInfo.reset_textures = 1;
            if expInfo.EXP.randContr
                contrLevel = expInfo.EXP.contrLevels(randi(length(expInfo.EXP.contrLevels)));
            else
                idxc =  max(1,TRIAL.CompCircle);%runInfo.currTrial;
                if idxc>length(expInfo.EXP.contrLevels)
                    idxc = rem(idxc, length(expInfo.EXP.contrLevels));
                    if idxc==0
                        idxc = length(expInfo.EXP.contrLevels);
                    end
                end
                contrLevel = expInfo.EXP.contrLevels(idxc);
            end
            TRIAL.trialContr(runInfo.currTrial) = contrLevel;
            
            if mod(max(1,TRIAL.CompCircle-1),expInfo.EXP.nTrialChange)==0 || toc(runInfo.t1) > expInfo.EXP.maxTrialDuration || runInfo.runTimeOut                
                
                runInfo.reset_textures = 1;                
                
                if expInfo.EXP.bidirec % to go back and forth
                    expInfo.EXP.trajDir = 'cw';
                end
                runInfo.blank_screen = 1;                
                runInfo.TRAJbeforeblank = mod(runInfo.TRAJ,RealRoomLength);
                runInfo.blank_screen_count = 1;
                TRIAL.trialBlanks(runInfo.currTrial) = expInfo.EXP.pause_frames + 120*rand(1);
            else
                runInfo.reset_textures = 0;
                runInfo.blank_screen = 0;
                runInfo.blank_screen_count = 2;
                TRIAL.trialBlanks(runInfo.currTrial) = 1;
%                 TRIAL.trialRL(runInfo.currTrial) = TRIAL.trialRL(runInfo.currTrial-1);
%                 TRIAL.trialContr(runInfo.currTrial) = TRIAL.trialContr(runInfo.currTrial-1);
                runInfo.TRAJ = mod(runInfo.TRAJ,RealRoomLength);
            end
            
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
    if expInfo.EXP.CircularMaze
        runInfo.TRAJ = runInfo.TRAJbeforeblank;%t_start;%-1;
        TRIAL.badlick(:)=0;
    else
        runInfo.TRAJ = t_start;%-1;
    end
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

%JUL FOR TESTING PURPOSE
if expInfo.EXP.CircularMaze
    runInfo.ANGLE = runInfo.TRAJ*360/(2*pi*MazeRadius);
    TRIAL.posdata(runInfo.currTrial,runInfo.count,T) = (TRIAL.posdata(runInfo.currTrial,runInfo.count,Z)*360/(2*pi*MazeRadius));
    thetapos = TRIAL.posdata(runInfo.currTrial,runInfo.count,T);
    TRIAL.posdata(runInfo.currTrial,runInfo.count,Z) = -sind(thetapos)*MazeRadius;
    TRIAL.posdata(runInfo.currTrial,runInfo.count,X)  = ((1-cosd(thetapos))*MazeRadius);
end

TRIAL.trialIdx(runInfo.currTrial,runInfo.count) = TRIAL.nCompTraj;

if runInfo.count == size(TRIAL.posdata,2)
    warning('data arrays aren''t long enough');
end

if ~expInfo.REPLAY
    switch expInfo.EXP.trajDir
        case 'ccw'
            TRIAL.posdata(runInfo.currTrial,runInfo.count,T) =  TRIAL.posdata(runInfo.currTrial,runInfo.count,T) + 180;
        otherwise
            TRIAL.posdata(runInfo.currTrial,runInfo.count,T) =  TRIAL.posdata(runInfo.currTrial,runInfo.count,T);
    end
end

%JUL: this part was moved further up so we start over at count = 1 to fill
%the posdata array when currTrial has been incremented
% if changeCount
%     runInfo.count = 1;
% end

% display(runInfo.TRAJ)