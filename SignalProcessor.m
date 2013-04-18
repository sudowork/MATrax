classdef SignalProcessor < handle
% SIGNALPROCESSOR Used to filter and distort a single signal
%                 Programatically constructs a SIMULINK model in order to
%                 provide real-time signal processing. Takes a single signal
%                 as an input and outputs a processed signal.
%
% Author: Kevin Gao
% Usage: 
% See Also: MATRAXENGINE
  properties (Access=private)
    sys     % backend SIMULINK model
    id      % system id
  end

  properties (GetAccess='public', SetAccess='private')
    in      % input signal
    out     % output signal
  end

  methods (Access=private)
  end

  methods
    function obj = SignalProcessor(varargin)
      if ~isdeployed
        addpath(fullfile('.', 'models'));
      end
      obj.sys = 'TrackModel';
      open_system(obj.sys);

      %% testing stuff
      t = linspace(0,1,44100)';
      obj.in = struct('time', t, 'signals', struct('values', sin(261.63*2*pi.*t)));
      ws = get_param(obj.sys, 'modelworkspace');
      assignin(ws, 'input', obj.in);
      outputs = sim(obj.sys, 'LoadExternalInput', 'on', 'ExternalInput', 'input');
      obj.out = struct('time', get(outputs, 'tout'), 'signals', struct('values', get(outputs, 'yout')));
    end

    function delete(obj)
      %close_system(obj.sys, 0);
    end
  end
end

