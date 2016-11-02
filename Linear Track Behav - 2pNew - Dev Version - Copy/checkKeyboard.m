function keyType = checkKeyboard
% keyType -   1 abort
%             2 give water
keyType = 0;
[keyIsDown, secs, keyCode] = KbCheck; % Psychophysics toolbox
if keyIsDown
    if keyCode(32) % space
        keyType = 2;
    elseif keyCode(27) || keyCode(81) % q/Q QUIT or Esc
        keyType = 1;
    end
end