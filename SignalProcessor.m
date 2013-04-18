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
      if (nargin > 0)
        obj.sys = varargin{1};
      else
        obj.sys = ['MATrax_' datestr(now,'MMSSFFF')];
      end

      new_system(obj.sys);
      open_system(obj.sys);

      %% testing stuff
      t = (0:1000)';
      obj.in = struct('time', t, 'signals', struct('values', sin(t)));
      ws = get_param(obj.sys, 'modelworkspace');
      assignin(ws, 'input', obj.in);
      add_block('simulink/Sources/In1', [obj.sys '/foo']);
      add_block('simulink/Sinks/Out1', [obj.sys '/bar']);
      add_line(obj.sys, 'foo/1', 'bar/1', 'autorouting', 'on');
      obj.out = sim(obj.sys, 'LoadExternalInput', 'on', 'ExternalInput', 'input');
    end

    function delete(obj)
      close_system(obj.sys, 0);
    end
  end
end

