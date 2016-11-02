%% 2009 -12 AA
% creating a virtual room using parameters (room) set in setExperimentPars.m
% such as room size and base distance and radius.

% 2010-05 AA: introduced an option of drawing bases randomly to the right
% or the left of the room. OPT1 =0 central bases OPT1 = 1 randomized side
% bases. Default = 0;


function Room = getMazeData (Exp)

switch Exp.basePosition
    case 'CENTRE'
        OPT1 = 0;
    case 'OFFSET'
        OPT1 = 1;
end

k = Exp;
%% main room related

% x-y-z coordinates of vertices in 3D maze room
% x<0 to the left of origin
% y<0 below the origin
% z<0 farther away from origin

v= [-k.b2, k.c2, k.a2;... kc(1) LEG 1 VERTICES
     k.b2, k.c2, k.a2;... lc(2)
     k.b2, k.c2,-k.a2;... mc(3)
    -k.b2, k.c2,-k.a2;... nc(4)
    ...
    -k.b1, k.c2, k.a1;... pc(5) LEG 2 VERTICES
     k.b1, k.c2, k.a1;... qc(6)
     k.b1, k.c2,-k.a1;... rc(7)
    -k.b1, k.c2,-k.a1;... sc(8)
    ...
    -k.b2, k.c1, k.a2;... kf(9) LEG 3 VERTICES
     k.b2, k.c1, k.a2;... lf(10)
     k.b2, k.c1,-k.a2;... mf(11)
    -k.b2, k.c1,-k.a2;... nf(12)
    ...
    -k.b1, k.c1, k.a1;... pf(13) LEG 4 VERTICES
     k.b1, k.c1, k.a1;... qf(14)
     k.b1, k.c1,-k.a1;... rf(15)
    -k.b1, k.c1,-k.a1;... sf(16)
    ...
    -k.b1, k.c2, k.a2;... pf(17) ALL LEGS xtra VERTICES
     k.b1, k.c2, k.a2;... qf(18)
     k.b1, k.c2,-k.a2;... rf(19)
    -k.b1, k.c2,-k.a2;... sf(20)
    ...
    -k.b1, k.c1, k.a2;... pf(21) ALL LEGS xtra VERTICES
     k.b1, k.c1, k.a2;... qf(22)
     k.b1, k.c1,-k.a2;... rf(23)
    -k.b1, k.c1,-k.a2;... sf(24)
    ...
    -k.tw, k.c2-k.delta, k.a2-k.delta;... t1c1(1) TEXTURE 1
     k.tw, k.c2-k.delta, k.a2-k.delta;... t1c2(2)
     k.tw, k.c2-k.delta, k.a1+k.delta;... t1c3(3)
    -k.tw, k.c2-k.delta, k.a1+k.delta;... t1c4(4)
    ...
    -k.tw, k.c1+k.delta, k.a2-k.delta;... t1f1(5) TEXTURE 1
     k.tw, k.c1+k.delta, k.a2-k.delta;... t1f2(6)
     k.tw, k.c1+k.delta, k.a1+k.delta;... t1f3(7)
    -k.tw, k.c1+k.delta, k.a1+k.delta;... t1f4(8)
    ...
    ...
    -k.tw, k.c2-k.delta, -k.a2+k.delta;... t2c1(9) TEXTURE 2
     k.tw, k.c2-k.delta, -k.a2+k.delta;... t2c2(10)
     k.tw, k.c2-k.delta, -k.a1-k.delta;... t2c3(11)
    -k.tw, k.c2-k.delta, -k.a1-k.delta;... t2c4(12)
    ...
    -k.tw, k.c1+k.delta, -k.a2+k.delta;... t2f1(13) TEXTURE 2
     k.tw, k.c1+k.delta, -k.a2+k.delta;... t2f2(14)
     k.tw, k.c1+k.delta, -k.a1-k.delta;... t2f3(15)
    -k.tw, k.c1+k.delta, -k.a1-k.delta;... t2f4(16)
    ...
    ...
     k.b2-k.delta, k.c2-k.delta, k.tw;... t3c1(17) TEXTURE 3
     k.b2-k.delta, k.c2-k.delta,-k.tw;... t3c2(18)
     k.b1+k.delta, k.c2-k.delta,-k.tw;... t3c3(19)
     k.b1+k.delta, k.c2-k.delta, k.tw;... t3c4(20)
    ...
     k.b2-k.delta, k.c1+k.delta, k.tw;... t3f1(21) TEXTURE 3
     k.b2-k.delta, k.c1+k.delta,-k.tw;... t3f2(22)
     k.b1+k.delta, k.c1+k.delta,-k.tw;... t3f3(23)
     k.b1+k.delta, k.c1+k.delta, k.tw;... t3f4(24)
    ...
    ...
     -k.b2+k.delta, k.c2-k.delta, k.tw;... t4c1(25) TEXTURE 4
     -k.b2+k.delta, k.c2-k.delta,-k.tw;... t4c2(26)
     -k.b1-k.delta, k.c2-k.delta,-k.tw;... t4c3(27)
     -k.b1-k.delta, k.c2-k.delta, k.tw;... t4c4(28)
    ...
     -k.b2+k.delta, k.c1+k.delta, k.tw;... t4f1(29) TEXTURE 4
     -k.b2+k.delta, k.c1+k.delta,-k.tw;... t4f2(30)
     -k.b1-k.delta, k.c1+k.delta,-k.tw;... t4f3(31)
     -k.b1-k.delta, k.c1+k.delta, k.tw;... t4f4(32)
    ];
