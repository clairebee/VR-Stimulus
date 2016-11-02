%% 2009 -12 AA
% creating a virtual room using parameters (room) set in setExperimentPars.m
% such as room size and base distance and radius.

% 2010-05 AA: introduced an option of drawing bases randomly to the right
% or the left of the room. OPT1 =0 central bases OPT1 = 1 randomized side
% bases. Default = 0;


function Room = getRoomData(EXP, scale)

k = EXP;

% Scaling the room size based on the current chosen scale...
k.l = k.l*scale;
k.tc1 = k.tc1*scale;
k.tc2 = k.tc2*scale;
k.tc3 = k.tc3*scale;
k.tc4 = k.tc4*scale;

%% main room related

% x-y-z coordinates of vertices in 3D mouse room
% x<0 to the left of origin
% y<0 below the origin
% z<0 farther away from origin

v= [-k.b  k.h -2*k.l; ...1 MAIN LINEAR CORRIDOR
    k.b   k.h -2*k.l; ...2 multiplied by two to allow for scaling the room length
    k.b  -k.h -2*k.l; ...3
    -k.b -k.h -2*k.l; ...4
    ...
    -k.b  k.h  0; ...5
    k.b   k.h  0; ...6
    k.b  -k.h  0; ...7
    -k.b -k.h  0; % 8
    ...
    ...
    -k.b+k.delta  k.h-k.delta -k.tc1-k.tw; ...1 TEXTURE 1
    k.b-k.delta   k.h-k.delta -k.tc1-k.tw; ...2
    k.b-k.delta  -k.h+k.delta -k.tc1-k.tw; ...3
    -k.b+k.delta -k.h+k.delta -k.tc1-k.tw; ...4
    ...
    -k.b+k.delta  k.h-k.delta -k.tc1+k.tw; ...5
    k.b-k.delta   k.h-k.delta -k.tc1+k.tw; ...6
    k.b-k.delta  -k.h+k.delta -k.tc1+k.tw; ...7
    -k.b+k.delta -k.h+k.delta -k.tc1+k.tw; ...8
    ...
    ...
    -k.b+k.delta  k.h-k.delta -k.tc2-k.tw; ...1 TEXTURE 2
    k.b-k.delta   k.h-k.delta -k.tc2-k.tw; ...2
    k.b-k.delta  -k.h+k.delta -k.tc2-k.tw; ...3
    -k.b+k.delta -k.h+k.delta -k.tc2-k.tw; ...4
    ...
    -k.b+k.delta  k.h-k.delta -k.tc2+k.tw; ...5
    k.b-k.delta   k.h-k.delta -k.tc2+k.tw; ...6
    k.b-k.delta  -k.h+k.delta -k.tc2+k.tw; ...7
    -k.b+k.delta -k.h+k.delta -k.tc2+k.tw; ...8
    ...
    ...
    -k.b+k.delta  k.h-k.delta -k.tc3-k.tw; ...1 TEXTURE 3
    k.b-k.delta   k.h-k.delta -k.tc3-k.tw; ...2
    k.b-k.delta  -k.h+k.delta -k.tc3-k.tw; ...3
    -k.b+k.delta -k.h+k.delta -k.tc3-k.tw; ...4
    ...
    -k.b+k.delta  k.h-k.delta -k.tc3+k.tw; ...5
    k.b-k.delta   k.h-k.delta -k.tc3+k.tw; ...6
    k.b-k.delta  -k.h+k.delta -k.tc3+k.tw; ...7
    -k.b+k.delta -k.h+k.delta -k.tc3+k.tw; ...8
    ...
    ...
    -k.b+k.delta  k.h-k.delta -k.tc4-k.tw; ...1 TEXTURE 4
    k.b-k.delta   k.h-k.delta -k.tc4-k.tw; ...2
    k.b-k.delta  -k.h+k.delta -k.tc4-k.tw; ...3
    -k.b+k.delta -k.h+k.delta -k.tc4-k.tw; ...4
    ...
    -k.b+k.delta  k.h-k.delta -k.tc4+k.tw; ...5
    k.b-k.delta   k.h-k.delta -k.tc4+k.tw; ...6
    k.b-k.delta  -k.h+k.delta -k.tc4+k.tw; ...7
    -k.b+k.delta -k.h+k.delta -k.tc4+k.tw; ...8
    ...
    -k.b   k.h  -k.l;  ...1 end wall
    k.b   k.h -k.l; ...2
    k.b  -k.h -k.l; ...3
    -k.b -k.h -k.l];...4
    if EXP.end_walls
    v = [v; ...
        -k.b+2*k.delta  k.h-2*k.delta -k.l; ...1 TEXTURE end 1
        k.b-2*k.delta   k.h-2*k.delta -k.l; ...2
        k.b-2*k.delta  -k.h+2*k.delta -k.l; ...3
        -k.b+2*k.delta -k.h+2*k.delta -k.l; ...4
        ...
        -k.b+2*k.delta  k.h-2*k.delta -k.l+k.etw2*2; ...5
        k.b-2*k.delta   k.h-2*k.delta -k.l+k.etw2*2; ...6
        k.b-2*k.delta  -k.h+2*k.delta -k.l+k.etw2*2; ...7
        -k.b+2*k.delta -k.h+2*k.delta -k.l+k.etw2*2; ...8
        ...
        ...
        -k.b+2*k.delta  k.h-2*k.delta -k.etw1*2; ...1 TEXTURE end 2
        k.b-2*k.delta   k.h-2*k.delta -k.etw1*2; ...2
        k.b-2*k.delta  -k.h+2*k.delta -k.etw1*2; ...3
        -k.b+2*k.delta -k.h+2*k.delta -k.etw1*2; ...4
        ...
        -k.b+2*k.delta  k.h-2*k.delta 0; ...5
        k.b-2*k.delta   k.h-2*k.delta 0; ...6
        k.b-2*k.delta  -k.h+2*k.delta 0; ...7
        -k.b+2*k.delta -k.h+2*k.delta 0 ...8
        ];
    end
    v=v';
    if EXP.end_walls
        Room.nOfWalls = 30;
    else
        Room.nOfWalls = 22;
    end
    
    % clockwise (determines the front of a wall) order of vertices of
    % rectangular walls
    
    order_temp= [5 1 4 8;...     % Left
        7 3 2 6;...     % Right
        6 2 1 5;...     % Ceiling
        8 4 3 7];       % Floor
    
    order = [ 6 5 8 7;...% front
        1 2 3 4];...     % back;
        
    order = [order' order_temp']'; % walls
    order = [order' order_temp'+8]'; % text 1
    order = [order' order_temp'+8+8]'; % text 2
    order = [order' order_temp'+8+8+8]'; % text 3
    order = [order' order_temp'+8+8+8+8]'; % text 4
    if EXP.end_walls
        order = [order' order_temp'+8+8+8+8+8]'; % text end 1
        order = [order' order_temp'+8+8+8+8+8+8]'; % text end 2
    end
    order(2,:) = [41 42 43 44]; %  to shift the end wall to the limits of the current room size
    
    % wrapX = Exp.roomWidth/300;
    % wrapY = Exp.roomHeight/300;
    % wrapZ = Exp.roomLength/300;
    
    
    % Room.wrap =   [wrapY wrapZ;     % left wall
    %                wrapY wrapZ;     % right wall
    %                wrapZ wrapX;     % floor
    %                wrapX wrapY;     % far wall
    %                wrapX wrapZ;     % ceiling
    %                wrapY wrapX];    % near wall
    %Room.wrap(Room.wrap<1)=1;
    
    Room.wrap = ones(Room.nOfWalls,2);
    % Room.wrap([3],1) = 0.125;
    
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
    
end



