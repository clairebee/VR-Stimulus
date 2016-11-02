
clear all;

fprintf('Initializing digital i/o\t');
valveOpenTime = 0.2;

DIO = digitalio('nidaq', 'Dev1');
addline(DIO, 0, 1, 'out', {'SOL1'});
start(DIO);

putvalue(DIO.Line(1), 1);


inTrial = 1;
ivalve = 1;

solOn = 0;
solOff = 1;

if getvalue(DIO.Line(ivalve)) == solOn
    fprintf('<giveReward> WARNING: Valve not closed before reward!\n');
    putvalue(DIO.Line(ivalve), solOff);
end

for i=1:1000
    
   
    
    
        putvalue(DIO.Line(ivalve), solOn); % open valve
       % playSound('correctResponse');
        
        t1=tic;
        while toc(t1)<valveOpenTime;
        end
        
        putvalue(DIO.Line(ivalve), solOff); % close valve
        

   
end

if getvalue(DIO.Line(ivalve)) == solOn
    fprintf('<giveReward> WARNING: Valve not closed before reward!\n');
    putvalue(DIO.Line(ivalve), solOff);
end

fprintf('done\n');

stop(DIO);
delete(DIO);
