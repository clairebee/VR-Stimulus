


fprintf('Initializing digital i/o\t');

DIO = digitalio('nidaq', 'Dev1');
addline(DIO, 0, 1, 'out', {'SOL1'});
start(DIO);
putvalue(DIO.Line(1), 1);



% open = '';
% while ~(strcmp(open, 'o'))
%     open = input('\npress ''o'' to open valves ', 's');
% end

ivalve = 1;
    ms = ['\n\nHit <ENTER> to open valve \n'];
    temp = input(ms, 's');
    putvalue(DIO.Line(ivalve), 0); % open valve
    
    ms = ['Hit <ENTER> to close valve #' num2str(ivalve) '\n'];
    temp = input(ms, 's');
    putvalue(DIO.Line(ivalve), 1); % close valve

fprintf('done\n');

stop(DIO);
delete(DIO);
