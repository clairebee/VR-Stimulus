classdef TimelineClock < hw.Clock
  %TimelineClock A Clock that uses Timeline time
  %   This clock returns time as counted by relative to Timeline's clock.
  %   See also hw.Clock.
  %
  % Part of Rigbox
  
  % 2013-01 CB created
  
  methods (Access = protected)
    function t = absoluteTime(obj)
      global Timeline
      assert(Timeline.isRunning, 'Timeline is not running.');
      t = GetSecs - Timeline.currSysTimeTimelineOffset;
    end
  end
  
end