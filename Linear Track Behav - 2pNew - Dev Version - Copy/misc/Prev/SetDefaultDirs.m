% function SetDefaultDirs (now a script)
% SetDefaultDirs sets the default directories

global DIRS serverName

% pick server
serverName    = 'zserver'; % or Znetgear1 or zserver2
serverDataDir = [filesep filesep serverName filesep 'Data' filesep];

% As of August 2006:
% DIRS.data       = '\\zeon\carandini\share\Data\trodes'; 		
% DIRS.spikes     = '\\zeon\carandini\share\Spikes';		
% DIRS.camera     = '\\zeon\carandini/share\Data\Camera';
% DIRS.xfiles     = '\\zeon\carandini\share\Data\xfiles';
% DIRS.michigan   = '\\zeon\carandini\share\Data\michigan';

% As of September 2008
DIRS.data       = [serverDataDir 'trodes'];
DIRS.spikes     = [serverDataDir 'Spikes'];
DIRS.camera     = [serverDataDir 'Camera'];
DIRS.xfiles     = [serverDataDir 'xfiles'];
DIRS.michigan   = [serverDataDir 'michigan'];
% Added February 2008:
% DIRS.Cerebus = '\\zeon\share\Data\cerebus';
% DIRS.Cerebus = '\\zdrobo\Data\Cerebus';
% DIRS.Cerebus = '\\zuni\Data\cerebus';
DIRS.Cerebus    = [serverDataDir 'Cerebus'];
% Added March 2008
DIRS.stimInfo   = [serverDataDir 'stimInfo'];
% Added March 2010
DIRS.behavior   = [serverDataDir 'behavior'];
% AS: added March 2010
DIRS.multichanspikes = [serverDataDir 'multichanspikes'];
DIRS.ball = [serverDataDir 'ball'];

clear serverDataDir;