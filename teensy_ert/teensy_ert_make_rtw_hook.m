function teensy_ert_make_rtw_hook(hookMethod, modelName, ~, ~, ~, ~)
% TEENSY_MAKE_RTW_HOOK

  switch hookMethod
   case 'error'
    % Called if an error occurs anywhere during the build.  If no error occurs
    % during the build, then this hook will not be called.  Valid arguments
    % at this stage are hookMethod and modelName. This enables cleaning up
    % any static or global data used by this hook file.
    disp(['### Build procedure for model: ''' modelName...
          ''' aborted due to an error.']);

   case 'entrydo'
    % Called at start of code generation process (before anything happens.)
    % Valid arguments at this stage are hookMethod, modelName, and buildArgs.
    i_teensy_setup(modelName);

   case 'before_tlc'
    % Called just prior to invoking TLC Compiler (actual code generation.)
    % Valid arguments at this stage are hookMethod, modelName, and
    % buildArgs

   case 'after_tlc'
    % Called just after to invoking TLC Compiler (actual code generation.)
    % Valid arguments at this stage are hookMethod, modelName, and
    % buildArgs

    % Safely check if model contains property 'UseRTOS'
    param = get_param(modelName, 'ObjectParameters');
    if isfield(param,'UseRTOS')
        rtos = strcmp(get_param(gcs,'UseRTOS'),'off');
    else
        rtos = false;
    end
    
    if ~rtos    % Multitasking is possible with RTOS only
        % This check must be done after the model has been compiled otherwise
        % sample time may not be valid
        i_check_tasking_mode(modelName)
    end

   case 'before_make'
    % Called after code generation is complete, and just prior to kicking
    % off make process (assuming code generation only is not selected.)  All
    % arguments are valid at this stage.
    if ( strcmp(get_param(gcs,'ParallelExecution'),'on') )
        args = get_param(modelName, 'RTWBuildArgs');
        args = [args, ' -j4'];  % run makefile in 4 threads
        set_param(modelName, 'RTWBuildArgs', args);
    end     
    i_write_teensy_makefiles(modelName);

   case 'after_make'
       %empty
   case 'exit'
    % Called at the end of the build process.  All arguments are valid at this
    % stage.
    rtw = RTW.GetBuildDir(modelName);
    if i_isPilSim
        fileDis = fullfile(rtw.BuildDirectory, 'pil', 'disassembly.txt');
        fileMap = fullfile(rtw.BuildDirectory, 'pil', 'mapFile.map');
    else
        fileDis = fullfile(rtw.BuildDirectory, 'disassembly.txt');
        fileMap = fullfile(rtw.BuildDirectory, 'mapFile.map');
    end
    fprintf('### Disassembling project code into <a href="matlab:edit %s">disassembly.txt</a>\n', fileDis);
    fprintf('### Linker Map file <a href="matlab:edit %s">mapFile.map</a>\n', fileMap);
    
    disp(['### Successful completion of build procedure for model: ', ...
        modelName]);
  end
end

function i_teensy_setup(modelName)
    if ~i_isPilSim
        % Check that the the main function will be generated using the correct
        % .tlc file
        if bdIsLoaded(modelName) && ~i_isModelReferenceBuild(modelName)
            requiredSetting = 'teensy_ert_file_process.tlc';
            assert(strcmp(get_param(modelName, 'ERTCustomFileTemplate'), ...
                          requiredSetting),...
                   'The model %s must have ERTCustomFileTemplate set to %s.',...
                   modelName, requiredSetting);
        end
    end

    % Check for C_INCLUDE_PATH
    if ~isempty(getenv('C_INCLUDE_PATH'))
        error('RTW:teensy_ert:nonEmptyCIncludePath',...
              ['The environment variable C_INCLUDE_PATH is set. '...
               'This may conflict with the gcc for ARM. You should '...
               'clear this environment variable, e.g. by running '...
               'setenv(''C_INCLUDE_PATH'','''') from the MATLAB command '...
               'window.']);
    end

    disp(['### Starting Teensy build procedure for ', ...
          'model: ',modelName]);

    if ~isempty(strfind(pwd,' ')) || ~isempty(strfind(pwd,'&'))
        error('RTW:teensy_ert:pwdHasSpaces',...
              ['The current working folder, %s, contains either a space or ' ...
               'ampersand character. This is '...
               'not supported. You must change the current working folder to '...
               'a path that does not contain either of these characters.'], pwd);
    end
end

function i_check_tasking_mode(modelName)
    % No support for multi tasking mode
    if ~i_isModelReferenceBuild(modelName)  &&  ~i_isPilSim
        solverMode = get_param(modelName,'SolverMode');
        st = get_param(modelName,'SampleTimes');
        if length(st)>1 && ~strcmp(solverMode,'SingleTasking')
            error('RTW:teensy_ert:noMultiTaskingSupport',...
                  ['The multi-tasking solver mode is not supported for the real-time '...
                   'Teensy target. '...
                   'In Simulation > Configuration Parameters > Solver you must select '...
                   '"SingleTasking" from the pulldown "Tasking mode for periodic sample '...
                   'times".']);
        end
    end
end

