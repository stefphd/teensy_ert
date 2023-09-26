function rtwTargetInfo(tr)
tr.registerTargetInfo(@loc_createToolchain);
end

function config = loc_createToolchain
    config(1) = coder.make.ToolchainInfoRegistry;
    config(1).Name = 'Toolchain for Teensy';
    config(1).FileName = fullfile(fileparts(mfilename('fullpath')),...
        'tcTeensy.mat');
    config(1).TargetHWDeviceType = {'*'};
    config(1).Platform =  'win64';
end