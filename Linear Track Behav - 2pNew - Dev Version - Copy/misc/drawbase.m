function drawbase( base, nEdge,tx,tx1,baseType )

% if nargin < 3
%     error ('invalid number of argument')
% elseif nargin ==3
%     baseType = 'VERTICAL_DISK';
% end
% 
% global GL
% global EXP
% global ROLL_ANGLE
% 
% %%%% For transparency
% % glEnable(GL.BLEND);
% % glBlendFunc(GL.SRC_COLOR, GL.ONE_MINUS_SRC_COLOR);
% 
% if isempty(ROLL_ANGLE)
%     ROLL_ANGLE = 1;
% end
% 
% % change material reflection properties again to red:
% glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0.5 0.5 0.5 0.5 ]);
% 
% 
% viewAngle = base.stopViewAngle*180/pi;
% radius = EXP.baseRadius;
% 
% 
% x=base.stopPosition(1);
% y=0;
% z=base.stopPosition(3);
% 
% % go to base center
% glTranslated(x,y,z);
% % glRotatef(base.center(4), 0,1,0);
% glRotatef(-(viewAngle+base.center(4)), 0,1,0);
% glTranslated(0,0,-EXP.baseDistance);
% contrast = 0.5;
% 
% switch baseType
%     case 'VERTICAL_DISK'
%         
%         glRotatef(90, 0,0,1);
%         glBindTexture(GL.TEXTURE_2D,tx);%255*((tx-128)*contrast)
%         glRotatef(90, 0,0,1);
%         
%         mysphere = gluNewQuadric;
%         gluQuadricNormals(mysphere, GL.SMOOTH);
%         gluQuadricTexture(mysphere, GL.TRUE);
%         
%         gluDisk(mysphere, 0, radius, 100, 100);
%         
%         glRotatef(-90, 0,0,1);
%         glRotatef(-90, 0,0,1);
%         
%     case 'GROUND_DISK'
%         glRotatef(90, 0,0,1);
%         glRotatef(90, 1,0,0);
%         
%         glBindTexture(GL.TEXTURE_2D,tx);
%         
%         mysphere = gluNewQuadric;
%         gluQuadricNormals(mysphere, GL.SMOOTH);
%         gluQuadricTexture(mysphere, GL.TRUE);
%         
%         gluDisk(mysphere, 0, radius, 100, 100);
%         glRotatef(-90, 1,0,0);
%         glRotatef(-90, 0,0,1);
%     case 'SPHERE'
%         
%         glRotatef(-90, 1,0,0);
%         
%         glBindTexture(GL.TEXTURE_2D,tx);
%         
%         ROLL_ANGLE = ROLL_ANGLE + EXP.RollSpeed;
%         glRotatef(EXP.RollAngle, 0,1,0); % rotate to orientation
%         glRotatef(ROLL_ANGLE, 0, 0, 1); % default - right
%         
%         mysphere = gluNewQuadric;
%         gluQuadricNormals(mysphere, GL.SMOOTH);
%         gluQuadricTexture(mysphere, GL.TRUE);
%         
%         gluSphere(mysphere, radius, 100, 100);
%         
%         glRotatef(ROLL_ANGLE, 0, 0, -1); % default - right
%         glRotatef(EXP.RollAngle, 0,1,0); % rotate to orientation
%         glRotatef(90, 1,0,0);
%     case 'CYLINDER'
%         
%         glTranslated(0,-EXP.roomHeight,0);
%         glRotatef(-90, 1,0,0);
%         
%         glBindTexture(GL.TEXTURE_2D,tx);
%         
%         ROLL_ANGLE = ROLL_ANGLE + EXP.RollSpeed;
%         %         glRotatef(EXP.RollAngle, 0,1,0); % rotate to orientation
%         glRotatef(ROLL_ANGLE, 0, 0, 1); % default - right
%         
%         mysphere = gluNewQuadric;
%         gluQuadricNormals(mysphere, GL.SMOOTH);
%         gluQuadricTexture(mysphere, GL.TRUE);
%         
%         gluCylinder(mysphere, radius, radius, 2*EXP.roomHeight, 100, 100);
%         
%         glRotatef(ROLL_ANGLE, 0, 0, -1); % default - right
%         
%         glRotatef(90, 1,0,0);
%         glTranslated(0,EXP.roomHeight,0);
%         
%     case 'BUMP'
%         
%         glTranslated(0,-EXP.roomHeight,0);
%         glRotatef(-90, 1,0,0);
%         
%         glBindTexture(GL.TEXTURE_2D,tx);
%         
%         ROLL_ANGLE = ROLL_ANGLE + EXP.RollSpeed;
%         glRotatef(ROLL_ANGLE, 0, 0, 1); % default - right
%         glRotatef(EXP.RollAngle, 0,1,0); %moving up
%         
%         mysphere = gluNewQuadric;
%         gluQuadricNormals(mysphere, GL.SMOOTH);
%         gluQuadricTexture(mysphere, GL.TRUE);
%         
%         gluSphere(mysphere, radius, 100, 100);
%         
%         glRotatef(EXP.RollAngle, 0,-1,0); %moving up
%         glRotatef(ROLL_ANGLE, 0, 0, -1); % default - right
%         glRotatef(90, 1,0,0);
%         glTranslated(0,EXP.roomHeight,0);
%     otherwise
%         error(['<drawbase> basetype ' basetype ' do not exist']);
% end
% 
% glTranslated(0,0,EXP.baseDistance);
% glRotatef((viewAngle+base.center(4)), 0,1,0);
% glTranslated(-x,-y,-z);
% 
% 
% %% Draw gray disk on opposite side if nCUE is DOUBLE
% 
% if (strcmp(EXP.nCUE,'DOUBLE'))
%     % go to base center
%     glTranslated(x,y,z);
%     % glRotatef(base.center(4), 0,1,0);
%     glRotatef(-(viewAngle-base.center(4)), 0,1,0);
%     glTranslated(0,0,-EXP.baseDistance);
%     
%     switch baseType
%         case 'VERTICAL_DISK'
%             
%             glRotatef(90, 0,0,1);
%             glBindTexture(GL.TEXTURE_2D,tx1);
%             glRotatef(90, 0,0,1);
%             
%             mysphere = gluNewQuadric;
%             gluQuadricNormals(mysphere, GL.SMOOTH);
%             gluQuadricTexture(mysphere, GL.TRUE);
%             
%             gluDisk(mysphere, 0, radius, 100, 100);
%             
%             glRotatef(-90, 0,0,1);
%             glRotatef(-90, 0,0,1);
%         case 'GROUND_DISK'
%             glRotatef(90, 0,0,1);
%             glRotatef(90, 1,0,0);
%             
%             glBindTexture(GL.TEXTURE_2D,tx1);
%             
%             mysphere = gluNewQuadric;
%             gluQuadricNormals(mysphere, GL.SMOOTH);
%             gluQuadricTexture(mysphere, GL.TRUE);
%             
%             gluDisk(mysphere, 0, radius, 100, 100);
%             glRotatef(-90, 1,0,0);
%             glRotatef(-90, 0,0,1);
%         case 'SPHERE'
%             
%             glRotatef(-90, 1,0,0);
%             
%             glBindTexture(GL.TEXTURE_2D,tx1);
%             
%             mysphere = gluNewQuadric;
%             gluQuadricNormals(mysphere, GL.SMOOTH);
%             gluQuadricTexture(mysphere, GL.TRUE);
%             
%             gluSphere(mysphere, radius, 100, 100);
%             
%             glRotatef(90, 1,0,0);
%         case 'CYLINDER'
%             
%             glTranslated(0,-EXP.roomHeight,0);
%             glRotatef(-90, 1,0,0);
%             
%             glBindTexture(GL.TEXTURE_2D,tx1);
%             
%             mysphere = gluNewQuadric;
%             gluQuadricNormals(mysphere, GL.SMOOTH);
%             gluQuadricTexture(mysphere, GL.TRUE);
%             
%             gluCylinder(mysphere, radius, radius, 2*EXP.roomHeight, 100, 100);
%             
%             glRotatef(90, 1,0,0);
%             glTranslated(0,EXP.roomHeight,0);
%             
%         case 'BUMP'
%             glTranslated(0,-EXP.roomHeight,0);
%             glRotatef(-90, 1,0,0);
%             
%             glBindTexture(GL.TEXTURE_2D,tx1);
%             
%             mysphere = gluNewQuadric;
%             gluQuadricNormals(mysphere, GL.SMOOTH);
%             gluQuadricTexture(mysphere, GL.TRUE);
%             
%             gluSphere(mysphere, radius, 100, 100);
%             
%             glRotatef(90, 1,0,0);
%             glTranslated(0,EXP.roomHeight,0);
%         otherwise
%             error(['<drawbase> basetype ' basetype ' do not exist']);
%     end
%     
%     % go to base center
%     
%     % glRotatef(base.center(4), 0,1,0);
%     glTranslated(0,0,EXP.baseDistance);
%     glRotatef((viewAngle-base.center(4)), 0,1,0);
%     glTranslated(-x,-y,-z);
%     
% else
%     if ~(strcmp(EXP.nCUE,'SINGLE'))
%         error('No such training cue configuration!!');
%     end
%     
% end
% 
% 
% % Return to main function:
% %%%% For transparency
% % glDisable(GL.BLEND);
% 
return
% 
% % glDepthMask(GL.TRUE);

end