function i_write_teensy_makefiles(modelname)
    lCodeGenFolder = Simulink.fileGenControl('getConfig').CodeGenFolder;
    buildAreaDstFolder = fullfile(lCodeGenFolder, 'slprj');
    % Copy the arduino version of target_tools.mk into the build area
    tgtToolsFile = 'target_tools.mk';
    target_tools_folder = fileparts(mfilename('fullpath'));
    srcFile = fullfile(target_tools_folder, tgtToolsFile);
    dstFile = fullfile(buildAreaDstFolder, tgtToolsFile);
    copyfile(srcFile, dstFile, 'f');
    % Make sure the file is not read-only
    fileattrib(dstFile, '+w');

    core_path = RTW.transformPaths(teensy_ert.Prefs.getCorePath);
    tool_path = RTW.transformPaths(teensy_ert.Prefs.getToolPath);
    % gmake needs forward slash as path separator
    core_path = strrep(core_path, '\', '/');
    tool_path = strrep(tool_path, '\', '/');

    % Write out the makefile
    makefileName = fullfile(buildAreaDstFolder, 'teensy_prefs.mk');
    fid = fopen(makefileName,'w');
    teensyboard = get_param(modelname, 'TeensyBoard');
    switch teensyboard
        case 'Teensy 4.1'
            mculd = 'imxrt1062_t41';
            core = 'teensy4';
            cpufreq = 600e6;
            mcu_def = 'ARDUINO_TEENSY41';
            mcu = upper('imxrt1062');
            cpuarch = 'cortex-m7';
            cpuflags = '-mfloat-abi=hard -mfpu=fpv5-d16 -mthumb ';
            cpuldflags = '-lm -lstdc++ -larm_cortexM7lfsp_math';
        case 'Teensy 4.0'
            mculd = 'imxrt1062';
            core = 'teensy4';
            cpufreq = 600e6;
            mcu_def = 'ARDUINO_TEENSY40';
            mcu = upper('imxrt1062');
            cpuarch = 'cortex-m7';
            cpuflags = '-mfloat-abi=hard -mfpu=fpv5-d16 -mthumb';
            cpuldflags = '-lm -lstdc++ -larm_cortexM7lfsp_math';
        case 'Teensy 3.6'
            mculd = 'mk66fx1m0';
            core = 'teensy3';
            cpufreq = 48000000;
            mcu_def = ['__' upper('mk66fx1m0') '__'];
            mcu = upper('mk66fx1m0');
            cpuarch = 'cortex-m4';
            cpuflags = '-mthumb';
            cpuldflags = '-lm --specs=nano.specs -mthumb';
        case 'Teensy 3.5'
            mculd = 'mk66fx1m0';
            core = 'teensy3';
            cpufreq = 48000000;
            mcu_def = ['__' upper('mk66fx1m0') '__'];
            mcu = upper('mk66fx1m0');
            cpuarch = 'cortex-m4';
            cpuflags = '-mthumb';
            cpuldflags = '-lm --specs=nano.specs -mthumb';
        case 'Teensy 3.2'
            mculd = 'mk20dx256';
            core = 'teensy3';
            cpufreq = 48000000;
            mcu_def = ['__' upper('mk20dx256') '__'];
            mcu = upper('mk20dx256');
            cpuarch = 'cortex-m4';
            cpuflags = '-mthumb';
            cpuldflags = '-lm --specs=nano.specs -mthumb';
        otherwise
            error('Invalid Board Selected.')
    end
    fwrite(fid, sprintf('%s\n\n', '# Teensy build preferences'));
    fwrite(fid, sprintf('# %s\n', teensyboard));
    fwrite(fid, sprintf('CORE_ROOT = %s\n', core_path));
    fwrite(fid, sprintf('TOOL_ROOT = %s\n', tool_path));
    fwrite(fid, sprintf('TEENSY_SL = %s\n',  strrep(fileparts(mfilename('fullpath')),'\', '/')));
    fwrite(fid, sprintf('MCU_LD = %s.ld\n', mculd));
    fwrite(fid, sprintf('CORE = %s\n', core));
    fwrite(fid, sprintf('F_CPU = %d\n', cpufreq));
    fwrite(fid, sprintf('MCU_DEF = %s\n', mcu_def));
    fwrite(fid, sprintf('MCU = %s\n', mcu));
    fwrite(fid, sprintf('CPUARCH = %s\n', cpuarch));
    fwrite(fid, sprintf('CPUFLAGS = %s\n', cpuflags));
    fwrite(fid, sprintf('CPULDFLAGS = %s\n', cpuldflags));
    fclose(fid);
end

function i_download(modelName)
    hexFile = fullfile('.',[modelName '.hex']);
    teensy_ert.runLoader(hexFile);
end

function isPilSim = i_isPilSim
    s = dbstack;
    isPilSim = false;
    for i=1:length(s)
        if strfind(s(i).name,'build_pil_target')
            isPilSim=true;
            break;
        end
    end
end

function isMdlRefBuild = i_isModelReferenceBuild(modelName)
    mdlRefTargetType = get_param(modelName, 'ModelReferenceTargetType');
    isMdlRefBuild = ~strcmp(mdlRefTargetType, 'NONE');
end
