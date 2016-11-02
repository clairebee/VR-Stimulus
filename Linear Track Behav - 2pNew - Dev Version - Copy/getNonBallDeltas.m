function getNonBallDeltas
% note:     In the standard position of the device mouse A is on the east side, mouse B on the north side
%
%       According to the MouseBall Tracker application:
%       ax goes positive if the ball turns away from mouse A, and negative if the ball turns towards Mouse A
%       bx goes positive if the ball moves away from mouse B and negative if the ball moves towards mouse B
%
%       ay goes positive for counterclockwise and negative for clockwise rotation
%       by behaves in the same way
%
%       mouse walks north: bx goes positive
%       mouse walks south: bx goes negative
%       mouse walks east:  ax goes positive
%       mouse walks west:  ax goes negative

global MOUSEXY


MOUSEXY.dbx = 0;
MOUSEXY.dax = 0;
MOUSEXY.day = 0;

%% Using the keyboard keys
[keyIsDown, secs, keyCode] = KbCheck; % Psychophysics toolbox

if keyIsDown
    
    if keyCode(38)
        %up
        MOUSEXY.dbx = 100;
    end
    if keyCode(40) %Down
        MOUSEXY.dbx = -100;
    end
    if keyCode(37) % left
        MOUSEXY.dax = -5;
    end
    if keyCode(39) % right
        MOUSEXY.dax = 5;
    end
    if keyCode(49) % 1
        MOUSEXY.day = -100;
        
    end
    if keyCode(50) % 2
        MOUSEXY.day = 100;
    end
    
end
    
%% Using the mouse
%     xdef = 1000;
%     ydef = 1000;
%     
%     [mousex, mousey, buttons] = GetMouse([2]);
%     if mousex ~= xdef
%         MOUSEXY.dbx = (xdef-mousex)*50;
%         %         mousex = x/5000;
%     end
%     if mousey ~= ydef
% %         MOUSEXY.day = (ydef-mousey)*50;
%         %         mousey = y/900;
%     end
%     if mousex ~= xdef | mousey~= ydef
% %         display(['mousex: ' num2str(mousex) 'mousey: ' num2str(mousey)]);
%         SetMouse(xdef,ydef,[2]);
%     end
%     
% % end
end

%