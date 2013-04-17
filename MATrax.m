classdef MATrax < handle
% MATRAX Singleton for running MATrax application
%        A GUI-based DJ software, built in MATLAB. Acts as a front-end interface
%        for theh MATRAXENGINE.
%
% Author: Kevin Gao
% Usage: call `MATrax` to start application and initialize the GUI
% See Also: MATRAXENGINE
  %% Properties
  properties (Constant)
    GUI_NAME = 'MATrax';
    GUI_WIDTH = 800;
    GUI_HEIGHT = 600;
  end

  properties (Access=private)
    f       % figure containing GUI
    eng     % engine for actually processing music
    comps   % map of ui components
  end

  methods (Access=private)
    %% GUI initialization methods
    function initGUI(this)
      this.f = figure(...
                   'Name', MATrax.GUI_NAME,...
                   'NumberTitle', 'off',...
                   'MenuBar', 'none',...
                   'Toolbar', 'none',...
                   'Position', [0 0 MATrax.GUI_WIDTH MATrax.GUI_HEIGHT],...
                   'Visible', 'off');
      movegui(this.f, 'center');
    end

    function addMenus(this)
      mFile = uimenu(this.f, 'Label', 'File');
      uimenu(mFile, 'Label', 'Load Library',...
                    'Accelerator', 'L',...
                    'Callback', {@(src, event) this.reloadLibrary()});
      uimenu(mFile, 'Label', 'Quit',...
                    'Separator', 'on',...
                    'Callback', {@(src, event) this.quit()});
    end

    function addComponents(this)
      % Construct layout
      root = uiflowcontainer('v0', 'Units', 'norm', 'Position', [.01 .01 .98 .98]);
      set(root, 'FlowDirection', 'TopDown');
      this.comps('root') = root;
      % top
      top = uiflowcontainer('v0', 'parent', root, 'Units', 'norm', 'Position', [.01 .495 .98 .485]);
      deckA = uicontrol('parent', top, 'string', 'Deck A');
      deckB = uicontrol('parent', top, 'string', 'Deck B');
      this.comps('top') = top;
      this.comps('deckA') = deckA;
      this.comps('deckB') = deckB;
      % bottom
      bot = uiflowcontainer('v0', 'parent', root, 'Units', 'norm', 'Position', [.01 .01 .98 .485]);
      colNames = {'Title' 'Artist' 'Album' 'Time' 'Path'};
      songlib = uitable('parent', bot,...
              'ColumnName', colNames,...
              'ColumnWidth', 'auto',...
              'Data', {'' '' '' ''});
      this.comps('songlib') = songlib;
    end

    function initComponents(this)
    end

    function setupCallbacks(this)
    end

    function displayGUI(this)
      set(this.f, 'Visible', 'on');
      Console.log('MATrax GUI Initialized');
      uiwait(this.f);
    end

    %% GUI Callbacks
    function reloadLibrary(this)
      if this.eng.loadLibrary();
        % update GUI
      end
    end

    function quit(this)
      switch questdlg('Are you sure you want to quit?', 'Quit Dialog',...
                      'Yes',...
                      'No',...
                      'Yes');
        case 'Yes'
          delete(this.eng);
          close(this.f);
      end
    end
  end

  methods (Static)
    %% MATrax Constructor
    function obj = MATrax()
      obj.comps = containers.Map();
      % Create new MATraxEngine
      obj.eng = MATraxEngine();
      % Set up GUI
      initGUI(obj);
      addMenus(obj);
      addComponents(obj);
      initComponents(obj);
      setupCallbacks(obj);
      displayGUI(obj);
    end
  end
end
