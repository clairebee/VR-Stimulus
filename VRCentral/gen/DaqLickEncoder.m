classdef DaqLickEncoder 
  %LICK ENCODER Tracks the number of licks from a DAQ
  %   Communicates with lick detector via a DAQ. Will configure a DAQ
  % session counter channel for you, log position and times every time you
  % call readPosition, and allows 'zeroing' at the current position. Also takes 
  % care of the DAQ counter overflow when ticking over backwards. 
  %
  % e.g. use:
  % session = daq.createSession('ni')
  % enc = DaqLickEncoder
  % enc.DaqSession = session
  % enc.DaqId = 'Dev2'
  % enc.createDaqChannel
  % [x, time] = enc.readCounter
  % enc.zero
  % [x, time] = enc.readCounter
  % X = Counter value
  % T = query time for the counter
  %
  % 
  
  properties
    DaqSession = []; % the DAQ session (see session-based interface docs)
    DaqId = 'Dev1'; % the DAQ's device ID, e.g. 'Dev1'
    DaqChannelId = 'ctr1'; % the DAQ's ID for the counter channel. e.g. 'ctr0'
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
      [ch, idx] = obj.DaqSession.addCounterInputChannel(obj.DaqId, obj.DaqChannelId, 'EdgeCount');
      obj.DaqChannelIdx = idx;
    end
    function msg = wiringInfo(obj)
      ch = obj.DaqSession.Channels;
      s1 = sprintf('Terminal  = %s', ...
        ch.Terminal);
%       s2 = sprintf('For KÜBLER 2400 series wiring is:\n');
%       s3 = sprintf('GREEN -> %s, GREY -> %s, BLUE -> %s [Optional], BROWN -> +5V, WHITE -> DGND\n',...
%         ch.TerminalA, ch.TerminalB, ch.TerminalZ);
      msg = [s1];
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

  methods
    function [x] = readCounter(obj)
      x = obj.DaqSession.inputSingleScan;
      x = x(2);
    end
    function zero(obj)
      obj.DaqSession.resetCounters
    end
  end
end

