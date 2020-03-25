function ax = addBandsToAx(ax,varargin)
%ADDBANDSTOAX  Adds frequency band labels to axes
%
%  ax = addBandsToAx(ax);
%
%  ax = addBandsToAx(ax,'NAME',value,...);

pars = parseParameters('LFP',varargin{:});
nextPlotBehavior = get(ax,'NextPlot');
set(ax,'NextPlot','add');

x = pars.TLIM_LABS;
dx = diff(x);
x = x(1);

for i = 1:numel(pars.BANDS)
   bandName = pars.BANDS{i};
   c = defs.BandColors(bandName);
   hg = hggroup(ax);
   y = pars.FC.(bandName);
   dy = diff(y);
   y = y(1);
   pos = [x, y, dx, dy];
   
   rectangle(ax,'Position',pos,...
      'Curvature',[0.2 0.2],...
      'FaceColor',c,...
      'EdgeColor','none');
   text(ax,x,y+dy/4,0.25,strrep(bandName,'_',' '),...
      'FontName','Arial',...
      'FontSize',15,...
      'Color',c,...
      'BackgroundColor','none',...
      'EdgeColor','none',...
      'Rotation',45,...
      'HorizontalAlignment','Right',...
      'FontWeight','bold');
end

% Revert to old behavior
set(ax,'NextPlot',nextPlotBehavior);

end