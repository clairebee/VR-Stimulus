function [direction distance performance]=whereIsItGoing(currentPos, baseIndex)

global EXP;
global TRIAL;

performance = [];
xMov=currentPos(1)-TRIAL.bases(baseIndex).stopPosition(1);
zMov=currentPos(3)-TRIAL.bases(baseIndex).stopPosition(3);

distance = sqrt(xMov^2+zMov^2);

moveAngle = findAngle(xMov,zMov);

baseCenterAngle = findAngle((TRIAL.bases(baseIndex).center(1)-TRIAL.bases(baseIndex).stopPosition(1)),...
    (TRIAL.bases(baseIndex).center(3)-TRIAL.bases(baseIndex).stopPosition(3)));

mirrorBaseAngle = findAngle((TRIAL.bases(baseIndex).mirrorCenter(1)-TRIAL.bases(baseIndex).stopPosition(1)),...
    (TRIAL.bases(baseIndex).mirrorCenter(3)-TRIAL.bases(baseIndex).stopPosition(3)));

direction = 'NO CHOICE';
correctTolerance =EXP.correctTolerance;

switch EXP.rewardScheme
    case 'BIN'
        if(abs(moveAngle-baseCenterAngle)>EXP.directionTolerance) %EXP.minOffsetAngle)
            direction = 'TIME OUT';
            
        elseif abs(moveAngle-baseCenterAngle)<= correctTolerance
            direction = 'CORRECT';
        elseif abs(moveAngle-baseCenterAngle)> correctTolerance
            direction = 'WRONG';
        end
    case 'PROB'
        
        I = max(exp(EXP.difficulty*cos((pi/180*(-179:1:180)))));
%         I2 = max(exp(cos(pi+((pi/180)*(-179:1:180)))));
        performance = (1/I)*exp(EXP.difficulty*cos(((pi/180)*(moveAngle-baseCenterAngle))));%))));%
        perf2 = (cos(((pi/180)*(moveAngle-baseCenterAngle))));%))));%))));%
        if performance>rand(1)
            direction = 'CORRECT';
        elseif perf2<(-1)*rand(1)
            direction = 'TIME OUT';
        else
            direction = 'WRONG';
        end
end

end

function angle = findAngle (xMov,zMov)

angle = atan(abs(xMov/zMov))/pi*180;

if (xMov<0 && zMov<=0)
    angle = -angle;
elseif (xMov>=0 && zMov<0)
    angle = angle;
elseif (xMov >0 && zMov>=0)
    angle = 180 - angle;
elseif (xMov<=0 && zMov>0)
    angle = -1*(180 - angle);
end

end

