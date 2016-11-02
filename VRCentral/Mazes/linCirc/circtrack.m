function circtrack(SegType,EXP,scale,tx1,tx2,tx3,AnglePos)

% We want to access OpenGL constants. They are defined in the global
% variable GL. GLU constants and AGL constants are also available in the
% variables GLU and AGL...
global GL
MazeRadius = scale*EXP.l/(2*pi);
MazeResol_high = 100*scale;
MazeResol_low = 1;
dwTrack = EXP.b;%4;
yTrack = -EXP.b;%-4;
yfloor = 2 * yTrack;
dzCylinder = EXP.tw;
dyCylinder = 0.95*(dwTrack + ((MazeRadius-dwTrack)-((MazeRadius-dwTrack)^2-(dzCylinder/2)^2)^0.5));%6;%EXP.h;
dyCylinderOut = (dwTrack + 1.05*((MazeRadius-dwTrack)-((MazeRadius-dwTrack)^2-(dzCylinder/2)^2)^0.5));%6;%EXP.h;
dyInnerwall = 0.2*dwTrack;%30 * dyCylinder;%0.5*dyCylinder;
dyOuterwall = 0.3 * dyInnerwall;
dyFarouterwall = 10 * dyCylinder;
FarwallRadius = MazeRadius+dyCylinderOut + ((MazeRadius+dyCylinderOut)-((MazeRadius+dyCylinderOut)^2-(dzCylinder/2)^2)^0.5);%5.5*MazeRadius;
DistcueRadius = 3.5 * MazeRadius;
dzPole = 5;

dyPole = 20;
ScaleTexWalls = 5;
% ScaleTexArch = dzCylinder/6;%we want the textures to be full size when the arch is 6 cm long; otherwise we scale it
%05.01.2016 scaletexarch changed
ScaleTexArch = dzCylinder/18;%we want the textures to be full size when the arch is 12 cm long; otherwise we scale it

dzSmallCue = 2*dzCylinder;
ScaleTexSmallCue = dzSmallCue/6;

mydisk = gluNewQuadric;
mycylinder = gluNewQuadric;
gluQuadricNormals(mydisk, GL.SMOOTH);
gluQuadricTexture(mydisk, GL.TRUE);
gluQuadricNormals(mycylinder, GL.SMOOTH);
gluQuadricTexture(mycylinder, GL.TRUE);

