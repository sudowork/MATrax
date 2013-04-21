classdef Mixer < handle
  properties (Access=private)
    arA
    arB
    ap
    t_played
    t_clock
    playbackTimer
    % tunable
    isPlaying = false
    abBalance = 0.5
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
      else
        this.isPlaying = false;
      end
    end
  end

  methods
    function obj = Mixer(arA, arB)
      obj.arA = arA;
      obj.arB = arB;
      obj.ap = dsp.AudioPlayer('SampleRate', MATrax.AUD_SAMPLE_RATE,...
                               'BufferSizeSource', 'Property',...
                               'BufferSize', MATrax.AUD_FRAME_SIZE);
      obj.time_step = MATrax.AUD_FRAME_SIZE / MATrax.AUD_SAMPLE_RATE;
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
          audio = A.step * (1 - this.abBalance) + B.step * this.abBalance;
          this.ap.step(audio);

          % update amount buffered
          this.t_played = this.t_played + this.time_step;
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

    function release(this)
      this.arA.release;
      this.arB.release;
      this.ap.release;
    end
  end
end
