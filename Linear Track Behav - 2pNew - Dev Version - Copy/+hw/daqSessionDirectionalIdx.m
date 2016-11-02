function i = daqSessionDirectionalIdx(session, channelIdx, direction)
%DAQSESSIONDIRECTIONALIDX Index of channel within direction sublist
%   DAQ Channels are either 'Input' or 'Output'. channelIdx specifies 
%   a channel of interest within the Session's full channel list. This 
%   function then finds all the channels of 'direction' (input or
%   output) within the full list. It then returns the index of the channel
%   of interest within the direction-specific list.
%   
%   This is useful for knowing what index into data matrices sent or
%   received to/from the DAQ pertain to that channel. e.g. if you recieve
%   a block of data from startForeground it will be an mxn matrix, where m
%   is the number of samples and n is the number of *input* channels (out 
%   of all the channels). This function will give you the correct column index 
%   into that matrix when all you might know is the overall (session-based)
%   channel index.

directionChannels = strcmpi(direction, hw.daqSessionChannelDirections(session));
assert(directionChannels(channelIdx), ...
  sprintf('channelIdx %i does not have direction "%s"', channelIdx, direction));
indexes = cumsum(directionChannels);
i = indexes(channelIdx);
end

