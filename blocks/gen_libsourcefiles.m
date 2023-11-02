%% Generates "SLibAddToStaticSources" for the lib source files
clc
clear
close all

%% lib directory
libdir = "../teensy/avr/libraries/SdFat/src/";
suffix = "%<file>/../libraries/SdFat/src/";

%% Find all .c and .cpp files
fileext = [".c", ".cpp"];
libpath = char(java.io.File(fullfile(pwd, libdir)).getCanonicalPath());
sources = [];
for k = 1 : numel(fileext)
    files = dir(libdir + "**/*" + fileext(k));
    for l = 1 : numel(files)
        filename = [files(l).folder '/' files(l).name];
        filename = string(strrep(filename, [libpath '/'], ''));
        filename = string(strrep(filename, [libpath '\'], ''));
        sources = [sources; strrep(filename, '\', '/')];
    end
end

%% Print %<SLibAddToStaticSources(file)>
for k = 1 : numel(sources)
    fprintf("\t%%<SLibAddToStaticSources(""%s%s"")>\n", suffix, sources(k))
end