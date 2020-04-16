function [fig,h,p] = histogram_LvR_distribution(T,R,xLim,yLim)
%HISTOGRAM_LVR_DISTRIBUTION  Makes histogram of distribution of LvR values
%
%  fig = make.lvr.histogram_LvR_distribution(T);
%  -> Uses default R of 0.0015 (see `eqn.LvR`)
%
%  fig = make.lvr.histogram_LvR_distribution(T,R,xLim,yLim);
%  -> Specify optional parameters: 
%     -> `R` : "Refractoriness" used (if different from 0.0015, should set
%                 it here to get correct title)
%     -> `xLim` : Default is []; if set, use fixed xLimits, otherwise,
%                       estimates based on data
%     -> `yLim` : Default is []; if set, use fixed yLimits, otherwise
%                       estimates based on data
%
%  [fig,h,p] = ...
%  -> Optionally return `h`, the histogram object
%  -> Optionally reteurn `p`, the patch object for kernel density
%
%  -- Input --
%   -> T : Table returned by `compute_epoch_LvR.m` (`data.LvR` from
%           loadDataStruct())
%
%  -- Output --
%   -> fig : Figure handle

X_LABEL = 'LvR';           % X-Axes label
Y_LABEL = 'Count';         % Y-Axes label
MU_COLOR = [0 0 0];        % Black
MU_SIZE = 12;              % Points
BAR_COLOR = [0.2 0.3 1.0]; % Blue

EDGE_COLOR = [0.2 0.2 0.2]; % Dark-grey
FACE_COLOR = [0.8 0.8 0.8]; % Light-grey
FACE_ALPHA = 0.5;           % See-through patch
LINE_WIDTH = 2.5;           % For kernel density estimate curve

FIG_NAME_EXPR = 'Distribution: LvR | R = %3.1fms';
if nargin < 2
   R = T.Properties.UserData.R;
end
if nargin < 3
   xLim = [];
end
if nargin < 4
   yLim = [];
end
fname = sprintf(FIG_NAME_EXPR,R*1e3);

% In case supplied as `data` from `loadDataStruct()`
if isstruct(T)
   T = T.LvR;
end

% Make figure
fig = figure(...
   'Name',fname,...
   'Color','w'...
   ); 
ax = axes(fig,...
   'XColor','k',...
   'YColor','k',...
   'Linewidth',2,...
   'TickDir','both',...
   'NextPlot','add',...
   'FontName','Arial'...
   ); 

% Get histogram
h = histogram(ax,T.LvR,...
   'FaceColor',BAR_COLOR,...
   'EdgeColor','none'); % Make histogram of LvR
N_max = max(h.Values);

% Plot points on figure
mu = mean(T.LvR);
text(ax,mu,N_max,sprintf('\\mu_{LvR} = %5.3f',mu),...
   'FontName','Arial','Color',MU_COLOR,'FontSize',MU_SIZE,...
   'FontWeight','bold','HorizontalAlignment','center',...
   'VerticalAlignment','bottom');

% Add annotation
xlabel(ax,X_LABEL,'FontName','Arial','Color','k'); 
ylabel(ax,Y_LABEL,'FontName','Arial','Color','k');
title(ax,fname,'FontName','Arial','Color','k','FontWeight','bold');

% Get kernel density estimate
[kd,kx] = ksdensity(T.LvR,'Support','positive');
yyaxis(ax,'right');
set(ax,'YColor',FACE_COLOR,'FontName','Arial');
ylabel(ax,'Density','FontName','Arial','Color',FACE_COLOR);

F = [1:numel(kx),1]; % Faces (connection pattern -> consecutive elements)
V = [kx.',kd.'];     % Vertices
p = patch(ax,'Faces',F,'Vertices',V,...
   'EdgeColor',EDGE_COLOR,...
   'FaceColor',FACE_COLOR,...
   'LineWidth',LINE_WIDTH,...
   'FaceAlpha',FACE_ALPHA);

if ~isempty(yLim)
   ylim(ax,yLim);
end
if ~isempty(xLim)
   xlim(ax,xLim)
end

if nargout < 1
   outDir = fullfile(defs.FileNames('OUTPUT_FIG_DIR'),'LvR Tests');
   outName = sprintf('Distribution LvR -- %4.0f usec',R*1e6);
   batchHandleFigure(fig,outDir,outName);
end

end