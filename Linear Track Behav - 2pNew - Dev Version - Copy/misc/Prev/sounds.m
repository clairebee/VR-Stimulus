beepon  = 0.5*MakeBeep(4400,0.1);
beepoff = 0.5*MakeBeep(2200,0.1);
oBeepOn  = audioplayer(beepon ,22000);
oBeepOff = audioplayer(beepoff,22000);
oRingRing = audioplayer([ring; ring], 2*8192);
% should not assume this file is in 'C:\WINDOWS\Media', should make it local
ring = wavread('C:\WINDOWS\Media\ringin.wav');
oBeepOn  = audioplayer(beepon ,22000);
oBeepOff = audioplayer(beepoff,22000);
oRingRing = audioplayer([ring; ring], 2*8192);
beepon  = 0.5*MakeBeep(4400,0.1);
beepoff = 0.5*MakeBeep(2200,0.1);
% should not assume this file is in 'C:\WINDOWS\Media', should make it local
ring = wavread('C:\WINDOWS\Media\ringin.wav');
oBeepOn  = audioplayer(beepon ,22000);
oBeepOff = audioplayer(beepoff,22000);
oRingRing = audioplayer([ring; ring], 2*8192);
play(oRingRing);
play(oRingRing);
play(oBeepOn);
play(oBeepOff);
figure; plot(beepon)