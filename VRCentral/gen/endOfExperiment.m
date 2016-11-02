function [fhandle, runInfo] = endOfExperiment(rigInfo, hwInfo, expInfo, runInfo)

global GL;

% cleans up and exits state system

fprintf('<stateSystem> endOfExperiment\n'); % debug
Priority(0);

if ~expInfo.OFFLINE
    VRmessage = ['VR_ExpEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo.sendUDPmessage(VRmessage);
    VRLogMessage(expInfo, VRmessage);
    pause(1)
    VRmessage = ['ExpEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo.sendUDPmessage(VRmessage);
    VRLogMessage(expInfo, VRmessage);
    
    VRLogMessage(expInfo);
    VRLogMessage(expInfo);
    
    rigInfo.closeUDPports;
end

pause(2)

Screen('CloseAll');

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end

fhandle = []; % exit state system
clear mex;

end