switch SegType
    case 'TRACK'
        %circular track
        glPushMatrix();
        glTranslated(-MazeRadius,yTrack,0); 
        glRotatef(90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluDisk(mydisk, MazeRadius-dwTrack, MazeRadius+dwTrack, MazeResol_high, MazeResol_high);
        glPopMatrix();
        
        glPushMatrix();
        glTranslated (-MazeRadius,yTrack-dyInnerwall,0); 
        glRotatef(90, 0,1,0);
        glRotatef(-90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx2);
        gluCylinder(mycylinder, MazeRadius-dwTrack, MazeRadius-dwTrack, dyInnerwall, MazeResol_high, MazeResol_low);
        glPopMatrix();
        
        glPushMatrix();
        glTranslated(-MazeRadius,yTrack,0); 
        glRotatef(90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx2);
        gluDisk(mydisk, 0, MazeRadius-dwTrack, MazeResol_high, MazeResol_high);
        glPopMatrix();
    case 'GFLOOR'
        %ground floor
        glPushMatrix();
        glTranslated(-MazeRadius,yfloor,0); 
        glRotatef(90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluDisk(mydisk, 0, 4*MazeRadius, MazeResol_high, MazeResol_high);
        glPopMatrix();
    case 'INNERWALL'
        %inner wall
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);
        
        glPushMatrix();
        glTranslated (-MazeRadius,yTrack-dyInnerwall,0); 
        glRotatef(90, 0,1,0);
        glRotatef(-90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluCylinder(mycylinder, (MazeRadius-dwTrack), (MazeRadius-dwTrack), dyInnerwall, MazeResol_high, MazeResol_low);
        glPopMatrix();
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);        
    case 'OUTERWALL'
        %outer wall        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(ScaleTexWalls,1,1);
        glMatrixMode(GL.MODELVIEW);
        
        glPushMatrix();
        glTranslated (-MazeRadius,yTrack,0);
        glRotatef(90, 0,1,0);
        glRotatef(-90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluCylinder(mycylinder, (MazeRadius+dwTrack), (MazeRadius+dwTrack), dyOuterwall, MazeResol_high, MazeResol_low);
        glPopMatrix();
        glPushMatrix();
        glTranslated(-MazeRadius,yTrack+dyOuterwall,0); 
        glRotatef(90, 0,1,0);
        glRotatef(90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx2);
        gluDisk(mydisk, MazeRadius+dwTrack, MazeRadius+dwTrack+0.5*dyOuterwall, MazeResol_high, MazeResol_low);
        glPopMatrix();
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);
    case 'FARWALL'
        %far outer wall
        glMatrixMode(GL.TEXTURE);
        
        glLoadIdentity();
        glScalef(1,1,1);
        glRotatef(90,0,0,1);
        glMatrixMode(GL.MODELVIEW);
        
        glPushMatrix();
        glTranslated (-MazeRadius,yfloor,0); 
        glRotatef(90, 0,1,0);
        glRotatef(-90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluCylinder(mycylinder, FarwallRadius, FarwallRadius, dyFarouterwall, MazeResol_high, MazeResol_high);
        glPopMatrix();
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);
    case 'ARCH'        
        %arches (proximal cues)
        %inside        
        glBindTexture(GL.TEXTURE_2D,tx1);
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(pi,ScaleTexArch,1);%we scale the texture by pi so it looks the same as on the floor
        glMatrixMode(GL.MODELVIEW);
        
        glPushMatrix();
        glTranslated (-MazeRadius+MazeRadius*cosd(AnglePos)-0.5*dzCylinder*sind(AnglePos),yTrack,-MazeRadius*sind(AnglePos)-0.5*dzCylinder*cosd(AnglePos)); 
        glRotatef(AnglePos, 0,1,0);
        glRotatef(180, 0,0,1);        
        gluCylinder(mycylinder, dyCylinder, dyCylinder, dzCylinder, MazeResol_high, MazeResol_high);
        glPopMatrix();
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);
                
        %front
        glPushMatrix();
        glTranslated(-MazeRadius+MazeRadius*cosd(AnglePos)-0.5*dzCylinder*sind(AnglePos),yTrack,-MazeRadius*sind(AnglePos)-0.5*dzCylinder*cosd(AnglePos)); 
        glRotatef(AnglePos, 0,1,0);
        glBindTexture(GL.TEXTURE_2D,tx2);
        gluDisk(mydisk, dyCylinder, dyCylinderOut, MazeResol_high, MazeResol_high);
        glPopMatrix();
        %outside
        glPushMatrix();
        glTranslated (-MazeRadius+MazeRadius*cosd(AnglePos)-0.5*dzCylinder*sind(AnglePos),yTrack,-MazeRadius*sind(AnglePos)-0.5*dzCylinder*cosd(AnglePos)); 
        glRotatef(AnglePos, 0,1,0);
        glRotatef(180, 0,0,1);
        glBindTexture(GL.TEXTURE_2D,tx3);
        gluCylinder(mycylinder, dyCylinderOut, dyCylinderOut, dzCylinder, MazeResol_high, MazeResol_high);
        glPopMatrix();
        %back
        glPushMatrix();
        glTranslated(-MazeRadius+MazeRadius*cosd(AnglePos)+0.5*dzCylinder*sind(AnglePos),yTrack,-MazeRadius*sind(AnglePos)+0.5*dzCylinder*cosd(AnglePos)); 
        glRotatef(AnglePos, 0,1,0);
        glBindTexture(GL.TEXTURE_2D,tx2);
        gluDisk(mydisk, dyCylinder, dyCylinderOut, MazeResol_high, MazeResol_high);
        glPopMatrix();
        %floor
        glBindTexture(GL.TEXTURE_2D,tx1);
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,ScaleTexArch,1);%we scale the texture ScaleTexArch
        glMatrixMode(GL.MODELVIEW);
        
        glPushMatrix();
        glTranslated (-MazeRadius+MazeRadius*cosd(AnglePos)-0.5*dzCylinder*sind(AnglePos),yTrack+0.001,-MazeRadius*sind(AnglePos)-0.5*dzCylinder*cosd(AnglePos));
        glRotatef(AnglePos, 0,1,0);
        glBegin(GL.POLYGON);
