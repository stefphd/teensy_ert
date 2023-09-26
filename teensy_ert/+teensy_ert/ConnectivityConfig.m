classdef ConnectivityConfig < rtw.connectivity.Config
%CONNECTIVITYCONFIG PIL configuration class for Teensy
%
%   CONNECTIVITYCONFIG(COMPONENTARGS) creates instances of MAKEFILEBUILDER,
%   LAUNCHER, RTIOSTREAMHOSTCOMMUNICATOR and collects them together into a
%   connectivity configuration class for PIL.
%
%   See also RTW.CONNECTIVITY.CONFIG, RTW.CONNECTIVITY.MAKEFILEBUILDER,
%   RTW.MYPIL.TARGETAPPLICATIONFRAMEWORK, RTW.MYPIL.LAUNCHER,
%   RTW.CONNECTIVITY.RTIOSTREAMHOSTCOMMUNICATOR, RTWDEMO_CUSTOM_PIL
    
    methods
        function this = ConnectivityConfig(componentArgs)
            
        % An executable framework specifies additional source files and
        % libraries required for building the PIL executable
            targetApplicationFramework = ...
                teensy_ert.TargetApplicationFramework(componentArgs);
            
            % Filename extension for executable on the target system
            exeExtension = '.hex';
            
            % Create an instance of MakefileBuilder; this works in
            % conjunction with your template makefile to build the PIL
            % executable
            builder = rtw.connectivity.MakefileBuilder...
                      (componentArgs, ...
                       targetApplicationFramework, ...
                       exeExtension);
            
            % Launcher
            launcher = teensy_ert.Launcher(componentArgs, builder);
            
            % File extension for shared libraries (e.g. .dll on Windows)
            sharedLibExt='.dll';

            % Evaluate name of the rtIOStream shared library
            rtiostreamLib = ['rtiostreamserial' sharedLibExt];
            
            communicator = teensy_ert.Communicator(componentArgs, ...
                                                launcher, ...
                                                rtiostreamLib);
            communicator.setTimeoutRecvSecs(5);
            rtIOStreamOpenArgs = {...                                  
                '-port', ['\\.\COM1'], ...
                '-baud', num2str(4000000)
                };                                                     
            
            communicator.setOpenRtIOStreamArgList(rtIOStreamOpenArgs); 
            
            % call super class constructor to register components
            this@rtw.connectivity.Config(componentArgs, builder, launcher, communicator);

            % The timer API is changing so we need to check whether to use the 
            % new or old style
            if teensy_ert.ConnectivityConfig.isOldStyleTimerApi
                % Register a timer if the execution profiling infrastructure is available. For
                % PIL simulations, a file execProfile.mat is created in the pil
                % sub-folder of the build directory. This file contains execution
                % time measurements for the component that you are running in PIL
                % simulation mode.
                if ~isempty(?rtw.connectivity.Timer)
                    timer = teensy_ert.TimerOldStyle(targetApplicationFramework);
                    this.setTimer(timer);
                end
            else
                timer = teensy_ert.Timer;
                this.setTimer(timer);
            end
        end
    end
    
    methods (Static = true)
        function isOldStyle = isOldStyleTimerApi
            h = new_system;
            try
                get_param(h,'CodeExecutionProfiling');
                isOldStyle=false;
            catch exc
                if any(strcmp(exc.identifier, {'Simulink:SL_ParamUnknown', ...
                        'Simulink:Commands:ParamUnknown'}))
                    isOldStyle=true;
                else
                    rethrow(exc);
                end
            end
            close_system(h);
        end
    end
end
