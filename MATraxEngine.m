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
    deckA   % Deck A
    deckB   % Deck B
    mixer   % mixer that mixes two decks
  end

  methods
    %% MATraxEngine Constructor
    function this = MATraxEngine()
      this.deckA = Deck();
      this.deckB = Deck();
      this.mixer = Mixer(this.deckA, this.deckB);
      Console.log('MATrax Engine Loaded');
    end

    % destructor to handle closing resources :)
    function delete(this)
      for deck = [this.deckA this.deckB]
        delete(deck);
      end
    end

    function start(this)
      this.mixer.play();
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

    function deck = loadDeck(this, deckLetter, file)
      deck = this.(['deck' deckLetter]).loadDeck(file);
    end

    function toggleDeck(this, deckLetter, currstate)
      MATraxEngine.togglePlayer(this.(['deck' deckLetter]), currstate);
    end

    function crossfade(this, bal)
      disp(bal);
      this.mixer.setBalance(bal);
    end
  end

  methods (Static)
    function togglePlayer(deck, currstate)
      if currstate
        deck.play;
        Console.log('Playing');
      else
        deck.pause;
        Console.log('Paused');
      end
    end
  end
end
