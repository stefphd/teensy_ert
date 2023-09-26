classdef Launcher < rtw.connectivity.Launcher
%LAUNCHER launches real-time application on Teensy
%
%   See also RTW.CONNECTIVITY.LAUNCHER, RTWDEMO_CUSTOM_PIL
    
    methods
        % constructor
        function this = Launcher(componentArgs, builder)
            error(nargchk(2, 2, nargin, 'struct'));
            % call super class constructor

            this@rtw.connectivity.Launcher(componentArgs, builder);
        end
        
        % destructor
        function delete(this) %#ok
        end
        
        % Start the application
        function startApplication(this)
            %addpath([get_param(gcs,'Name') '_teensy/']);
            buildDirs = RTW.getBuildDir(get_param(gcs,'Name'));
            oldDir = cd(buildDirs.BuildDirectory);
            hexfile = this.getBuilder.getApplicationExecutable;
            teensy_ert.runLoader(hexfile);
            cd(oldDir);
        end
        
        % Stop the application
        function stopApplication(~)
            %empty
        end
    end
end