v = v';

Room.nOfWalls = 32;

% clockwise (determines the fromt of a wall) order of vertices of
% rectangular walls

order= [...
    17 18 6 5;...     LEG 1
    21 22 14 13;... 
    1 2 10 9;...
    5 6 14 13;...
    ...
    2 3 19 18;...     LEG 2
    10 11 23 22;...
    2 3 11 10;...
    6 7 15 14;...
    ...
    19 20 8 7;...     LEG 3
    23 24 16 15;...
    3 4 12 11;...
    7 8 16 15;...
    ...
    4 1 17 20;...     LEG 4
    12 9 21 24;...
    4 1 9 12;...
    8 5 13 16;
...
    1 4 3 2;...                 L1 TEX 1 (ADD 24 for all texture coordinates)
    5 8 7 6;...                 L1 TEX 2
    1 5 6 2;...                 L1 TEX 3
    4 8 7 3;...                 L1 TEX 4
    ...
    17    20    19    18;...    L2 TEX 1
    21    24    23    22;...    L2 TEX 2
    17    21    22    18;...    L2 TEX 3
    20    24    23    19;...    L2 TEX 4
    ...
     9    12    11    10;...    L3 TEX 1
    13    16    15    14;...    L3 TEX 2
     9    13    14    10;...    L3 TEX 3
    12    16    15    11;...    L3 TEX 4
    ...
    25    28    27    26;...    L4 TEX 1
    29    32    31    30;...    L4 TEX 2
    25    29    30    26;...    L4 TEX 3
    28    32    31    27;...    L4 TEX 4
    ];

order(17:end,:) = order(17:end,:) + 24;
    
% wrapX = Exp.roomWidth/300;
% wrapY = Exp.roomHeight/300;
% wrapZ = Exp.roomLength/300;
% 
% 
% Room.wrap =   [wrapY wrapZ;     % left wall
%                wrapY wrapZ;     % right wall
%                wrapZ wrapX;     % floor
%                wrapX wrapY;     % far wall
%                wrapX wrapZ;     % ceiling
%                wrapY wrapX];    % near wall
% 
% Texture coordinates


Room.wrap=ones(32);  
           
