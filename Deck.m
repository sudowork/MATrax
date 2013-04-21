classdef Deck < handle
  properties (Access=private)
    ar
    file
    currentSample
    waveform
    callback
    latency
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
      cs = round(this.currentSample - this.latency * MATrax.AUD_SAMPLE_RATE);
      if cs <= 0
        cs = 1;
      end
    end

    function wf = getWaveform(this)
      wf = this.waveform;
    end

    function setCallback(this, cb)
      this.callback = cb;
    end

    function runCallback(this)
      if isa(this.callback, 'function_handle')
        this.callback();
      end
    end

    function deck = loadDeck(this, file, waveform)
      this.file = file;
      this.ar = dsp.AudioFileReader('Filename', file,...
                                    'SamplesPerFrame', MATrax.AUD_FRAME_SIZE);
      this.channels = this.ar.info.NumChannels;
      this.currentSample = 1;
      this.waveform = waveform;
      this.latency = round((1 + MATrax.AUD_FRAME_SIZE * 2 / MATrax.AUD_SAMPLE_RATE) * 1000) / 1000;
      % return ref to self
      deck = this;
    end

    %% Effects tuning
    function setGain(this, val)
      this.gain = val;
    end
  end
end

