function wallface( v,order,n,tx,wrap )

% We want to access OpenGL constants. They are defined in the global
% variable GL. GLU constants and AGL constants are also available in the
% variables GLU and AGL...
global GL


% Bind (Select) texture 'tx' for drawing:
glBindTexture(GL.TEXTURE_2D,tx);
glBegin(GL.POLYGON);

% Assign n as normal vector for this polygons surface normal:
glNormal3dv(n);

glTexCoord2dv([ 0 0 ]);
glVertex3dv(v(:,order(1)));

glTexCoord2dv([ 0 wrap(1) ]);
glVertex3dv(v(:,order(2)));

glTexCoord2dv([ wrap(2) wrap(1) ]);
glVertex3dv(v(:,order(3)));

glTexCoord2dv([ wrap(2) 0 ]);
glVertex3dv(v(:,order(4)));

glEnd;

return;
end