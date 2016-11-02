classdef VRclient < handle
    
    properties
        Com = [];
        Uri = [];
        Name = [];
        serverList
        Connected = false;
        ExpRunning = false;
    end
    properties (Constant)
        DefaultPort = 2014
    end
    
    methods
        function [serverNames, obj] = listServers(obj)
            load('./data/VRserver_list.mat')
            numServers = length(serverList);
            serverNames = [];
            for n = 1:numServers
                serverNames = [serverNames, {serverList(n).Name}];
            end
            obj.serverList = serverList;
        end
        
        function [msgId, data, host] = checkMessages(obj)
            [msgId, data, host] = obj.Com.receive;
        end
        
        function state = status(obj)
            if isempty(obj.Com)
                display('Nothing here!')
                state = 0;
            elseif isempty(obj.Com.WebSocket)
                display('Not connected')
                state = 0;
            elseif obj.Com.WebSocket.isOpen==0
                display('Not connected')
                state = 0;
            elseif obj.Com.WebSocket.isOpen==1
                display(['Connected to ' obj.Name])
                obj.Connected = true;
                obj.Uri = obj.Com.WebSocket.getURI;
                state = 1;
            end
        end
        
        function [obj] = connect(obj, servNum)
            load('./data/VRserver_list.mat')
            numServers = length(serverList);
            serverNames = [];
            for n = 1:numServers
                serverNames = [serverNames, {serverList(n).Name}];
            end
            obj.serverList = serverList;
            obj.Name = serverList(servNum).Name;
            
            if ~isempty(obj.Com)
                if obj.Com.WebSocket.isOpen==1
                    display('Already connected')
                    return
                end
            end
            %Establish connection
            obj.Com = io.WSJCommunicator.client(serverList(servNum).Uri);
            pause(0.05)
            obj.Com.open();
            pause(0.05)
            if obj.Com.WebSocket.isOpen==1
                display(['Connected to ' obj.Name])
                obj.Connected = true;
                obj.Uri = obj.Com.WebSocket.getURI;
            else
                display('There was a problem connecting');
            end
            obj.Com.send('Hello','Hello')
        end
        
        function close(obj)
            obj.send('Bye','Bye')
            obj.Com.close
            obj.Com = [];
            display('Bye!');
        end
        
        function send(obj,a,b)
            obj.Com.send(a,b)
            display(['Sent message ' a]);
        end
        
        function startExperiment(obj, animalName, replay, param)
            obj.send('animalName',animalName)
            pause(1e-2)
            obj.send('replay',replay)
            pause(1e-2)
            obj.send('params',param)
            pause(1e-2)
            obj.send('startExp',animalName)
        end
    end
end