%         glNormal3dv([0 1 0]);
        glTexCoord2dv([ 0 0 ]);
        glVertex3dv([-dyCylinder 0 0]); 
        glTexCoord2dv([ 0 1 ]);
        glVertex3dv([-dyCylinder 0 +dzCylinder]);
        glTexCoord2dv([ 1 1 ]);
        glVertex3dv([+dyCylinder 0 +dzCylinder]);
        glTexCoord2dv([ 1 0 ]);
        glVertex3dv([+dyCylinder 0 0]);
        glEnd;
        glPopMatrix();
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);
        
    case 'SMALLCUE'
        glPushMatrix();
        glTranslated (-MazeRadius+MazeRadius*cosd(AnglePos)-0.5*dzCylinder*sind(AnglePos),yTrack+0.001,-MazeRadius*sind(AnglePos)-0.5*dzCylinder*cosd(AnglePos));  
        glRotatef(90, 1,0,0);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluDisk(mydisk, 0, 0.2*dwTrack, 0.5*MazeResol_high, 0.5*MazeResol_high);
        glPopMatrix();
%         glPushMatrix();
%         glTranslated (-MazeRadius+(MazeRadius+dwTrack)*cosd(AnglePos)-0.5*dzSmallCue*sind(AnglePos),yTrack+0.001,-(MazeRadius+dwTrack)*sind(AnglePos)-0.5*dzSmallCue*cosd(AnglePos));
%         glRotatef(AnglePos, 0,1,0);
%         glRotatef(90, 0,0,1);
%         glBegin(GL.POLYGON);
% %         glNormal3dv([0 1 0]);
%         glTexCoord2dv([ 0 0 ]);
%         glVertex3dv([0 0 0]); 
%         glTexCoord2dv([ 0 1 ]);
%         glVertex3dv([0 0 +dzSmallCue]);
%         glTexCoord2dv([ 1 1 ]);
%         glVertex3dv([+dyCylinder 0 +dzSmallCue]);
%         glTexCoord2dv([ 1 0 ]);
%         glVertex3dv([+dyCylinder 0 0]);
%         glEnd;
%         glPopMatrix();
%         
%         glPushMatrix();
%         glTranslated (-MazeRadius+MazeRadius*cosd(AnglePos)-0.5*dzSmallCue*sind(AnglePos),yTrack+dyCylinder,-MazeRadius*sind(AnglePos)-0.5*dzSmallCue*cosd(AnglePos));
%         glRotatef(AnglePos, 0,1,0);
%         glBegin(GL.POLYGON);
% %         glNormal3dv([0 1 0]);
%         glTexCoord2dv([ 0 0 ]);
%         glVertex3dv([-dyCylinder 0 0]); 
%         glTexCoord2dv([ 0 1 ]);
%         glVertex3dv([-dyCylinder 0 +dzSmallCue]);
%         glTexCoord2dv([ 1 1 ]);
%         glVertex3dv([+dyCylinder 0 +dzSmallCue]);
%         glTexCoord2dv([ 1 0 ]);
%         glVertex3dv([+dyCylinder 0 0]);
%         glEnd;
%         glPopMatrix();
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);

    case 'DISTALCUES'
        %poles
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(0.5,1,1);%we scale the texture by pi so it looks the same as on the floor
        glMatrixMode(GL.MODELVIEW);
        
        glPushMatrix();        
        glTranslated(-MazeRadius+DistcueRadius*cosd(AnglePos),yfloor,-DistcueRadius*sind(AnglePos)); 
        glRotatef(-90, 1,0,0);
        glRotatef(AnglePos, 0,0,1);
        glBindTexture(GL.TEXTURE_2D,tx1);
        gluCylinder(mycylinder, dzPole, dzPole, dyPole, MazeResol_high, MazeResol_low);
        glPopMatrix();                
        
        glMatrixMode(GL.TEXTURE);
        glLoadIdentity();
        glScalef(1,1,1);
        glMatrixMode(GL.MODELVIEW);

%         %sphere
%         glPushMatrix();        
%         glTranslated(-MazeRadius+DistcueRadius*cosd(AnglePos),yfloor+dzPole+dyPole,-DistcueRadius*sind(AnglePos));
%         glRotatef(90,1,0,0);
%         glRotatef(AnglePos,0,0,1);
%         glBindTexture(GL.TEXTURE_2D,tx2);
%         gluSphere(mycylinder, 2*dzPole, MazeResol_high, MazeResol_high);
%         glPopMatrix();
end

return;
end