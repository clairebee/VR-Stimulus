function myload(fileName)
% MYLOAD substitutes load.m to log dependences on data files
%
% Put this function in the folder of interest and rename it load.m
% Add the working directory to the top of path, then run main.m or the
% function whose dependencies you are interested in (ignore the conflict 
% warning while the function is running).
%  
% This function will create a file (LoadedFiles.txt) listing the data files
% that have been loaded during the execution of the function.
%
% Use it in conjunction with searchDependencies.m
%
% Known problems: function will crash if load has more than 1 input
% argument. i.e. load(name, var1, var2, ...)
%
% AB

wd = pwd;
mr = matlabroot;

if isempty(strfind(fileName,'C:\'))
    [ff gg hh] = fileattrib(fileName);
else
    gg.Name = fileName;
end

cd(mr); rmpath(wd);

fid = fopen(fullfile(wd,'LoadedFiles.txt'), 'a+');
fwrite(fid, sprintf('%s\r\n',fileName), 'char');
fclose(fid);

varBefore = whos; 
load(gg.Name); 
varAfter = whos;

for ivar = 1:length(varAfter)
    if isempty(strfind([varBefore.name],varAfter(ivar).name)) &&...
            ~strcmpi(varAfter(ivar).name,'varBefore')
        eval(sprintf('foo = %s;',varAfter(ivar).name));
        assignin('caller', varAfter(ivar).name, foo);
    end
end

cd(wd);
addpath(wd);
me;
end

% cd(mr); rmpath(wd);
% 
% fid = fopen(fullfile(wd,'LoadedFiles.txt'), 'a+');
% fwrite(fid, sprintf('%s\r\n',fileName), 'char');
% fclose(fid);
% 
% varBefore = whos; load(gg.Name); varAfter = whos;
% 
% for iv