ZirkusPort  = pnet('udpsocket', 1001);
pnet(ZirkusPort,'udpconnect','144.82.135.38',1001);

pnet(ZirkusPort, 'write',['ExpStart MOUSE ' int2str(1)]);
pnet(ZirkusPort, 'writePacket');


pnet(ZirkusPort, 'write',['BlockStart MOUSE ' int2str(1) ' ' int2str(1)]);
pnet(ZirkusPort, 'writePacket');

pnet( ZirkusPort,'write',['TrialStart MOUSE ' int2str(1) ' '  int2str(1) ' ' int2str(2)]);
pnet(ZirkusPort, 'writePacket');

pnet( ZirkusPort,'write',['TrialEnd MOUSE ' int2str(1) ' '  int2str(1) ' ' int2str(2)]);
pnet(ZirkusPort, 'writePacket');

pnet(ZirkusPort, 'write',['BlockEnd MOUSE ' int2str(1) ' ' int2str(1)]);
pnet(ZirkusPort, 'writePacket');

pnet(ZirkusPort, 'write',['ExpEnd MOUSE ' int2str(1)]);
pnet(ZirkusPort, 'writePacket');

pnet(ZirkusPort, 'close');