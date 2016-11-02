% function f = analyze
% figure('position',[150 150 300 300]);
% 
% zvec =TRIAL.zvec(TRIAL.zvec~=0);
% zvec=-1*zvec;
% ylim([min(zvec)-50  max(zvec)+50]);
% 
% xlim([min(TRIAL.xvec)-50 max(TRIAL.xvec)+50]);
% 
% 
% 
% hold on;
% 
% % for i=1:numel(TRIAL.bases)
% %     plot(TRIAL.bases(i).center(1),-TRIAL.bases(i).center(3),'r*');
% %     
% %     end
% activeBase = 1;
% baseToReward = 1;
% 
% for i=1:15000
%     
%     if(activeBase<= numel(TRIAL.bases) && TRIAL.bases(activeBase).activationTime ~=-1 ...
%         && TRIAL.bases(activeBase).activationTime < TRIAL.time(i))
%         plot(TRIAL.bases(activeBase).center(1),-TRIAL.bases(activeBase).center(3),'r*');
%         plot(TRIAL.xvec(i),-TRIAL.zvec(i),'go');
%         activeBase = activeBase+1;
%         if(baseToReward < activeBase-1)
%             baseToReward = activeBase-1;
%         end
%     end
%     
%     if(TRIAL.bases(baseToReward).rewardTime < TRIAL.time(i))
%        plot(TRIAL.xvec(i),-TRIAL.zvec(i),'k*');
%        baseToReward = baseToReward +1;
%     else
%         plot(TRIAL.xvec(i),-TRIAL.zvec(i));
%     end
%     
%     %pause(0.01)
% end
% end
%  
% 
