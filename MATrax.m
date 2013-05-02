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
    % gui properties
    GUI_NAME = 'MATrax';
    GUI_WIDTH = 800;
    GUI_HEIGHT = 600;
    GUI_EQ_NAME = 'Equalizer';
    GUI_EQ_WIDTH = 400;
    GUI_EQ_HEIGHT = 300;
    % audio/playback properties
    AUD_QUEUE_DUR = 0.3;
    AUD_FRAME_SIZE = 2048;
    AUD_SAMPLE_RATE = 44.1e3;
  end

  properties (Access=private)
    f         % figure containing GUI
    eng       % engine for actually processing music
    eq        % gui for equalizer
    comps     % map of ui components
    idxTrack  % keep track of index
  end

  methods (Access=private)
    %% GUI initialization methods
    function initGUI(this)
      % main window
      this.f = figure(...
                   'Name', MATrax.GUI_NAME,...
                   'NumberTitle', 'off',...
                   'MenuBar', 'none',...
                   'Toolbar', 'none',...
                   'Position', [0 0 MATrax.GUI_WIDTH MATrax.GUI_HEIGHT],...
                   'Renderer', 'painters',...
                   'Visible', 'off');
      set(this.f, 'CloseRequestFcn', {@(src, event) this.destructor()});
      movegui(this.f, 'center');
      % equalizer window
      this.eq = figure(...
                   'Name', MATrax.GUI_EQ_NAME,...
                   'NumberTitle', 'off',...
                   'MenuBar', 'none',...
                   'Toolbar', 'none',...
                   'Position', [0 0 MATrax.GUI_EQ_WIDTH MATrax.GUI_EQ_HEIGHT],...
                   'Visible', 'off');
      set(this.eq, 'CloseRequestFcn', {@(src, event) this.hideEqualizer()});
      movegui(this.eq, 'center');
    end

    function addMenus(this)
      mFile = uimenu(this.f, 'Label', 'File');
      uimenu(mFile, 'Label', 'Load Library',...
                    'Accelerator', 'L',...
                    'Callback', {@(src, event) this.reloadLibrary()});
      uimenu(mFile, 'Label', 'Quit',...
                    'Separator', 'on',...
                    'Callback', {@(src, event) this.destructor()});
      mPreferences = uimenu(this.f, 'Label', 'Preferences');
      uimenu(mPreferences, 'Label', 'Equalizer',...
                           'Accelerator', 'E',...
                           'Callback', {@(src, event) this.displayEqualizer()});
    end

    function setLayout(this)
      % main window layout
      root = uigridcontainer('v0', this.f, 'Units', 'norm', 'Position', [.01 .01 .98 .98]);
      set(root, 'GridSize', [3, 1], 'VerticalWeight', [3 1 3]);

      top = uiflowcontainer('v0', 'Parent', root, 'Units', 'norm', 'Position', [.01 .59 .98 .40]);

      mid = uiflowcontainer('v0', 'Parent', root, 'Units', 'norm', 'Position', [.01 .42 .98 .16]);
      ctlA = uiflowcontainer('v0', 'Parent', mid', 'Units', 'norm', 'Position', [.01 .01 .32 .98]);
      ctlMid = uiflowcontainer('v0', 'Parent', mid', 'Units', 'norm', 'Position', [.34 .01 .32 .98]);
      ctlB = uiflowcontainer('v0', 'Parent', mid', 'Units', 'norm', 'Position', [.67 .01 .32 .98]);

      bot = uiflowcontainer('v0', 'Parent', root, 'Units', 'norm', 'Position', [.01 .01 .98 .40]);

      this.comps('top') = top;
      this.comps('ctlA') = ctlA;
      this.comps('ctlMid') = ctlMid;
      this.comps('ctlB') = ctlB;
      this.comps('bot') = bot;

      % equalizer layout
      eqRoot = uigridcontainer('v0', this.eq, 'Units', 'norm', 'Position', [.01 .01 .98 .98]);
      set(eqRoot, 'GridSize', [2, 1], 'VerticalWeight', [8 2]);
      eqTop = uiflowcontainer('v0', 'Parent', eqRoot, 'Units', 'norm', 'Position', [.01 .01 .98 .98]);
      eqBot = uiflowcontainer('v0', 'Parent', eqRoot, 'Units', 'norm', 'Position', [.01 .01 .98 .98]);
      this.comps('eqTop') = eqTop;
      this.comps('eqBot') = eqBot;
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
      ctlMid = c('ctlMid');
      ctlB = c('ctlB');
      deckA.toggle = uicontrol('parent', ctlA, 'Style', 'togglebutton', 'string', 'Play/Pause A', 'Position', [0 0 60 20]);
      deckA.load = uicontrol('parent', ctlA, 'string', 'Move to Deck A', 'Position', [0 0 60 20], 'UserData', 'A');
      this.comps('crossfader') = uicontrol('parent', ctlMid, 'Style', 'slider', 'Min', 0, 'Max', 1, 'Value', 0.5);
      deckB.load = uicontrol('parent', ctlB, 'string', 'Move to Deck B', 'Position', [0 0 60 20], 'UserData', 'B');
      deckB.toggle = uicontrol('parent', ctlB, 'Style', 'togglebutton', 'string', 'Play/Pause B', 'Position', [0 0 60 20]);

      % bot (library))
      bot = c('bot');
      colNames = {'Title' 'Artist' 'Time' 'Bitrate' 'Path'};
      songlib = uitable('parent', bot,...
              'ColumnName', colNames,...
              'ColumnWidth', 'auto');

      this.comps('deckA') = deckA;
      this.comps('deckB') = deckB;
      this.comps('songlib') = songlib;

      % equalizer components
      eqTop = c('eqTop');
      eqBot = c('eqBot');
      eqCtl.bass = uicontrol('Parent', eqTop, 'Style', 'slider', 'Min', 0, 'Max', 2, 'Value', 1);
      eqCtl.mid = uicontrol('Parent', eqTop, 'Style', 'slider', 'Min', 0, 'Max', 2, 'Value', 1);
      eqCtl.treble = uicontrol('Parent', eqTop, 'Style', 'slider', 'Min', 0, 'Max', 2, 'Value', 1);
      eqCtl.toggle = uicontrol('Parent', eqBot, 'Style', 'togglebutton', 'String', 'Enable Equalizer');
      this.comps('eqCtl') = eqCtl;
    end

    function setupCallbacks(this)
      c = this.comps;
      % deck and crossfader control callbacks
      deckA = c('deckA');
      deckB = c('deckB');
      set(deckA.toggle, 'Callback', {@(src,~) this.eng.toggleDeck('A', get(src, 'Value'))})
      set(deckB.toggle, 'Callback', {@(src,~) this.eng.toggleDeck('B', get(src, 'Value'))})
      set(deckA.load, 'Callback', {@(src,~) this.loadDeck(src); });
      set(deckB.load, 'Callback', {@(src,~) this.loadDeck(src); });
      addlistener(c('crossfader'), 'Value', 'PostSet', @(~,event) this.eng.crossfade(event.newValue));
      % equalizer callbacks
      % TODO: fill these in with real implementations
      addlistener(c('eqCtl').bass, 'Value', 'PostSet', @(~,event) this.eng.setBassGain(event.newValue));
      addlistener(c('eqCtl').mid, 'Value', 'PostSet', @(~,event) this.eng.setMidGain(event.newValue));
      addlistener(c('eqCtl').treble, 'Value', 'PostSet', @(~,event) this.eng.setTrebleGain(event.newValue));
      set(c('eqCtl').toggle, 'Callback', @(src,~) this.eng.setEqEnable(get(src, 'Value')));
    end

    function displayGUI(this)
      set(this.f, 'Visible', 'on');
      Console.log('MATrax GUI Initialized');
    end

    function modJavaObjs(this)
    % NOTE: Java objects must be modified after GUI is shown
      c = this.comps;
      % configure uitable for row-wise selection
      songlib = c('songlib');
      jSonglib = findjobj(songlib);
      jTable = jSonglib.getViewport.getView;
      jTable.setNonContiguousCellSelection(false);
      jTable.setColumnSelectionAllowed(false);
      jTable.setRowSelectionAllowed(true);
      jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
      % NOTE: Modifying table above causes normal CellSelectionCallback to break,
      %       so we directly change the MousePressedCallback
      set(jTable, 'MousePressedCallback', {@(~, ~) this.updateSelectedTrack(jTable)});
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
          caSongs = struct2cell(s);
          songData(i,:) = caSongs(1:numCols);
        end
        set(songlib, 'Data', songData);
      end
    end

    function updateSelectedTrack(this, table)
      this.idxTrack = table.getSelectedRow + 1;
    end

    function loadDeck(this, src)
      deck = get(src, 'UserData');
      if length(this.eng.songs) >= this.idxTrack
        song = this.eng.songs(this.idxTrack);
        Console.log(sprintf('Moving song "%s" to Deck %s', song.title, deck));
        wave = this.eng.loadDeck(deck, this.idxTrack);
        waveform = this.comps(['deck' deck]).plot;
        initWaveform(waveform, wave);
      end
    end

    function displayEqualizer(this)
      set(this.eq, 'Visible', 'on');
    end

    function hideEqualizer(this)
      set(this.eq, 'Visible', 'off');
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
      obj.modJavaObjs;

      % start engine
      obj.eng.start();

      % wait for main window to close
      uiwait(obj.f);
    end
  end
end
