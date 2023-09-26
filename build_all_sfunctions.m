% This script compiles all S-Functions

cd blocks
list = dir('*.c');
fprintf('\n\n');

for i = 1:numel(list)
    
    if ~exist([list(i).name(1:end-1) 'mexw64']) &&  ~exist([list(i).name(1:end-1) 'mexw32']),
        try
            fprintf('Building S-Function: %s\n', list(i).name);
            mex(list(i).name);
        catch
        end
    end
    
end

cd ..
