function initWaveform(phandle, deck)
% INITWAVEFORM This function initializes a player and associated plot This
%              function acts both as an initializer for the AUDIOPLAYER and
%              as a decorator for a plot. In addition, this function bootstraps
%              the callback for animating the plot as time goes on.
%
% Author: Kevin Gao
% Usage:  `initWaveform(plothandler)` will simply stylize
%         `initWaveform(plothandler, deck)` will plot, setup callbacks, and stylize
%
% TODO: change this into a more powerful class instead of just a function?

  if (nargin > 1)
    winSize = 5; % seconds
    winLength = winSize * deck.Fs;
    player = deck.player;
    monoY = (deck.Y(:,1) + deck.Y(:,2)) / 2;

    % plot and set axes limits
    wave = plot(phandle, monoY(1:winLength), 'g');
    set(phandle,...
        'XLim', [0 winLength],...
        'YLim', [-1.1 1.1]);
    % set callback to shift X axis at each interval
    player.TimerFcn = {@(src, event) shiftXLim(wave, monoY, player.CurrentSample, winLength)};
  end

  stylize(phandle);
end

function stylize(phandle)
  set(phandle,...
      'Color', 'k',...
      'XColor', 'k',...
      'YColor', 'k',...
      'XTick', [],...
      'YTick', []);
end

function shiftXLim(phandle, data, currSample, numSamples)
  set(phandle, 'YData', data(currSample:currSample + numSamples));
end
