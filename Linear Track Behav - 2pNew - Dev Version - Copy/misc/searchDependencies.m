function [myFunctions loadFcns] = searchDependencies(functionName,makeCopy)
% SEARCHDEPENDENCIES finds dependencies of a given function
%
% [myFunctions loadFcns] = searchDependencies( functionName )
% Searches for all dependencies of functionName that are not in the defualt
% Matlab path.
%
% functionName: the name of the function with no .m extension
% myFunctions : the list of dependencies not in the defualt Matlab path
% loadFcns    : list of fcns with 'load' statements
% To know which data files have been loaded use myload.m (see help for use)
%
% [myFunctions loadFcns] = searchDependencies( functionName, makeCopy )
%
% Copies the dependencies to the local folder 'functionName dependencies'.
%
% AB


makeCopy = 1;
if nargin<2, makeCopy = 0; end

mr = matlabroot;

% find top lelvel functions
[list, builtins, classes] = depfun(functionName,'-toponly','-quiet');

% note: only functions written by me (not built-in) will have
% dependencies on other functions that I wrote.

stillSearching = 1;
myFunctions = [];
m = 1;

while stillSearching
    
    fprintf('Iteration %d\n',m); m=m+1;
    
    nfcns = length(list);
    n = 1;
    templist = [];
    
    for ifcn = 1:nfcns
        
        k = findstr(mr,list{ifcn});
        
        if isempty(k) % it's one of my functions, not in the original path
            
            % get the name of the fcn
            [pathstr, name, ext, versn] = fileparts(list{ifcn});
            
            % do not include functionName or names already saved
            if ~strcmpi(name,functionName) && sum(strcmpi(name,myFunctions))==0
                
                % add the name to the global list
                myFunctions = [myFunctions, {name}];
                fprintf('Function found: %s\n',name);
                
                % find all its dependencies
                [fooList, builtins, classes] = depfun(name,'-toponly','-quiet');
                
                % add dependencies to a temporary list
                templist = [templist; fooList];
            end
        end
    end
    
    if isempty(templist)
        stillSearching = 0;
        fprintf('Function found: none\n');
    end
    
    % replace list with temporary one just computed and start again
    list = templist;
    
end

%% Find load statements

loadFcns = {};
for ifn = 1:length(myFunctions)
    thisfile = which(myFunctions{ifn});
    fp = fopen(thisfile);
    ss = fscanf(fp,'%s');
    if any( findstr('load',ss) )
        loadFcns{end+1} = myFunctions{ifn};
    end
    fclose(fp);
end

%% Copy functions if needed

if makeCopy
    toDir = sprintf('%s dependencies',functionName);
    dd = mkdir(toDir);
    for ifn = 1:length(myFunctions)
        ww = which(myFunctions{ifn});
        status = copyfile(ww,toDir);
        if ~status, error(sprintf('Cannot copy %s\n',myFunctions{ifn})); end
    end
end









 = which(myFunctions{ifn});
    fp = fopen(thisfile);
    ss = fscanf(fp,'%s');
    if any( findstr('load',ss) )
        loadFcns{end+1} = myFunctions{ifn};
    end
    fclose(fp);
end

%% Copy func