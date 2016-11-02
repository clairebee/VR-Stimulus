function [t, n, dw] = calibrate(rewardController, scales, tMin, tMax)
%HW.CALIBRATE Performs measured reward deliveries for calibration
%   TODO. This needs sanitising and incoporating into HW.REWARDCONTROLLER
%
% Part of Rigbox

% 2013-01 CB created

% tMin = 30/1000;
% tMax = 80/1000;
interval = 0.1;
delivPerSample = 400;
nPerT = 3;

settleWait = 2; % seconds

t = meshgrid(linspace(tMin, tMax, 5), zeros(1, nPerT));
n = repmat(delivPerSample, size(t));
dw = zeros(size(t));

approxTime = interval*(n - 1) + n.*t + settleWait*numel(t);
approxTime = sum(approxTime(:));

%deliver some just to get the scales to a new reading
rewardController.deliverMultiple(tMax, interval, 50, true);
pause(settleWait);
prevWeight = scales.readGrams; %now take initial reading
fprintf('Initial scale reading is %.2fg\n', prevWeight);

startTime = GetSecs;
fprintf('Deliveries will take approximately %.0f minute(s)\n', approxTime/60);

for j = 1:size(t,2)
  for i = 1:size(t,1)
    rewardController.deliverMultiple(t(i,j), interval, n(i,j), true);
    % wait just a moment for drops to settle
    pause(settleWait);
    newWeight = scales.readGrams;
    dw(i,j) = newWeight - prevWeight;
    prevWeight = newWeight;
    ml = dw(i,j)/n(i,j);
    fprintf('Delivered %ful per %fms\n', 1000*ml, 1000*t(i,j));
  end
end

endTime = GetSecs;

fprintf('Deliveries took %.2f minute(s)\n', (endTime - startTime)/60);

end

