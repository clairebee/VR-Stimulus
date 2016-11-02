% texture coding temporary code
clear all;close all;load('textures_hf_new.mat');
for i=2:5;
tmp=textures(i).matrix;
tmp=[tmp(:,1:200),tmp(:,1:200),tmp(:,1:100),tmp(:,1:500)];
textures(i).matrix=tmp;
end;
clear('tmp');clear('i');
save('textures_hf_MiK3.mat');