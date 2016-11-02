function newVRServer

load('./data/VRserver_list.mat')

listenPort = io.WSJCommunicator.DefaultListenPort;
com = io.WSJCommunicator.server(listenPort);
com.EventMode = false;
pause(0.5)
com.open;

try
    name = hostname;
    s.Uri  = ['ws://' name ':' num2str(listenPort)];
    s.Name  = name;
    s.Role = com.Role;
    s.Port = com.DefaultListenPort;
    s.ActiveServer = false; % To say if there is a possibility to run the VR on this machine
    
    numServers = length(serverList);
    matchExisting = false;
    
    for n = 1:numServers
        if strcmp(s.Name,serverList(n).Name)
            matchExisting = true;
        end
    end
    
    if matchExisting
        display('Server already exists, check!')
    else
        display('Adding server')
        com.close
        clear com
        if isempty(serverList)
            serverList = s;
        else
            serverList(numServers+1) = s;
        end
        save('./data/VRserver_list.mat', 'serverList')
    end
catch
    display('Failed')
    com.close
end