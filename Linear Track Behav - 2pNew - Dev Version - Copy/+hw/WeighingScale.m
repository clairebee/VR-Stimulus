classdef WeighingScale < handle
  %HW.WEIGHINGSCALE Interface to a weighing scale connected via serial
  %   Allows you to read the current weight from scales and tare it.
  %
  % Part of Rigbox

  % 2013-02 CB created  
  
  properties
    ComPort = 'COM1'
    TareCommand = hex2dec('54')
  end
  
  properties (Access = protected)
    LastGrams = [];
    Port = [];
  end
  
  methods
    function tare(obj)
      fprintf(obj.Port, obj.TareCommand);
      obj.LastGrams = 0;
    end
    
    function g = readGrams(obj)
      nr = obj.Port.BytesAvailable/13;
      
      for i = 1:nr
        c = fscanf(obj.Port);
        d = sscanf(c,'%s %f %*s');
        g = d(2);
        if d(1) == 45
          g = -g;
        end
        obj.LastGrams = g;
      end
      g = obj.LastGrams;
    end
    
    function init(obj)
      if isempty(obj.Port)
        obj.Port = serial(obj.ComPort);
        fopen(obj.Port);
        fprintf('Opened scales on "%s"\n', obj.ComPort);
%         tare(obj);
      end
    end
    
    function cleanup(obj)
      if ~isempty(obj.Port)
        fclose(obj.Port);
        obj.Port = [];
        fprintf('Closed scales on "%s"\n', obj.ComPort);
      end
    end
    
    function delete(obj)
      cleanup(obj);
    end
  end
  
end

