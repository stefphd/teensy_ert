function teensy_ert_select_callback_handler(hDlg, hSrc)
%TEENSY_ERT_SELECT_CALLBACK_HANDLER callback handler for teensy target

% The target is model reference compliant
slConfigUISetVal(hDlg, hSrc, 'ModelReferenceCompliant', 'on');
slConfigUISetEnabled(hDlg, hSrc, 'ModelReferenceCompliant', false);

% Hardware being used is the production hardware
slConfigUISetVal(hDlg, hSrc, 'ProdEqTarget', 'on');

% Setup C++ as default language
slConfigUISetVal(hDlg, hSrc, 'TargetLang', 'C++');
slConfigUISetVal(hDlg, hSrc, 'TargetLangStandard', 'C++11 (ISO)');

% Setup Code Interface Packaging as C++ Class
slConfigUISetVal(hDlg,hSrc,'CPPClassGenCompliant','on');
%slConfigUISetVal(hDlg, hSrc, 'CodeInterfacePackaging', 'C++ class'); %EXTMODE NOT WOKRING WITH C++ CLASS

% Setup the hardware configuration
slConfigUISetVal(hDlg, hSrc, 'ProdHWDeviceType', 'ARM Compatible->ARM Cortex-M');

% Set the TargetLibSuffix
slConfigUISetVal(hDlg, hSrc, 'TargetLibSuffix', '.a');

% For real-time builds, we must generate ert_main.c
slConfigUISetVal(hDlg, hSrc, 'ERTCustomFileTemplate', 'teensy_ert_file_process.tlc');

%slConfigUISetVal(hDlg, hSrc, 'ConcurrentExecutionCompliant', 'on');

slConfigUISetVal(hDlg, hSrc, 'ExtModeTransport', 1);

hSrc.getConfigSet.refreshDialog;

end
