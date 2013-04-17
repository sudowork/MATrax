classdef MATraxEngine < handle
% MATRAXENGINE Engine for MATRAX DJ platform
%              Maintains state for the MATRAX application and acts as the
%              overarching music composer.
%
% Author: Kevin Gao
% Usage: Construct a new engine using `MATraxEngine(GUI_HANDLE)`
% See Also: MATRAX
  properties (Access=private)
    gui     % reference to GUI front-end
    libDir  % path to music library
  end
  properties (SetAccess='private', GetAccess='public')
    songs   % dynamically sized array containing paths to songs
    deckA   % in the form of {data: [Y, FS], player: audioplayer}
    deckB   % in the form of {data: [Y, FS], player: audioplayer}
  end

  methods
    %% MATraxEngine Constructor
    function this = MATraxEngine()
      this.songs = [];
      this.deckA = false;
      this.deckB = false;
      Console.log('MATrax Engine Loaded');
    end

    %% Callback methods
    function success = loadLibrary(this)
      % transform file metadata to song metadata
      function song = fileToSong(file)
        path = fullfile(this.libDir, file.name);
        metadata = audioinfo(path);
        duration = round(metadata.Duration);
        % TODO: Actually process song metadata
        song = struct('title', metadata.Title,...
                      'artist', metadata.Artist,...
                      'time', sprintf('%d:%02d', round(duration/60), mod(duration, 60)),...
                      'bitrate', metadata.BitRate,...
                      'file', metadata.Filename);
      end

      if isdeployed
        % TODO: test USERPROFILE for windows
        homeVars = {'HOME' 'USERPROFILE'};
        defDir = getenv(homeVars{ispc + 1});
      else
        defDir = pwd;
      end
      userDir = uigetdir(defDir, 'Open Directory Containing Tracks');
      % if valid directory, process and load songs
      if ischar(userDir) && exist(userDir, 'dir')
        this.libDir = userDir;
        % TODO: recursive search of library directory and do more than just
        %       searching by extension
        files = dir(fullfile(this.libDir, '*.mp3'));
        Console.log(sprintf('Library loaded: %s', this.libDir));
        Console.log(sprintf('\t%d tracks loaded', length(files)));
        this.songs = arrayfun(@fileToSong, files);
        success = true;
      else
        success = false;
      end
    end

    function deck = loadDeckA(this, file)
      deck = MATraxEngine.loadDeckFromFile(file);
      this.deckA = deck;
    end

    function deck = loadDeckB(this, file)
      deck = MATraxEngine.loadDeckFromFile(file);
      this.deckB = deck;
    end

    function toggleDeckA(this, currstate)
      MATraxEngine.togglePlayer(this.deckA.player, currstate);
    end

    function toggleDeckB(this, currstate)
      MATraxEngine.togglePlayer(this.deckB.player, currstate);
    end
  end

  methods (Static)
    function deck = loadDeckFromFile(file)
      deck.file = file;
      [deck.Y, deck.Fs] = audioread(file);
      deck.player = audioplayer(deck.Y, deck.Fs);
    end

    function togglePlayer(player, currstate)
      if currstate
        if get(player, 'CurrentSample')
          player.resume
        else
          player.play;
        end
        Console.log('Playing');
      else
        player.pause;
        Console.log('Paused');
      end
    end
  end
end
