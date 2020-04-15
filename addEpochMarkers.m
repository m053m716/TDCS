function addEpochMarkers(ax,stimStart,stimStop,preX,stimX,postX,labY,yLim)
%ADDEPOCHMARKERS  Add epoch delimiter markers and labels to time-series
%
%  addEpochMarkers(ax,stimStart,stimStop,preX,stimX,postX,labY,yLim);
%
%  >> addEpochMarkers(ax,15,35,5,25,45,0.5,[-1 1]);
%
%  -- Inputs --
%   -> ax : Axes object to add delimiters to
%   -> stimStart : Time (minutes) of stim epoch start
%   -> stimStop  : Time (minutes) of stim epoch end
%   -> preX : Time (minutes) of "pre" label x-coordinate
%   -> stimX : Time (minutes) of "stim" label x-coordinate
%   -> postX : Time (minutes) of "post" label x-coordinate
%   -> labY : Y-coordinate of all labels (scalar)
%     --> If not set, default value is 0.5
%     --> Can also be 3-element vector to set unique for preX,stimX,postX
%   -> yLim : [lower upper] coordinates for epoch marker
%     --> If not set, defaults to axes y-limit

if nargin < 7
   labY = 0.5;
end

if nargin < 8
   yLim = get(ax,'YLim');
end

% Add epoch delimiters
line(ax,ones(1,2).*stimStart,yLim,'Color','k','LineStyle','--','LineWidth',1.5);
line(ax,ones(1,2).*stimStop,yLim,'Color','k','LineStyle','--','LineWidth',1.5);

% Add epoch labels
if isscalar(labY)
   text(ax,preX,labY,'Pre','FontName','Arial','FontSize',12,'FontWeight','bold','Color','k');
   text(ax,stimX,labY,'Stim','FontName','Arial','FontSize',12,'FontWeight','bold','Color','k');
   text(ax,postX,labY,'Post','FontName','Arial','FontSize',12,'FontWeight','bold','Color','k');
else
   text(ax,preX,labY(1),'Pre','FontName','Arial','FontSize',12,'FontWeight','bold','Color','k');
   text(ax,stimX,labY(2),'Stim','FontName','Arial','FontSize',12,'FontWeight','bold','Color','k');
   text(ax,postX,labY(3),'Post','FontName','Arial','FontSize',12,'FontWeight','bold','Color','k');
end

end