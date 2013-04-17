classdef MATraxEngine < handle
% MATRAXENGINE Engine for MATRAX DJ platform
%              Maintains state for the MATRAX application and acts as the
%              overarching music composer.
%
% Author: Kevin Gao
% Usage: call `MATrax` to start application and initialize the GUI
% See Also: MATRAX
  properties (Access=private)
    gui     % reference to GUI front-end
    libDir  % path to music library
  end

  methods
    %% MATraxEngine Constructor
    function this = MATraxEngine(gui)
      this.gui = gui;
      disp('MATrax Engine Loaded');
    end

    %% Callback methods
    function loadLibrary(this)
      this.libDir = uigetdir(pwd(), 'Open Directory Containing Tracks');
      if ischar(this.libDir) && exist(this.libDir, 'dir')
        fprintf('Library loaded: %s\n', this.libDir);
      end
    end
  end
end
