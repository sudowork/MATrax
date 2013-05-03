classdef Equalizer < handle

  properties (Access=private)
    Fs  % Sampling rate
    Ns  % Nyquist frequency
    Bc  % Bass cutoff freq
    Tc  % Treble cutoff freq
  end

  properties
    filters
  end

  methods (Static)
    function f = shiftHalfSteps(f0, n)
      a = 2^(1/12); % twelfth root of 2 (e.g. half steps in an octave)
      f = f0 * a^n; % move n-relative half steps
    end
  end

  methods
    function obj = Equalizer(Fs, Bc, Tc)
      obj.setSamplingRate(Fs);
      obj.Bc = Bc;
      obj.Tc = Tc;
      [bb,ba] = obj.getBassEq();
      [tb,ta] = obj.getTrebleEq();
      obj.filters.bass = Filter.makeIIR(bb,ba);
      obj.filters.mid = Filter.makeFIR(obj.getMidEq());
      obj.filters.treble = Filter.makeIIR(tb,ta);
    end

    function setSamplingRate(this, Fs)
      this.Fs = Fs;
      this.Ns = Fs/2;
    end

    % Use elliptic filter for low-pass (sharpest cutoff)
    function [b,a] = getBassEq(this)
      n = 5;        % Order
      Rp = 5;       % Ripple for pass band (~5 dB recommended for < 300Hz)
      Rs = 90;      % Attenuation for stop band
      [b,a] = ellip(n, Rp, Rs, this.Bc/this.Ns);
    end

    % Use Chebyshev filter for mids using Park-McClennan
    function b = getMidEq(this)
      t = 100;  % transition window size (equiripple to prevent blow up)
      Fs1 = this.Bc - t;
      Fp1 = this.Bc + t;
      Fs2 = this.Tc - t;
      Fp2 = this.Tc + t;
      Rs = 90;      % stop band attenuation
      f = [Fs1 Fp1 Fs2 Fp2] / this.Ns;      % Cutoff frequencies
      A = [0 1 0];        % Desired amplitudes
      % Compute deviations
      Rsd = 10^(-Rs/20);
      dev = [Rsd .05 Rsd];

      % compute filter params
      [n,fo,ao,w] = firpmord(f,A,dev);
      b = firpm(n,fo,ao,w);
    end

    % Use elliptic high pass filter for treble eq
    function [b,a] = getTrebleEq(this)
      n = 10;       % Order
      Rp = 2;       % Ripple for pass band (~2 dB recommended for > 300Hz)
      Rs = 90;      % Attenuation for stop band
      [b,a] = ellip(n, Rp, Rs, this.Tc/this.Ns, 'high');
    end

    % don't actually use this (it's slow)
    function [b,a] = getMidKaiserEq(this)
      Wp = Equalizer.shiftHalfSteps(this.Bc, 3);  % pass cutoff freq
      Ws = Equalizer.shiftHalfSteps(this.Tc, -3); % stop cutoff freq
      f = [this.Bc Wp Ws this.Tc] / this.Ns;      % Cutoff frequencies
      A = [0 1 0];        % Desired amplitudes
      % Compute deviations
      dev = [0.001 .05 0.001];  % ripple of 5%, attenuation of -60 dB
      [M,Wn,beta,typ] = kaiserord(f,A,dev);

      b = fir1(M,Wn,typ,kaiser(M+1,beta),'noscale');
      a = 1;
    end

    % not used by MATrax; only for reporting purposes
    function freqz(this)
      [b1,a1] = this.getBassEq();
      [b2,a2] = this.getMidEq();
      [b3,a3] = this.getTrebleEq();
      fvtool(b1,a1,b2,a2,b3,a3);
    end

  end
end
