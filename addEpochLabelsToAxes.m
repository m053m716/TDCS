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


pars = parseParameters('EpochLabels',varargin{:});

yMin = get(gca,'YLim')-pars.LABEL_OFFSET;
yMax = yMin(2);
if isempty(pars.LABEL_FIXED_Y)
   yMin = yMin(1);
else
   yMin = pars.LABEL_FIXED_Y;
end
ylim(gca,[yMin, yMax]);
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
set(gca,'XLim',[min(pars.EPOCH_ONSETS),max(pars.EPOCH_OFFSETS)]);
set(gca,'XTick',sort(unique(xt),'ascend'));

end