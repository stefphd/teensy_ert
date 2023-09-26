function teensy_ert_apply_callback_handler(hDlg, hSrc)
%TEENSY_ERT_APPLY_CALLBACK_HANDLE

teensyextport = hSrc.TeensyExtPort;
port = sscanf(teensyextport,"COM%d");
teensyextverb = strcmp(hSrc.TeensyExtVerb, 'on');
mexargs = sprintf('%d %d %d', teensyextverb, port, 4000000);
slConfigUISetVal(hDlg, hSrc, 'ExtModeTransport', 1);
slConfigUISetVal(hDlg, hSrc, 'ExtModeMexArgs', mexargs)

hSrc.getConfigSet.refreshDialog;

end
