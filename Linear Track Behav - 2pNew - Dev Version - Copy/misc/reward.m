function  reward(command)
global DIO;
global EXP;
global OFFLINE

solOn = 0;
solOff = 1;


myLine = 1;


if(command == solOn)

    if ~OFFLINE
        if getvalue(DIO.Line(myLine)) == solOn
            fprintf('<giveReward> WARNING: Valve not closed before reward!\n');
            putvalue(DIO.Line(myLine), solOff);
        end
        
        
%         fprintf(' startReward\n'); % debug
        %    playSound('correctResponse');
        putvalue(DIO.Line(myLine), solOn);
%         fprintf('SolOn\n');
    end
end

if (command == solOff)
%     fprintf(' stopReward\n'); % debug
    if ~OFFLINE
        putvalue(DIO.Line(myLine), solOff);
%         fprintf('SolOff\n');
        
        if getvalue(DIO.Line(myLine)) == solOn
            fprintf('<giveReward> WARNING: Valve not closed after reward!\n');
            putvalue(DIO.Line(myLine), solOff);
        end
    end
end
end