Room.normals = [];
for i=1:Room.nOfWalls
    
    n = cross((v(:,order(i,2))-v(:,order(i,1))),(v(:,order(i,3))-v(:,order(i,2))));
    n = n./sqrt(n(1)^2+n(2)^2+n(3)^2);
    Room.normals = [Room.normals; n'];
end


% room size is 2*width, 2*height, 1*length
% I choose to have coordinates of the room as follows:
% -width<x<width -height<y<height -length<z<0


% v(1,:) = v(1,:)*Exp.roomWidth;
% v(2,:) = v(2,:)*Exp.roomHeight;
% v(3,:) = v(3,:)*Exp.roomLength;

Room.v = v;
Room.order = order;



%% bases
switch Exp.cueGeneration
    case 'PRESET'
        cX = [];
        cY = [];
        cZ = [];
        cA = 0;
    nOfBases = length(Exp.rewCorners);
    Room.nOfBases = nOfBases;
        for rewID = 1:nOfBases
            switch Exp.rewCorners(rewID)
                case 1
                    cX = [cX -(k.b2 + k.w*cosd(45))];
                    cY = [cY k.c3];
                    cZ = [cZ -(k.a2 + k.w*cosd(45))];
                case 2
                    cX = [cX (k.b2 + k.w*cosd(45))];
                    cY = [cY k.c3];
                    cZ = [cZ -(k.a2 + k.w*cosd(45))];
                case 3
                    cX = [cX (k.b2 + k.w*cosd(45))];
                    cY = [cY k.c3];
                    cZ = [cZ (k.a2 + k.w*cosd(45))];
                case 4
                    cX = [cX -(k.b2 + k.w*cosd(45))];
                    cY = [cY k.c3];
                    cZ = [cZ (k.a2 + k.w*cosd(45))];
                otherwise
                    display('undefined reward location');
            end
        end
        
        Room.BaseCoor = [cX' cY' -cZ' pi/4*ones(nOfBases,1)];

        
        %         if (2*Exp.baseRadius  + Exp.sideBaseOffset  > 2*Exp.roomWidth)
%             fprintf('Warning !!! room is too narrow, increase room width \n')
%         end
% 
%         if (4*Exp.baseRadius > Exp.roomLength)
%             fprintf('Warning !!!  room is too short, increase room length \n')
%         end
% 
%         nOfBases = floor((Exp.roomLength - 2*Exp.baseRadius +Exp.baseDistance)...
%             /(Exp.baseDistance+2*Exp.baseRadius));
% 
%         if mod((Exp.roomLength - 3*Exp.baseRadius),Exp.baseDistance) > 3*Exp.baseRadius
%                 nOfBases = nOfBases+1;
%         end
%    
    
    case 'ONLINE'
        display('Online CUE generation not valid');
        return;
end

% Room.nOfBases = nOfBases;
% 
% r=rand(nOfBases-1,1);
% r=r./sum(r);
% r=r.*(nOfBases-1)*(Exp.baseDistance);
% 
% cX = 0;
% cY = 0;
% cZ = 3*Exp.baseRadius; 
% 
% xr = rand(nOfBases,1);
% %xr=(xr-0.5)*2;
% 
% xs = sign(rand(nOfBases,1)-0.5);%-Exp.leftPr);
% 
% % random offset angles
% cA = (xs.*xr.*(Exp.maxOffsetAngle-Exp.minOffsetAngle)+xs.*Exp.minOffsetAngle);
% for i=2:nOfBases
%     
%     if(i>2 )
%         if (sign(cA(i))==sign(cA(i-1))&& sign(cA(i))==sign(cA(i-2)))
%                     cA(i)=-1*cA(i);
%         end
%     end
% end
% 
% cA = cA + Exp.bias;
%   

% Room.BaseCoor = [cX cY -cZ cA(1)];

% for i=2:nOfBases
%     cZ = cZ + 2*Exp.baseRadius + r(i-1);
%     Room.BaseCoor = [ Room.BaseCoor; cX cY -cZ cA(i)];
% end


% if strcmp(Exp.cueGeneration,'ONLINE')
%     Room.BaseCoor(:,3) = 0;
% end
end



