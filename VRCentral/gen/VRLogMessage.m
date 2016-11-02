function VRLogMessage(expInfo, message)
% Call this to log any message to the data log files in the central
% directory and the animal directory

if nargin<2
    message = [];
end


expInfo.animalLog  = fopen(expInfo.animalLogName,'a');
expInfo.centralLog = fopen(expInfo.centralLogName, 'a');
if ~isempty(message)
timeStamp = datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF');
fprintf(expInfo.animalLog,  '%s     %s \n',timeStamp, message);
fprintf(expInfo.centralLog, '%s     %s \n',timeStamp, message);
else
    fprintf(expInfo.animalLog,  '%s     %s \n',' ', ' ');
    fprintf(expInfo.centralLog, '%s     %s \n',' ', ' ');
end
fclose(expInfo.animalLog);
fclose(expInfo.centralLog);

end