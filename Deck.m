classdef Deck < handle
  properties (Access=private)
    ar
    file
    currentSample
    isPlaying = false

    % derived
    channels = 2

    % tunable effects
    gain = 1
  end

  methods
    function obj = Deck(varargin)
      if (nargin > 0)
        obj.loadDeck(varargin{1});
      end
    end

    function delete(this)
      this.release;
    end

    %% Controls
    function audio = step(this)
      if this.isPlaying && isobject(this.ar) && ~this.ar.isDone
        % get initial audio and apply effects
        tempAudio = this.ar.step;
        tempAudio = tempAudio .* this.gain;

        audio = tempAudio;

        % advance current sample
        this.currentSample = this.currentSample + MATrax.AUD_FRAME_SIZE;
      else
        % if not playing or done playing, return zero-matrix
        audio = zeros(MATrax.AUD_FRAME_SIZE, this.channels);
      end
    end

    function play(this)
      this.isPlaying = true;
    end

    function pause(this)
      this.isPlaying = false;
    end

    function release(this)
      if isobject(this.ar)
        this.ar.release;
      end
    end

    function cs = getCurrentSample(this)
      cs = this.currentSample;
    end

    function deck = loadDeck(this, file)
      this.file = file;
      this.ar = dsp.AudioFileReader('Filename', file,...
                                    'SamplesPerFrame', MATrax.AUD_FRAME_SIZE);
      this.channels = this.ar.info.NumChannels;
      this.currentSample = 0;
      % return ref to self
      deck = this;
    end

    %% Effects tuning
    function setGain(this, val)
      this.gain = val;
    end
  end
end

