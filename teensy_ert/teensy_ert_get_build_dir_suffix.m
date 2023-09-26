function suffix = teensy_ert_get_build_dir_suffix(modelname)
%GETBUILDDIRSUFFIX 
try
    suffix = '_';
    teensyboard = get_param(modelname, 'TeensyBoard');
    board = '';
     switch teensyboard
            case 'Teensy 4.1'
                board = 't41';
            case 'Teensy 4.0'
                board = 't40';
            case 'Teensy 3.6'
                board = 't36';
            case 'Teensy 3.5'
                board = 't35';
            case 'Teensy 3.2'
                board = 't32';
     end
    suffix = [suffix board '_ert'];
catch
    suffix =  '_ert';
end
end

