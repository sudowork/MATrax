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
  end

  methods
    %% MATraxEngine Constructor
    function this = MATraxEngine()
      this.songs = [];
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
                      'time', sprintf('%d:%d', round(duration/60), mod(duration, 60)),...
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
  end
end
