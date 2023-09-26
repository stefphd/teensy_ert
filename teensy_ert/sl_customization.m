function sl_customization(cm)
% SL_CUSTOMIZATION for teensy_ert connectivity config

cm.registerTargetInfo(@loc_createSerialConfig);
cm.ExtModeTransports.add('teensy_ert.tlc', 'tcpip',  'ext_comm', 'Level1'); %NOT IMPLEMENTED
cm.ExtModeTransports.add('teensy_ert.tlc', 'serial', 'ext_serial_win32_comm', 'Level1');

% local function
function config = loc_createSerialConfig

config = rtw.connectivity.ConfigRegistry;
config.ConfigName = 'Teensy connectivity config using serial';
config.ConfigClass = 'teensy_ert.ConnectivityConfig';

% matching system target file
config.SystemTargetFile = {'teensy_ert.tlc'};

% match template makefile
config.TemplateMakefile = {'teensy_ert.tmf'};

% match any hardware implementation
config.TargetHWDeviceType = {};
