classdef Clock < handle
  %Clock An interface for abstracting clock implementation
  %   This class is to help with abstracting code that needs to timestamp
  % events. Subclasses of this implement timestamps using different clocks 
  % (e.g. using MATLAB's 'now', Psychtoolbox's 'GetSecs', or a DAQ
  % timing clock etc). The function 'now' must return the time in *seconds* since 
  % some reference time, as counted by whatever clock the subclass uses. This class 
  % also allows you to "zero" the reference time at some moment. Time is then counted 
  % up from that moment on (and is negative for times before that point). Code 
  % that needs to track time can use this class to remain agnostic about what 
  % timing clock is acutally used.

  properties (Access = protected)
    ReferenceTime = 0;
  end
  
  methods (Abstract)
    % convert from a MATLAB serial date number to the same time but
    % expressed in this clocks units (and relative to any zero time point)
    t = fromMatlab(serialDateNum)
  end
  
  methods (Abstract, Access = protected)
    t = absoluteTime(obj)
  end
  
  methods
    function t = now(obj)
      % t returned is the time now in seconds, either relative to some
      % arbritrary reference or if zero has been called, relative to that
      % moment
      t = absoluteTime(obj) - obj.ReferenceTime;
    end
    function zero(obj)
      obj.ReferenceTime = absoluteTime(obj);
    end
  end
  
end

