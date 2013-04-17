classdef Console < handle
% CONSOLE Utility class to centralize logging
%         Meant to replace writing to the command window. Centralized logging
%         allows for the display logic to be refactored easily.
%
% Author: Kevin Gao
% Usage: call `MATrax` to start application and initialize the GUI
% See Also: MATRAXENGINE

  methods (Static)
    function log(msg)
      % TODO: Create separate GUI window to log
      disp(msg);
    end
  end
end
