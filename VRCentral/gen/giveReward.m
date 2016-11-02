function runInfo = giveReward(count,tag, lastActiveBase, corner, expInfo, runInfo, hwInfo, rigInfo)

% global rewardStartT;

% global STOPrewardStopT;
% global BASErewardStopT;
% global PASSrewardStopT;
% global ACTVrewardStopT;

% global oBeepSTOP;
% global oBeepBASE;
% global REWARD;
% global OFFLINE;
% global EXP
% global rewVal

% playSound('correctResponse');
% 'EXP.BASEvalveTime',1.5,...           % Reward for correct base
%              'EXP.PASSvalveTime',2,...           % Reward for correct base
%              'EXP.ACTVvalveTime',3,...           % Reward for correct base
if ~expInfo.OFFLINE
    if(strcmp(runInfo.rewardStartT.Running, 'off') && strcmp(runInfo.STOPrewardStopT.Running,'off')...
            && strcmp(runInfo.BASErewardStopT.Running,'off'))
        VRmessage = ['Reward given at trial Time: ' num2str(round(count/(60*60))) ' min ' num2str(round(rem(count/60,60))) ' s ' tag];
        disp(VRmessage);
        VRLogMessage(expInfo, VRmessage);
        
        runInfo.REWARD.TRIAL = [runInfo.REWARD.TRIAL lastActiveBase];
        runInfo.REWARD.count = [runInfo.REWARD.count count];
        
              
        switch tag
            case 'STOP'
                if expInfo.EXP.soundOn
                    play(runInfo.oBeepSTOP);
                end
                hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime);
                %                 start(rewardStartT);
                %                 start(runInfo.STOPrewardStopT);
                runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 0];
                runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.BASEvalveTime;
            case 'ACTIVE'
                if expInfo.EXP.soundOn
                    play(runInfo.oBeepBASE);
                end
                hwInfo.rewVal.deliverBackground(expInfo.EXP.ACTVvalveTime);
                %                 start(rewardStartT);
                %                 start(runInfo.STOPrewardStopT);
                runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 2];
                runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.ACTVvalveTime;
            case 'PASSIVE'
                if expInfo.EXP.soundOn
                    play(runInfo.oBeepBASE);
                end
                hwInfo.rewVal.deliverBackground(expInfo.EXP.PASSvalveTime);
                %                 start(rewardStartT);
                %                 start(runInfo.STOPrewardStopT);
                runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 1];
                runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.PASSvalveTime;
            case 'BASE'
                if expInfo.EXP.soundOn
                    play(runInfo.oBeepBASE);
                end
                hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime);
                %                 start(rewardStartT);
                %                 start(runInfo.STOPrewardStopT);
                runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 1];
                runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.BASEvalveTime;
            case 'USER'
                if expInfo.EXP.soundOn
                    play(runInfo.oBeepBASE);
                end
                hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime);
                %                 start(rewardStartT);
                %                 start(runInfo.STOPrewardStopT);
                runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 0];
                runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.BASEvalveTime;
            otherwise
                display('!!!!!!!!!!!No such sound!!!!!!!!!!!!!')
        end
        rigInfo.send('reward', runInfo.REWARD.TotalValveOpenTime);
    end
end

end