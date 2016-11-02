Version Training 3:

1) Added automated sessioning
2) added Contrast textures
3) added dialogue boxes for animal name and some parameters
4) time, trial id and reward so far are display online


version 16 Changes:

textrure related (MouseBallExp.m):


texture file (textures.mat) only contains different texture matrices 
does not repeat the texture matrices for different walls.

textures.mat contains two variables (textures,txindex)
textures : 3 texture structures 

txindex: representing different indices for different textures
txindex.GRAY
txindex.WHITENOISE
txindex.COSGRATING

when textures are mapped to walls or bases they are called with these indices

room data related (getRoomData.m)

introduced an option (OPT2==1) of getting a room without vertical walls
wrote some comments as well


version 15 changes:

-introduced keyboard quit ('q' or 'esc')
bugs resolved related to keyboard quit

changes made to:
MouseBallExp.m
	-checkkeyboard
	-endOfExperiment
	-run
	

-texture mapping is no longer clamped to edges
	-wallface


