classdef MATrax < handle
% MATRAX Singleton for running MATrax application
%        A GUI-based DJ software, built in MATLAB. Acts as a front-end interface
%        for theh MATRAXENGINE.
%
% Author: Kevin Gao
% Usage: call `MATrax` to start application and initialize the GUI
% See Also: MATRAXENGINE, INITWAVEFORM
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

    function setLayout(this)
      root = uigridcontainer('v0', this.f, 'Units', 'norm', 'Position', [.01 .01 .98 .98]);
      set(root, 'GridSize', [3, 1], 'VerticalWeight', [3 1 3]);

      top = uiflowcontainer('v0', 'parent', root, 'Units', 'norm', 'Position', [.01 .59 .98 .40]);

      mid = uiflowcontainer('v0', 'parent', root, 'Units', 'norm', 'Position', [.01 .42 .98 .16]);
      ctlA = uiflowcontainer('v0', 'parent', mid', 'Units', 'norm', 'Position', [.01 .01 .59 .98]);
      ctlB = uiflowcontainer('v0', 'parent', mid', 'Units', 'norm', 'Position', [.01 .01 .59 .98]);

      bot = uiflowcontainer('v0', 'parent', root, 'Units', 'norm', 'Position', [.01 .01 .98 .40]);

      this.comps('root') = root;
      this.comps('top') = top;
      this.comps('ctlA') = ctlA;
      this.comps('ctlB') = ctlB;
      this.comps('bot') = bot;
    end

    function addComponents(this)
      c = this.comps;
      % top (waveforms + effects)
      top = c('top');
      deckA.plot = axes('parent', top);
      initWaveform(deckA.plot);
      deckB.plot = axes('parent', top);
      initWaveform(deckB.plot);

      % mid (controls)
      ctlA = c('ctlA');
      ctlB = c('ctlB');
      deckA.toggle = uicontrol('parent', ctlA, 'Style', 'togglebutton', 'string', 'Play/Pause A', 'Position', [0 0 60 20]);
      deckA.load = uicontrol('parent', ctlA, 'string', 'Move to Deck A', 'Position', [0 0 60 20]);
      deckB.load = uicontrol('parent', ctlB, 'string', 'Move to Deck B', 'Position', [0 0 60 20]);
      deckB.toggle = uicontrol('parent', ctlB, 'Style', 'togglebutton', 'string', 'Play/Pause B', 'Position', [0 0 60 20]);

      % bot (library))
      bot = c('bot');
      colNames = {'Title' 'Artist' 'Time' 'Bitrate' 'Path'};
      songlib = uitable('parent', bot,...
              'ColumnName', colNames,...
              'ColumnWidth', 'auto',...
              'Data', {'' '' '' ''});

      this.comps('deckA') = deckA;
      this.comps('deckB') = deckB;
      this.comps('songlib') = songlib;
    end

    function setupCallbacks(this)
      c = this.comps;
      % TODO: refactor all the deck A/B stuff into one common bootstrapping process
      deckA = c('deckA');
      deckB = c('deckB');
      set(deckA.toggle, 'Callback', {@(src, event) this.eng.toggleDeckA(get(src, 'Value'))})
      set(deckB.toggle, 'Callback', {@(src, event) this.eng.toggleDeckB(get(src, 'Value'))})
    end

    function displayGUI(this)
      set(this.f, 'Visible', 'on');
      Console.log('MATrax GUI Initialized');
      uiwait(this.f);
    end

    %% GUI Callbacks
    function reloadLibrary(this)
      if this.eng.loadLibrary();
        % on successful load, convert songs to cell array and repopulate song
        % uitable with new data
        songlib = this.comps('songlib');
        songs = this.eng.songs;
        numCols = length(get(songlib, 'ColumnName'));
        songData = cell(length(songs), numCols);
        for i = 1:length(songs)
          s = songs(i);
          songData(i,:) = struct2cell(s);
        end
        set(songlib, 'Data', songData);
        set(songlib, 'ColumnWidth', calcColWidth(songData, [128 64 64 32 32]));

        % TODO: remove this (just for testing)
        this.eng.loadDeckA(songs(1).file);
        this.eng.loadDeckB(songs(2).file);
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
      % Add path if not stand-alone
      if ~isdeployed
        addpath(fullfile(pwd, 'util'));
      end

      % Create new MATraxEngine
      obj.eng = MATraxEngine();
      % Init map for ui components
      obj.comps = containers.Map();

      % Set up GUI
      obj.initGUI;
      obj.addMenus;
      obj.setLayout;
      obj.addComponents;
      obj.setupCallbacks;
      obj.displayGUI;
    end
  end
end
