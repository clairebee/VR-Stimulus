function [ballTime, dax, dbx, day, dby] = getBallDeltas(myPort)
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

messageSize = 50;
dax = nan; dbx = nan; day = nan; dby = nan; ballTime = nan;
 len = pnet(myPort,'readpacket', messageSize, 'noblock');
if len > 0
   myString = pnet(myPort, 'read', messageSize, char);
   allVars = str2num(myString);
   ballTime = allVars(1);
   dax = allVars(2); dbx = allVars(4); day = allVars(3); dby = allVars(5);
   %dax = -allVars(2); dbx = -allVars(4); day = -allVars(3); dby = -allVars(5);
end



