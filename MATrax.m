classdef MATrax < handle
% MATRAX Singleton for running MATrax application
%        A GUI-based DJ software, built in MATLAB.
%
% Author: Kevin Gao
% Usage: call `MATrax` to start application and initialize the GUI
% See Also: MATRAXGUI
  properties (Constant)
    GUI_NAME = 'MATrax';
    GUI_WIDTH = 800;
    GUI_HEIGHT = 600;
  end % constants

  properties (Access=private)
    f   % figure containing GUI
  end % private instance variables

  methods (Access=private)
    function initGUI(this)
      this.f = figure(...
                   'Name', MATrax.GUI_NAME,...
                   'MenuBar', 'none',...
                   'Toolbar', 'none',...
                   'Position', [0,0,MATrax.GUI_WIDTH,MATrax.GUI_HEIGHT],...
                   'Visible', 'off');
      movegui(this.f, 'center');
    end % initGUI

    function addComponents(this)
    end % addComponents

    function initComponents(this)
    end % initComponents

    function setupCallbacks(this)
    end % setupCallbacks

    function displayGUI(this)
      set(this.f, 'Visible', 'on');
      uiwait(this.f);
    end % displayGUI
  end % private methods

  methods (Static)
    function obj = MATrax()
      initGUI(obj);
      addComponents(obj);
      initComponents(obj);
      setupCallbacks(obj);
      displayGUI(obj);
    end % MATrax
  end
end
