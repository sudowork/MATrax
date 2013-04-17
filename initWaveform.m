% TODO: change this into a more powerful class instead of just a function?
function initWaveform(phandle, deck)
% INITWAVEFORM This function initializes a player and associated plot This
%              function acts both as an initializer for the AUDIOPLAYER and
%              as a decorator for a plot. In addition, this function bootstraps
%              the callback for animating the plot as time goes on.
  if (nargin > 1)
    player = deck.player;
    Y = deck.data(1);
    monoY = (Y(:,1) + Y(:,2)) / 2;

    % plot and set axes limits
    line(0:(length(monoY)-1), monoY, 'Parent', phandle, 'Color', 'g');
    set(phandle,...
        'XLim', [0 length(monoY)-1],...
        'YLim', [-1.1 1.1]);
    % set callback to shift X axis at each interval
    player.TimerFcn = {@(src, event) shiftXLim(player, phandle, length(monoY))};
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

function shiftXLim(player, phandle, numSamples)
  set(phandle, 'XLim', [0 numSamples] + player.CurrentSample);
end
