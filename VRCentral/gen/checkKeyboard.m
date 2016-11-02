function keyType = checkKeyboard(rigInfo)
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
[msgId, data, host] = rigInfo.comms.checkMessages;
if ~isempty(msgId)
    switch msgId
        case 'Reward'
            keyType = 2;
        case 'Quit'
            keyType = 1;
    end
end