classdef PtbClock < Clock
  %PTBCLOCK A Clock that uses Psychtoolbox GetSecs
  %   This clock returns time as counted by Psychtoolbox's GetSecs 
  % function. See Clock superclass for general description.
  
  methods
    function t = fromMatlab(obj, serialDateNum)
      mnow = now;
      ptbnow = GetSecs;
      t = ptbnow + (serialDateNum - mnow)*24*60*60 - obj.ReferenceTime;
    end
  end
  
  methods (Access = protected)
    function t = absoluteTime(obj)
      t = GetSecs;
    end
  end
  
end