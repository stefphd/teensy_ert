function upload( modelName )
%FLASH - target flashing

rtw = RTW.GetBuildDir(modelName);
file = fullfile(rtw.BuildDirectory, [ modelName, '.hex']);

if exist(file, 'file')
    teensy_ert.runLoader(file);
else
    msgbox(['File ', file ' not found'], 'Target flasing', 'error');
end

end

