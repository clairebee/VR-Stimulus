function rig = devices(name, init)
%HW.DEVICES Returns hardware interfaces configured for rig
%   rig = HW.DEVICES([name], [init])
%
% Part of Rigbox

% 2012-11 CB created
% 2013-02 CB modified

if nargin < 1 || isempty(name)
  name = hostname;
end

if nargin < 2
  init = true;
end

paths = dat.paths(name);

% if strcmp(name, 'zen')
%   baseDir = 'D:\Users\Chris\Documents\MATLAB\Experiments';
%   configDir = fullfile(fullfile(baseDir, 'config'), name);
% else
%   baseDir = '\\zserver\code\Rigging';
%   configDir = fullfile(fullfile(baseDir, 'config'), name);
% end
%% Basic initialisation
rig = load(fullfile(paths.rigConfig, 'hardware.mat'));
rig.name = name;
rig.useTimeline = pick(rig, 'useTimeline', 'def', false);
rig.clock = iff(rig.useTimeline, hw.TimelineClock, hw.ptb.Clock);
rig.useDaq = pick(rig, 'useDaq', 'def', true);

%% Configure common devices, if present
configure('mouseInput');
configure('rewardController');
configure('lickDetector');

%% Deal with reward controller calibrations
if init && isfield(rig, 'rewardController')
  if isfield(rig, 'rewardCalibrations')
    % use most recent reward calibration
    [newestDate, idx] = max([rig.rewardCalibrations.dateTime]);
    rig.rewardController.MeasuredDeliveries =...
      rig.rewardCalibrations(idx).measuredDeliveries;
    fprintf('\nApplying reward calibration performed on %s\n', datestr(newestDate));
  else
    %create an empty structure
    rig.rewardCalibrations = struct('dateTime', {}, 'measuredDeliveries', {});
    warning('Rigbox:hw:calibration', 'No reward calibrations found');
  end
end

if init
  % intialise psychportaudio 
  InitializePsychSound;
  % setup playback audio device - no configurable settings for now
  % 96kHz sampling rate, 2 channels, try to very low audio latency
  rig.audio = aud.open(2, 96e3, 2);
end

rig.paths = paths;

%% Helper function
  function configure(deviceName)
    if isfield(rig, deviceName)
      device = rig.(deviceName);
      device.Clock = rig.clock;
      if init && rig.useDaq
        device.DaqSession = daq.createSession('ni');
        device.createDaqChannel();
      end
    end
  end

end

