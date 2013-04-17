% TODO: change this into a more powerful class instead of just a function?
function player = initWaveform(phandle, file)
% INITWAVEFORM This function initializes a player and associated plot This
%              function acts both as an initializer for the AUDIOPLAYER and
%              as a decorator for a plot. In addition, this function bootstraps
%              the callback for animating the plot as time goes on.

  if (nargin > 1)
    [Y, Fs] = audioread(file);
    player = audioplayer(Y, Fs);

    monoY = (Y(:,1) + Y(:,2)) / 2;
    wave = line(0:(length(monoY)-1), monoY, 'Parent', phandle, 'Color', 'g');
    set(phandle,...
        'XLim', [0 length(monoY)-1],...
        'YLim', [-1.1 1.1]);
    player.TimerFcn = {@(src, event) shiftXLim(player, phandle, length(monoY))};

    set(phandle,'ButtonDownFcn',@(src, event) toggle(player));
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

function toggle(player)
  if player.isplaying()
    pause(player);
    Console.log('Paused');
  else
    play(player);
    Console.log('Playing');
  end
end
