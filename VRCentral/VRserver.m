function VRserver
% function to start the experiment server and wait for the commands to
% start experiment.
% Can start experiment by connecting to this server and sending a parameter
% file with ServerExpStart
% Active Keys:
% q/Esc - quit, hit twice if running experiment
% spacebar -  Check connection status, give reward while running experiment
%
% Based on Websockets from Chris Burgess
%
% Aman Saleem
% 2016q

listenPort = io.WSJCommunicator.DefaultListenPort;

com = io.WSJCommunicator.server(listenPort);
com.EventMode = false;
pause(0.5)
com.open;

try
    running = true;
    
    fprintf('Hello, \nI am now open for business!')
    % InitializeMatlabOpenGL;
    fprintf('\n<q> quit, \n<space> check connection\n');
    
    while running
        keyType = checkKeyboard_server;
        if keyType==1
            closeServer;
            continue;
        elseif keyType==2
            checkConnection;
            pause(0.05);
        end
        
        if com.IsMessageAvailable
            [msgId, data, host] = com.receive;
            switch msgId
                case 'animalName'
                    animal_name = data;
                    display(['Animal name: ' animal_name]);
                case 'replay'
                    replay_in = data;
                case 'params'
                    EXP = data;
                    display(['Received parameter file']);
                case 'startExp'
                    display(['Starting the experiment for ' animal_name]);
%                     MouseBallExp(replay_in, EXP, animal_name, com);
                case 'endExp'
                    display('Not running experiment, nothing to quit')
                case 'Hello'
                    display('Hello!')
                case 'Bye'
                    display('Bye!')
                otherwise
                    display(['Recieved message from ' host ', says: ' msgId])
            end
        end
        pause(0.01)
    end
catch ME
    fprintf(['exception : ' ME.message '\n']);
    fprintf(['line #: ' num2str(ME.stack(1,1).line)]);
    
    display('There was an error, closing server')
    closeServer
end

    function closeServer
        com.send('ServerClosed', 'Bye, bye!');
        com.close;
        clear com;
        display('Goodbye!');
        running = false;
    end
    function checkConnection
        connections = com.WebSocket.connections;
        numCon = connections.size;
        if numCon==0
            display('No connection yet')
        else
            display(['Number of connections= ' num2str(numCon)])
            if numCon>1
                display('Check why there are more than two connections!')
            end
        end
    end
end