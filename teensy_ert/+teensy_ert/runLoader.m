function runLoader(hexFile)
%RUNLOADER downloads a program into flash using TeensyLoader

    toolPath = teensy_ert.Prefs.getToolPath;

    modelname = get_param(gcs,'Name');
    viewer = sldiagviewer.createStage('Uploading', 'ModelName', modelname);
    
    rebooter = fullfile(toolPath, 'teensy_reboot');
    loader = fullfile(toolPath, 'teensy_post_compile');
    
    [hexDir,hexFile]=fileparts(hexFile);
    if isempty(hexDir)
        hexDir = './';
    end
    loader_flags = sprintf("-file=%s -path=%s -tools=%s", hexFile, hexDir, toolPath); %-board teensy:avr:%s
    
    cmd = sprintf('%s %s', loader, loader_flags);
    
    sldiagviewer.reportInfo(cmd);
    [s,w] = system(cmd);        
    sldiagviewer.reportInfo(w);
    if (s~=0)
        sldiagviewer.reportWarning(w);
        clear viewer
        return;
    end
    sldiagviewer.reportInfo(w);
    
    cmd = sprintf('%s',rebooter);
    sldiagviewer.reportInfo(cmd);
    [s,w] = system(cmd);
    if (s~=0)
        sldiagviewer.reportWarning(w);
        clear viewer
        return;
    end
    sldiagviewer.reportInfo(w);

    sldiagviewer.reportInfo('Model uploaded.');

    clear viewer
end
