function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to the generated makefiles.
%   For details refer to documentation on the rtwmakecfg API.

% makeInfo.sources = {'io_wrappers.cpp'}; NOT USED b/c using C++
% Add the folder where this file resides to the include path
blocks_inc_path = fileparts(mfilename('fullpath'));
makeInfo.includePath = {blocks_inc_path};
