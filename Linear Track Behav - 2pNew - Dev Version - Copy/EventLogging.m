classdef EventLogging < handle
  %DATALOGGING Abstract class that can log some values and associated times
  %   Detailed explanation goes here
  
  properties
    Clock
  end
  
  properties (Access = protected)
    EventCount = 0;
    ValuesBuffer = [];
    TimesBuffer = [];
  end
  
  methods
    function obj = EventLogging(clock)
      % EventLogging constructor
      % timekeeper: Timekeeper object for generating timestamps, if not specified,
      %   we use a PtbTimekeeper by default, which just uses Psychtoolboxes
      %   GetSecs function for the current time
      if nargin < 1
        clock = PtbClock; % use Psychtoolbox Timekeeper by default
      end
      obj.Clock = clock;
    end
  end

  methods (Access = protected)
    function clearEventData(obj)
      obj.EventCount = 0;
      obj.ValuesBuffer = [];
      obj.TimesBuffer = [];
    end
    function logEvent(obj, value, time)
      if nargin < 3
        time = obj.Clock.now;
      end
      accommodateBuffers(obj);
      obj.EventCount = obj.EventCount + 1;
      obj.ValuesBuffer(obj.EventCount) = value;
      obj.TimesBuffer(obj.EventCount) = time;
    end
    function logEvents(obj, values, times)
      nValues = length(values);
      accommodateBuffers(obj, nValues);
      fromIdx = obj.EventCount + 1;
      toIdx = obj.EventCount + nValues;
      obj.EventCount = obj.EventCount + nValues;
      obj.ValuesBuffer(fromIdx:toIdx) = values;
      obj.TimesBuffer(fromIdx:toIdx) = times;
    end
    function accommodateBuffers(obj, n)
      % n: number of extra spaces needed in buffer
      if nargin < 2
        n = 1; % default extra spaces is 1
      end
      % makes sure the data buffers are large enough to handle more data
      currLen = length(obj.ValuesBuffer);
      lenNeeded = obj.EventCount + n;
      if currLen < lenNeeded
        % at least double the sizes of the arrays
        extra = max(n, currLen);
        obj.ValuesBuffer = [obj.ValuesBuffer ; zeros(extra, 1)];
        obj.TimesBuffer = [obj.TimesBuffer ; zeros(extra, 1)];
        length(obj.ValuesBuffer);
      end
    end
  end
  
end

