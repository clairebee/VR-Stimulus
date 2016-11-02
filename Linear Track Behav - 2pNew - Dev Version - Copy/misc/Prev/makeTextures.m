function texname = makeTextures(n)

% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL(1);

% Enable 2D texture mapping, so the faces of the cube will show some nice
% images:
glEnable(GL_TEXTURE_2D);

% Generate 6 textures and store their handles in vecotr 'texname'
texname=glGenTextures(n);

% Setup textures for all six sides of cube:
for i=1:n,
    % Enable i'th texture by binding it:
    glBindTexture(GL_TEXTURE_2D,texname(i));
    
     % Compute image in matlab matrix 'tx'
    texmatrix = rand(256);
    if i == 1
        texmatrix = ones(256).*0.5;
    else if i == 2
        % Compute actual cosine grating:
        x=meshgrid(1:256,1:256)./256.*pi;
        texmatrix=0.5 + 0.5*cos(5*x);
        end
    end
    
     f=max(min(128*(texmatrix),255),0);
     tx=repmat(flipdim(f,1),[ 1 1 3 ]);
     tx=permute(flipdim(uint8(tx),1),[ 3 2 1 ]);
    % Assign image in matrix 'tx' to i'th texture:
     glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,256,256,0,GL_RGB,GL_UNSIGNED_BYTE,tx);
%    glTexImage2D(GL_TEXTURE_2D,0,GL_ALPHA,256,256,1,GL_ALPHA,GL_UNSIGNED_BYTE,noisematrix);

    % Setup texture wrapping behaviour:
    glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    % Setup filtering for the textures:
    glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
   
    % Choose texture application function: It shall modulate the light
    % reflection properties of the the cubes face:
    glTexEnvfv(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
end