function hg = addEpochLabelsToAxes(ax,varargin)
%ADDEPOCHLABELSTOAXES  Adds labels to axes and returns grouped graphics
%
%  hg = ADDEPOCHLABELSTOAXES(ax);
%
%  ax : Axes handle
%  varargin : (Optional) 'name' value pairs for different things like
%                 'EPOCH_ONSETS' etc
%
%  hg : Graphics object group handle with all the separator lines,
%        rectangles and texts on them.

if nargin < 1
   ax = gca;
end

if numel(ax) > 1
   error(['tDCS:' mfilename ':BadInputSize'],...
      ['\n\t->\t<strong>[ADDEPOCHLABELSTOAXES]:</strong> ' ...
      'Should only add epoch labels to scalar axes objects\n']);
end

set(ax,'NextPlot','add');
pars = parseParameters('EpochLabels',varargin{:});

if isempty(pars.LABEL_FIXED_Y)
   yMin = ax.YLim(1)-pars.LABEL_OFFSET;
else
   yMin = pars.LABEL_FIXED_Y;
end
yMax = ax.YLim(2);
if yMin < ax.YLim(1)
   ylim(ax,[yMin, yMax]);
end
hg = hggroup(ax,'Tag','Epochs','DisplayName','Epoch Info');
nEpoch = numel(pars.EPOCH_ONSETS);
xt = [];
for iL = 1:nEpoch
   rx = pars.EPOCH_ONSETS(iL);
   ry = yMin;
   rw = pars.EPOCH_OFFSETS(iL) - pars.EPOCH_ONSETS(iL);
   rh = pars.LABEL_HEIGHT;
   rectangle(hg,'Position',[rx,ry,rw,rh],'Curvature',pars.RECT_CURVATURE,...
      'FaceColor',pars.EPOCH_COL(iL,:),'EdgeColor','none');
   if (iL > 1) && pars.ADD_EPOCH_DELIMITER_LINES
      lx = (pars.EPOCH_ONSETS(iL) + pars.EPOCH_OFFSETS(iL-1))/2;
      xt = [xt, pars.EPOCH_ONSETS(iL), pars.EPOCH_OFFSETS(iL-1)]; %#ok<AGROW>
      line(hg,[lx,lx],...
         [ry yMax], ...
         'Color',pars.LINE_COL,...
         'LineStyle',pars.LINE_STYLE,...
         'LineWidth',pars.LINE_WIDTH);
   end
   tx = rx + (rw/2);
   ty = ry + (rh/2);
   text(tx,ty,pars.EPOCH_NAMES{iL},'Parent',hg,...
      'FontName','Arial','Color',pars.TEXT_COL,'FontSize',10,...
      'FontWeight','bold','HorizontalAlignment','center',...
      'VerticalAlignment','middle');
end
hg.Annotation.LegendInformation.IconDisplayStyle = 'off';
set(ax,'XLim',[min(pars.EPOCH_ONSETS),max(pars.EPOCH_OFFSETS)]);
set(ax,'XTick',sort(unique(xt),'ascend'));

end