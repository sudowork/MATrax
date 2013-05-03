classdef Reverberator < matlab.System

  properties (Access=private)
    numCombs = 4  % number of parallel comb filters
    delay         % inital delay in ms
    Fs            % sampling rate
    Ns            % Nyquist freq
    combs         % comb filters
    g             % gain for each comb
  end

  methods (Access=private)
    function delays = getDelays(this)
      % calculate delays such that they are prime
      p = nextprime(this.delay-1);
      delays = zeros(1,this.numCombs);
      delays(1) = p;
      for i=2:this.numCombs
        p = nextprime(p);
        delays(i) = p;
      end
    end
  end

  methods (Access=protected)
    function y = stepImpl(this,x)
      y = zeros(size(x));
      % parallel combs
      for i=1:this.numCombs
        y = y + this.g .* step(this.combs{i}, x);
      end
    end
  end

  methods
    function sys = Reverberator(fs, delay, g)
      % convert delay from ms to samples
      sys.delay = round(delay/1000 * fs);
      sys.Fs = fs;
      sys.Ns = fs/2;
      sys.g = g;

      % create comb filters (delay)
       sys.combs = cell(1,sys.numCombs);
      delays = sys.getDelays();
      for i=1:sys.numCombs
        sys.combs{i} = dsp.Delay(delays(i));
      end
    end
  end

end
