classdef PositionSensor < EventLogging
  %POSITIONSENSOR Abstract class for tracking positions from a sensor
  %   Takes care of logging positions and times every time readPosition is
  % called. Has a zeroing function.
  
  properties (Dependent = true)
    Positions
    PositionTimes
  end
  
  properties (Access = protected)
    ZeroOffset = 0;
  end

  methods (Abstract, Access = protected)
    [x, time] = readAbsolutePosition(obj)
  end
  
  methods
    function clearPositionData(obj)
      clearEventData(obj);
    end    
    function value = get.Positions(obj)
      value = obj.ValuesBuffer(1:obj.EventCount);
    end
    function value = get.PositionTimes(obj)
      value = obj.TimesBuffer(1:obj.EventCount);
    end    
    function zero(obj, log)
      % zeros the position counter relative to sensor current position, and if 
      % (optional) log is true, will log that zero in Positions and PositionTimes
      if nargin < 2
        log = false; % by default don't log zero at this time
      end
      [x1, ~, time] = readAbsolutePosition(obj);
      obj.ZeroOffset = x1;
%       if log
%         logEvent(obj, 0, time);
%       end
    end    
    function [x1, x2, time] = readPosition(obj)
      % reads, logs and returns the current position. Also records
      % the time the reading was made (according to the timekeeper)
      [x1, x2, time] = readAbsolutePosition(obj);
      x1 = x1 - obj.ZeroOffset;
%       logEvent(obj, x1, time);
    end
  end
  
end

