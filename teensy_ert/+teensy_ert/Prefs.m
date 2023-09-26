classdef Prefs
%PREFS gives access to Teensy EC preferences file

    methods (Static, Access=public)
%%
        function setCorePath(corePath)
            if ~exist('corePath', 'var') || ~ischar(corePath)
               nl = newline;
               error('RTW:teensy_ert:invalidCorePath', ...
                      ['Teensy core path must be a string, e.g.' nl ...
                       '   teensy_ert.Prefs.setCorePath(''.\cores'')']);
            end

            javaFileObj = java.io.File(corePath);
            if ~javaFileObj.isAbsolute()
                corePath = fullfile(pwd, corePath);
            end
            
            if ~exist(corePath,'dir')
                error('RTW:teensy_ert:invalidCorePath', 'The specified folder (%s) does not exist', toolPath);
            end

            if ~exist(fullfile(corePath, 'teensy4'), 'dir') || ~exist(fullfile(corePath, 'teensy3'), 'dir')
                error('RTW:teensy_ert:invalidCorePath', 'The specified folder (%s) does not contain teensy3 and teensy4 folders', toolPath);
            end

            % remove trailing backslashes
            corePath = regexprep(corePath, '\\+$', '');

            % Alternate form of path to handle spaces
            altPath = RTW.transformPaths(corePath, 'pathType', 'alternate');

            teensy_ert.Prefs.setPref('CorePath', altPath);
        end
%%
        function setToolPath(toolPath)

            if ~exist('toolPath', 'var') || ~ischar(toolPath)
               nl = newline;
               error('RTW:teensy_ert:invalidToolPath', ...
                      ['Teensy tool path must be a string, e.g.' nl ...
                       '   teensy_ert.Prefs.setToolPath(''.\tools'')']);
            end

            javaFileObj = java.io.File(toolPath);
            if ~javaFileObj.isAbsolute()
                toolPath = fullfile(pwd, toolPath);
            end
            
            if ~exist(toolPath,'dir')
                error('RTW:teensy_ert:invalidToolPath', 'The specified folder (%s) does not exist', toolPath);
            end

            if ~exist(fullfile(toolPath, 'teensy.exe'), 'file')
                error('RTW:teensy_ert:invalidToolPath', 'The specified folder (%s) does not contain teensy.exe', toolPath);
            end

            % remove trailing backslashes
            toolPath = regexprep(toolPath, '\\+$', '');

            % Alternate form of path to handle spaces
            altPath = RTW.transformPaths(toolPath, 'pathType', 'alternate');

            teensy_ert.Prefs.setPref('ToolPath', altPath);
        end

%%
        function toolPath = getToolPath
            toolPath = teensy_ert.Prefs.getPref('ToolPath');
            % check validity of path (in case the folder got deleted between
            % after setToolPath and before getToolPath)
            if ~exist(toolPath,'dir')
                nl = newline;
                error('RTW:teensy_ert:invalidToolPath', ...
                      ['Teensy path is unspecified or invalid.' nl ...
                       'Specify a valid path using teensy_ert.Prefs.setToolPath, e.g.' nl ...
                       '   teensy_ert.Prefs.setToolPath(''.\tools'')']);
            end
        end

%%
        function corePath = getCorePath
            corePath = teensy_ert.Prefs.getPref('CorePath');
            % check validity of path (in case the folder got deleted between
            % after setToolPath and before getToolPath)
            if ~exist(corePath,'dir')
                nl = newline;
                error('RTW:teensy_ert:invalidCoolPath', ...
                      ['Teensy path is unspecified or invalid.' nl ...
                       'Specify a valid path using teensy_ert.Prefs.setCoolPath, e.g.' nl ...
                       '   teensy_ert.Prefs.setToolPath(''.\cores'')']);
            end
        end

    end
%%
    methods(Static,Access=private)

        function setPref(prefName, prefValue)
            prefGroup = 'TeensyGeneric';
            setpref(prefGroup, prefName, prefValue);
        end

        function prefValue = getPref(prefName)
            prefGroup = 'TeensyGeneric';
            if ispref(prefGroup,prefName)
                prefValue = getpref(prefGroup, prefName);
            else
                prefValue = '';
            end
        end
    end
end

% LocalWords:  USBSER
