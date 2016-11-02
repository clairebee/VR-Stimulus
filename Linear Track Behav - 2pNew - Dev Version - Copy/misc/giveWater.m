clear all;

fprintf('Initializing digital i/o\t');
valveOpenTime = 0.07;

DIO = digitalio('nidaq', 'Dev1');

addline(DIO, 0, 1, 'out', {'SOL1'});
start(DIO);

putvalue(DIO.Line(1), 1);


inTrial = 1;
ivalve = 1;

solOn = 0;
solOff = 1;

beepStart  = 0.5*MakeBeep(3300,0.1);
oBeepStart  = audioplayer(beepStart ,22000);
% beepSTOP  = 0.5*MakeBeep(3300,0.1);
% oBeepSTOP  = audioplayer(beepSTOP ,22000);

if getvalue(DIO.Line(ivalve)) == solOn
    fprintf('<giveReward> WARNING: Valve not closed before reward!\n');
    putvalue(DIO.Line(ivalve), solOff);
end

while (inTrial)
    
    ms = ['\n\nHit <ENTER> to open valve or q to quit' '\n'];
    
    temp = input(ms, 's')
    if (strcmp(temp, 'q'))
        
        inTrial =0;
        continue
    end
    
    
        putvalue(DIO.Line(ivalve), solOn); % open valve
        %playSound('correctResponse');
        play(oBeepStart);
        
        t1=tic;
        while toc(t1)<valveOpenTime;
        end
        
        putvalue(DIO.Line(ivalve), solOff); % close valve
        
%         t1=tic;
%         while toc(t1)<2;
%         end
%        play(oBeepSTOP);

   
end

if getvalue(DIO.Line(ivalve)) == solOn
    fprintf('<giveReward> WARNING: Valve not closed before reward!\n');
    putvalue(DIO.Line(ivalve), solOff);
end

fprintf('done\n');

stop(DIO);
delete(DIO);
