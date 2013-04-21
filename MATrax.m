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
      set(this.f, 'CloseRequestFcn', {@(src, event) this.destructor()});
      movegui(this.f, 'center');
    end

    function addMenus(this)
      mFile = uimenu(this.f, 'Label', 'File');
      uimenu(mFile, 'Label', 'Load Library',...
                    'Accelerator', 'L',...
                    'Callback', {@(src, event) this.reloadLibrary()});
      uimenu(mFile, 'Label', 'Quit',...
                    'Separator', 'on',...
                    'Callback', {@(src, event) this.destructor()});
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
      deckB.plot = axes('parent', top);
      initWaveform(deckA.plot);
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
      % TODO: refactor all the deck A/B stuff into one common bootstrapping process
      function tempA(~,~)
        temp = this.eng.loadDeckA('./library/01.mp3');
        initWaveform(deckA.plot, temp);
      end
      function tempB(~,~)
        temp = this.eng.loadDeckB('./library/02.mp3');
        initWaveform(deckB.plot, temp);
      end

      c = this.comps;
      deckA = c('deckA');
      deckB = c('deckB');
      set(deckA.toggle, 'Callback', {@(src, event) this.eng.toggleDeckA(get(src, 'Value'))})
      set(deckB.toggle, 'Callback', {@(src, event) this.eng.toggleDeckB(get(src, 'Value'))})
      set(deckA.load, 'Callback', @tempA);
      set(deckB.load, 'Callback', @tempB);
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
      end
    end

    function destructor(this)
      switch questdlg('Are you sure you want to quit?', 'Quit Dialog',...
                      'Yes',...
                      'No',...
                      'Yes');
        case 'Yes'
          delete(this.eng);
          delete(this.f);
      end
    end
  end

  methods (Static)
    %% MATrax Constructor
    function obj = MATrax()
      % Add path if not stand-alone
      if ~isdeployed
        addpath(fullfile(pwd, 'lib'));
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
