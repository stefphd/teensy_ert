function makeCmd = teensy_ert_wrap_make_cmd_hook(args)
%MAKE_TEENSY wrap_make_cmd hook

if ispc
    makeCmd = args.makeCmd;
    teensy_path = teensy_ert.Prefs.getToolPath;
    args.make = strrep(args.make,'%TEENSY_ROOT%',...
        teensy_path);
    args.makeCmd = strrep(makeCmd,'%TEENSY_ROOT%',...
        teensy_path);

    makeCmd = setup_for_default(args);
else
    error('Only Windows supported.')
end
