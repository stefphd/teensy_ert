classdef Timer < rtw.connectivity.Timer
% TIMER is a Timer subclass to get timing information for the application 
% running on the Teensy target
%
%   See also RTW.CONNECTIVITY.TIMER

    methods

        function this = Timer
            
            % Configure data type returned by timer reads
            this.setTimerDataType('uint32');

            % The micros() function returns microseconds
            ticksPerSecond = 1e6; 
            this.setTicksPerSecond(ticksPerSecond);

            % The timer counts upwards
            this.setCountDirection('up');

            % Configure source files required to access the timer
            filepath = fileparts(fileparts(mfilename('fullpath')));
            headerFile = fullfile(filepath, 'timer.h');                     
            this.setHeaderFile(headerFile);

            % we don't need any extra C-file for timer
            % this.setSourceFile(timerSourceFile);
            
            % Configure the expression used to read the timer
            readTimerExpression = 'micros()';
            this.setReadTimerExpression(readTimerExpression);
            
        end  
    end
end

