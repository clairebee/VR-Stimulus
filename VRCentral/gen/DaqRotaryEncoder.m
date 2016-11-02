classdef DaqRotaryEncoder < PositionSensor
  %ROTARYENCODER Tracks rotary encoder position from a DAQ
  %   Communicates with rotary encoder via a DAQ. Will configure a DAQ
  % session counter channel for you, log position and times every time you
  % call readPosition, and allows 'zeroing' at the current position. Also takes 
  % care of the DAQ counter overflow when ticking over backwards. 
  %
  % e.g. use:
  % session = daq.createSession('ni')
  % enc = DaqRotaryEncoder
  % enc.DaqSession = session
  % enc.DaqId = 'Dev1'
  % enc.createDaqChannel
  % [x, time] = enc.readPosition
  % enc.zero
  % [x, time] = enc.readPosition
  % X = enc.Positions
  % T = enc.PositionTimes
  %
  % If using a KÜBLER 2400 series encoder and an NI DAQ, calling
  % createDaqChannel, then wiringInfo will give a specific wiring message
  %
  % Note because we use X4 encoding, we record all pulses from both
  % channels for maximum resolution. This means that e.g. a KÜBLER 2400 with 
  % 100 pulses per revolution will actually generate *400* position ticks per
  % full turn.
  
  properties
    DaqSession = []; % the DAQ session (see session-based interface docs)
    DaqId = 'Dev1'; % the DAQ's device ID, e.g. 'Dev1'
    DaqChannelId = 'ctr0'; % the DAQ's ID for the counter channel. e.g. 'ctr0'
  end
  
  properties (Access = protected)
    DaqListener % created when listenForAvailableData is called
    % Allows us to log positions during DAQ background acquision
    DaqInputChannelIdx % index into acquired input data matrices for our channel
  end
  
  properties (Dependent)
    DaqChannelIdx % index into DaqSession's channels for our data
  end
  
  methods
    function value = get.DaqChannelIdx(obj)
      inputs = find(strcmpi('input', hw.daqSessionChannelDirections(obj.DaqSession)));
      value = inputs(obj.DaqInputChannelIdx);
    end
    function obj = set.DaqChannelIdx(obj, value)
      obj.DaqInputChannelIdx = hw.daqSessionDirectionalIdx(obj.DaqSession, value, 'Input');
    end
    function createDaqChannel(obj)
      [ch, idx] = obj.DaqSession.addCounterInputChannel(obj.DaqId, obj.DaqChannelId, 'Position');
      % quadrature encoding where each pulse from the channel updates
      % the counter - ie. maximum resolution (see http://www.ni.com/white-paper/7109/en)
      ch.EncoderType = 'X4';
      obj.DaqChannelIdx = idx;
    end
    function msg = wiringInfo(obj)
      ch = obj.DaqSession.Channels(obj.DaqChannelIdx);
      s1 = sprintf('Terminals: A = %s, B = %s, Z = %s\n', ...
        ch.TerminalA, ch.TerminalB, ch.TerminalZ);
      s2 = sprintf('For KÜBLER 2400 series wiring is:\n');
      s3 = sprintf('GREEN -> %s, GREY -> %s, BLUE -> %s [Optional], BROWN -> +5V, WHITE -> DGND\n',...
        ch.TerminalA, ch.TerminalB, ch.TerminalZ);
      msg = [s1 s2 s3];
    end
    function setZeroResetEnabled(obj, enabled)
      % Enable or disable resetting the position to zero at the encoders
      % zero phase position. To use this you need to plugin the encoders
      % zero line to the DAQ.
      obj.DaqSession.Channels(obj.DaqChannelIdx).ZResetEnable = enabled;
    end
    function listenForAvailableData(obj)
      % adds a listener to the DAQ session that will receive and process
      % data when the DAQ is acquiring data in the background (i.e.
      % startBackground() has been called on the session).
      deleteListeners(obj);
      obj.DaqListener = obj.DaqSession.addlistener('DataAvailable', ...
        @(src, event) daqListener(obj, src, event));
    end
    function delete(obj)
      deleteListeners(obj);
    end
    function deleteListeners(obj)
      if ~isempty(obj.DaqListener)
        delete(obj.DaqListener);
      end;
    end
  end

  methods (Access = protected)
    function [x1, x2, time] = readAbsolutePosition(obj)
      preTime = obj.Clock.now;
      [x1, x2] = obj.DaqSession.inputSingleScan;
      x1 = decode(obj, x1);
      postTime = obj.Clock.now;
      time = (preTime + postTime)/2;
    end
    function x = decode(obj, x)
      % correct for 32-bit overflow when going down from zero
      midBound = 2^16;
      x(x > midBound) = x(x > midBound) - 2^32;
    end
    function daqListener(obj, src, event)
      acqStartTime = obj.Clock.fromMatlab(event.TriggerTime);
%       fprintf('called at %g with %i samples\n', acqStartTime, size(event.Data,1));
      values = decode(obj, event.Data(:,obj.DaqInputChannelIdx)) - obj.ZeroOffset;
      times = acqStartTime + event.TimeStamps(:,obj.DaqInputChannelIdx);
      logEvents(obj, values, times);
    end
  end
end

