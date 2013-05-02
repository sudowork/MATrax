classdef Mixer < handle
  properties (Access=private)
    arA
    arB
    ap
    t_played
    t_clock
    playbackTimer
    cb_last
    cb_interval = .1
    eq
    % tunable
    isPlaying = false
    abBalance = 0.5
    eqGain = [1 1 1]
    eqEnabled
    % derived
    time_step
  end

  methods (Access=private)
    function setPlay(this, enable)
      if enable
        this.isPlaying = true;
        this.t_clock = 0;
        this.t_played = 0;
        % reset timer
        this.playbackTimer = tic();
        this.cb_last = toc(this.playbackTimer);
      else
        this.isPlaying = false;
      end
    end
  end

  methods
    function obj = Mixer(arA, arB)
      obj.arA = arA;
      obj.arB = arB;
      % set up audio output device
      obj.ap = dsp.AudioPlayer('SampleRate', MATrax.AUD_SAMPLE_RATE,...
                               'BufferSizeSource', 'Property',...
                               'BufferSize', MATrax.AUD_FRAME_SIZE,...
                               'QueueDuration', MATrax.AUD_QUEUE_DUR);
      obj.time_step = MATrax.AUD_FRAME_SIZE / MATrax.AUD_SAMPLE_RATE;
      % set up equalizer
      obj.eq = Equalizer(MATrax.AUD_SAMPLE_RATE, 350, 5200);
    end

    function delete(this)
      this.release;
    end

    %% Controls
    function play(this)
      A = this.arA;
      B = this.arB;

      % initialize playback state and timer
      this.setPlay(true);

      while this.isPlaying
        % buffer until we buffer into the future for pseudo-real-time mixing
        if this.t_played < this.t_clock + this.time_step
          % get audio from both decks and crossfade
          audio = A.step * (1 - this.abBalance) + B.step * this.abBalance;
          % apply equalizer if necessary
          if (this.eqEnabled)
            audio = this.eqGain(1) .* step(this.eq.filters.bass, audio)...
              + this.eqGain(2) .* step(this.eq.filters.mid, audio)...
              + this.eqGain(3) .* step(this.eq.filters.treble, audio);
          end
          this.ap.step(audio);

          % update amount buffered
          this.t_played = this.t_played + this.time_step;

          if this.t_clock > this.cb_last + this.cb_interval
            this.cb_last = this.t_clock;
            A.runCallback;
            B.runCallback;
          end
        end

        % update clock
        this.t_clock = toc(this.playbackTimer);
        pause(0.001);
      end
    end

    function pause(this)
      this.setPlay(false);
    end

    function setBalance(this, bal)
      this.abBalance = bal;
    end

    function setEqGain(this, param, gain)
      this.eqGain(param) = gain;
    end

    function setEqEnable(this, enabled)
      this.eqEnabled = enabled;
    end

    function release(this)
      this.ap.release;
    end
  end
end
