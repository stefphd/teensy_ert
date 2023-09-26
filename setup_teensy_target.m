function setup_teensy_target
    %% Teensy ERT target setup

    %% Add path for blocks and teensy target files
    addpath(fullfile(pwd,'teensy_ert'), fullfile(pwd,'blocks'))

    result = savepath;
    if result==1
        nl = newline;
        msg = [' Unable to save updated MATLAB path (<a href="http://www.mathworks.com/support/solutions/en/data/1-9574H9/index.html?solution=1-9574H9">why?</a>)' nl ...
               ' Exit MATLAB, right-click on the MATLAB icon, select "Run as administrator", and re-run setup_customtarget_arduino.m' nl ...
               ];
        error(msg);
    else
        disp(' Saved updated MATLAB path');
        disp(' ');
    end


    %% Build S-functions
    %TODO

    %% Register PIL/ExtMode communication interface 
    sl_refresh_customizations; %this is a MATLAB p-file

    %% Set path for Teensy tools
    teensy_ert.Prefs.setToolPath('.\tools')

    %% Set path for Teensy core
    teensy_ert.Prefs.setCorePath('.\teensy\avr\cores')

    %% Register toolchain
    RTW.TargetRegistry.getInstance('reset');
end