function colWidth = calcColWidth(data, varargin)
  [numCols, ~] = size(data');

  if isempty(varargin)
    minWidths = ones(1, numCols) .* 32;
  else
    minWidths = varargin{1};
  end

  colWidth = num2cell(max(cat(1,...
    cellfun(@(s) length(s) * 5.5, data),... % correct for pixels
    minWidths)));                         % concat min row
end
