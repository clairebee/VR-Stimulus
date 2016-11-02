classdef RewardController < hw.DataLogging
  %HW.REWARDCONTROLLER Abstract interface for controlling reward devices
  %   Detailed explanation goes here
  %
  % Part of Rigbox

  % 2012-10 CB created
  
  properties (Dependent = true)
    DeliveredSizes
    DeliveryTimes
  end
  
  methods (Abstract)
    %deliverBackground(size) call deliver to deliver a reward of the
    %specified size and return before completion of delivery.
    deliverBackground(obj, size)
    deliverMultiple(obj, size, interval, n) %for calibration
  end
  
  methods
    function value = get.DeliveredSizes(obj)
      value = obj.DataBuffer(1:obj.SampleCount);
    end
    function value = get.DeliveryTimes(obj)
      value = obj.TimesBuffer(1:obj.SampleCount);
    end
  end
  
end

