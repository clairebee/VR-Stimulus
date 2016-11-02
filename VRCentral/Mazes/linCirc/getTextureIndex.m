function index = getTextureIndex(str)

switch str
    case 'GRAY'
        index = 1;
    case 'WHITENOISE'
        index = 2;
    case 'WHITENOISE2'
        index = 3;
    case 'WHITENOISE3'
        index = 4;
    case 'WHITENOISE4'
        index = 5;
    case 'COSGRATING' % grating along the track, tunnel
        index = 6;
    case 'VCOSGRATING'
        index = 7;
    case 'PLAIDS'
        index = 8;
    case 'RED'
        index = 9;
    case 'BLUE'
        index = 10;
    case 'STAR'
        index = 11;
    case 'STAR_OPP'
        index = 12;
    case 'COSGRATING_OPP'
        index = 13;
    case 'VCOSGRATING_OPP'
        index = 14;
    case 'PLAIDS_OPP'
        index = 15;
    case 'VHCOSGRATING'
        index = 16;
    otherwise
        index = 2;
end