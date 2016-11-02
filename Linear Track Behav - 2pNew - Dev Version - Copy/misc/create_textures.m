texsize = 512;

sf = 12; % no.of bars visible

% Gray
textures(1).matrix = 0.5*ones(64,64);

% Unfiltered Whitenoise
textures(2).matrix = rand(16, 512);

% Horizontal grating
textures(6).matrix = 0.5+0.5*repmat(sin(0:((2*sf*pi)/texsize):(2*sf)*pi-(((2*sf)*pi)/texsize)),texsize,1);

% Vertical grating
textures(7).matrix = 0.5+0.5*repmat(sin(0:(((2*sf)*pi)/texsize):(2*sf)*pi-(((2*sf)*pi)/texsize))',1,texsize);

% Plaid
textures(8).matrix = (textures(6).matrix+textures(7).matrix)/2;

% c = [0:0.1:1.0];

% % Horixontal grating at 0, 10 to 100% contrast
% for n = 6:16
%     textures(n).matrix = 0.5+c(n-5)*0.5*repmat(sin(0:(((2*sf)*pi)/texsize):(2*sf)*pi-(((2*sf)*pi)/texsize)),texsize,1);
% end

% % Anti-phase Vertical, horizontal gratings
% textures(17).matrix = 1-textures(4).matrix;
% textures(20).matrix = 1-textures(3).matrix;
% textures(21).matrix = 1-textures(17).matrix;


%% Filtered White noise
% Making a 2D Gaussian filter to convolve
filtSize = 40;
sigma = 15;
sigma1 = 3;

x = 1:filtSize;


for texID = 2:5
    
    %     if texID==4; sigma = 30; end;
%     if texID==3; sigma = 5; end;

    y = exp(-((x-round(filtSize/2)).^2)/(2*sigma^2));
    y1 = exp(-((x-round(filtSize/2)).^2)/(2*sigma1^2));
    y = y./sum(y);
    y1 = y1./sum(y1);
    
    
    filt2 = y'*y1;
    % imagesc(filt2); colormap(gray)
    
    Im = rand(texsize/8+filtSize*2,texsize*4+filtSize*2);
    
    % Convolving and normalizing the image to 100% contrast
    Imf = conv2(filt2,Im);
    Imf = Imf(filtSize+floor(filtSize/2):end-ceil(filtSize/2)-filtSize,filtSize+floor(filtSize/2):end-ceil(filtSize/2)-filtSize);
    Imf = Imf - min(min(Imf));
    textures(texID).matrix = Imf./max(max(Imf));
    
end
% pause(1);
% close;

clear Im ImF filt2 texID x y
