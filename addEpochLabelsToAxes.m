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
yMin = yMin(1);
ylim(gca,[yMin, yMax]);
hg = hggroup(ax,'Tag','Epochs','DisplayName','Epoch Info');
for iL = 1:numel(pars.EPOCH_ONSETS)
   rx = pars.EPOCH_ONSETS(iL);
   ry = yMin;
   rw = pars.EPOCH_OFFSETS(iL) - pars.EPOCH_ONSETS(iL);
   rh = pars.LABEL_HEIGHT;
   rectangle(hg,'Position',[rx,ry,rw,rh],'Curvature',pars.RECT_CURVATURE,...
      'FaceColor',pars.EPOCH_COL(iL,:),'EdgeColor','none');
   if iL > 1
      line(hg,[rx,rx],...
         [ry yMax], ...
         'Color',pars.LINE_COL,...
         'LineStyle','-.',...
         'LineWidth',2);
   end
   tx = rx + (rw/2);
   ty = ry + (rh/2);
   text(tx,ty,pars.EPOCH_NAMES{iL},'Parent',hg,...
      'FontName','Arial','Color',pars.TEXT_COL,'FontSize',10,...
      'FontWeight','bold','HorizontalAlignment','center',...
      'VerticalAlignment','middle');
end
hg.Annotation.LegendInformation.IconDisplayStyle = 'off';

xtick = intersect(pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS);
set(gca,'XLim',[min(pars.EPOCH_ONSETS),max(pars.EPOCH_OFFSETS)]);
set(gca,'XTick',xtick);

end