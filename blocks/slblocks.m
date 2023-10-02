function blkStruct = slblocks
blkStruct.Name = 'Custom C/C++ Target - Teensy';    %Display name
blkStruct.OpenFcn = 'teensy_lib';          %Library name
blkStruct.MaskDisplay = '';
Browser(1).Library = 'teensy_lib';         %Library name

%   Copyright 2012-2014 The MathWorks, Inc.

Browser(1).Name='Custom C/C++ Target - Teensy';     %Display name
blkStruct.Browser = Browser;
