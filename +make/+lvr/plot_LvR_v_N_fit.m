function [fig,x,y,r] = plot_LvR_v_N_fit(T,R)
%PLOT_LVR_V_N_FIT  Plots fit of spike rate by LvR
%
%  fig = make.lvr.plot_LvR_v_N_fit(T);
%  -> Uses default R of 0.0015 (see `eqn.LvR`)
%
%  fig = make.lvr.plot_LvR_v_N_fit(T,R);
%  -> Specifies that a different R than default was used
%
%  [fig,x,y] = ...
%  --> Returns additional outputs:
%     -> `x` : Zero-mean log(N) spikes
%     -> `y` : Zero-mean LvR values
%     -> `r` : Correlation coefficient
%
%  -- Input --
%   -> T : Table returned by `compute_epoch_LvR.m` (`data.LvR` from
%           loadDataStruct())
%
%   -> R : (Optional) Refractoriness parameter used.
%
%  -- Output --
%   -> fig : Figure handle

X_COLOR = [0 0 0];
Y_COLOR = [0 0 0];
X_LABEL = 'log(N)';     % X-Axes label
Y_LABEL = 'LvR';        % Y-Axes label
X_LIM = [-5 5];         % X-Axes fixed range
Y_LIM = [-1.5 1.5];     % Y-Axes fixed range

MARKER_FACE_ALPHA = 0.20;
MARKER_FACE_COLOR = [0.1 0.1 0.1];
MARKER_EDGE_COLOR = [0.2 0.3 1.0];
MARKER_EDGE_ALPHA = 0.05;
MARKER_LINE_WIDTH = 6;
MARKER = 'o';

LINE_COLOR = [1.0 0.2 0.2];
LINE_WIDTH = 2.5;
LINE_STYLE = '--';

RESIDUAL_WEIGHT_FCN = @(x)atan(sqrt(abs(x))); % Residual2Size transform
POINT_SIZE_MULTIPLIER = 50; % Multiplier for scatter size (based on resid)
POINT_SIZE_MAX = 24;        % Maximum size of scatter data (unit: points)
POINT_SIZE_MIN =  2;        % Minimum Size of scatter data (unit: points)

FIG_NAME_EXPR = 'Fit: log(N) vs LvR | R = %3.1fms';

if nargin < 2
   R = 0.0015;
end

fname = sprintf(FIG_NAME_EXPR,R*1e3);

% In case supplied as `data` from `loadDataStruct()`
if isstruct(T)
   T = T.LvR;
end

x = log(T.N) - mean(log(T.N)); 
y = T.LvR-mean(T.LvR); 
c = corrcoef(x,y);
r = c(1,2);

xx = X_LIM;
yy = xx .* r;

resid = sqrt((r*x - y).^2);
w = RESIDUAL_WEIGHT_FCN(resid);
s = round(w .* POINT_SIZE_MULTIPLIER);
s = max(min(s,POINT_SIZE_MAX),POINT_SIZE_MIN);

% Make figure
fig = figure(...
   'Name',fname,...
   'Color','w'...
   ); 
ax = axes(fig,...
   'XColor',X_COLOR,...
   'YColor',Y_COLOR,...
   'Linewidth',2,...
   'XAxisLocation','origin',...
   'YAxisLocation','origin',...
   'TickDir','both',...
   'NextPlot','add',...
   'FontName','Arial',...
   'XLim',X_LIM,...
   'YLim',Y_LIM); 

% Plot points on figure
line(ax,xx,yy,...
   'Color',LINE_COLOR,...
   'LineStyle',LINE_STYLE,...
   'LineWidth',LINE_WIDTH,...
   'DisplayName',sprintf('fit: r = %5.3f',r));
scatter(ax,x,y,...
   'MarkerEdgeColor',MARKER_EDGE_COLOR,...
   'MarkerEdgeAlpha',MARKER_EDGE_ALPHA,...
   'MarkerFaceColor',MARKER_FACE_COLOR,...
   'MarkerFaceAlpha',MARKER_FACE_ALPHA,...
   'Marker',MARKER,...
   'LineWidth',MARKER_LINE_WIDTH,...
   'SizeData',s,...
   'DisplayName','data');

% Add annotation
xlabel(ax,X_LABEL,'FontName','Arial','Color','k'); 
ylabel(ax,Y_LABEL,'FontName','Arial','Color','k');
title(ax,fname,'FontName','Arial','Color','k','FontWeight','bold');
legend(ax,'Location','south');

if nargout < 1
   outDir = fullfile(defs.FileNames('OUTPUT_FIG_DIR'),'LvR Tests');
   outName = sprintf('Fit LvR v Spike Counts -- %4.0f usec',R*1e6);
   batchHandleFigure(fig,outDir,outName);
end

end