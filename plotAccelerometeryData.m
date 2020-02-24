function fig = plotAccelerometeryData(acc,ax)
%PLOTACCELEROMETERYDATA  Plots data in 'acc' accelerometer data struct
%
%  fig = PLOTACCELEROMETERYDATA(acc);
%  >> standard, makes 2 axes
%
%  acc : See EXAMPLE_ACCELEROMETERY_TDCS
%  fig : Output figure handle
%
%  fig = PLOTACCELEROMETERYDATA(acc,ax);
%  >> Puts stuff that usually goes on top axes onto the axes defined by ax.
%  >> For multiple elements of acc, ax can be a scalar or array of axes of
%  same dimension as acc.
%  >> In this case:
%  fig : Output line with tag 'Aux', which could have its YData changed to
%  represent something else as desired


if numel(acc) > 1
   fig = gobjects(1,numel(acc));
   if nargin == 2
      if numel(ax) == 1
         ax = repmat(ax,size(acc));
      end
   end
   for i = 1:numel(acc)
      if nargin < 2
         fig(i) = plotAccelerometeryData(acc(i));
      else
         fig(i) = plotAccelerometeryData(acc(i),ax(i));
      end
   end
   return;
end

% % % Make figure % % % % %
% Make top axes
if exist('ax','var')==0
   % Define graphics objects
   fig = figure('Name','tDCS Accelerometer Example',...
      'NumberTitle','off',...
      'Color','w',...
      'Units','Normalized',...
      'Position',[0.2 0.3 0.35 0.35]); 
   ax_top = axes(fig,...
      'XColor','k','YColor','k',...
      'LineWidth',2.0,'FontName','Arial',...
      'XColor',[0.25 0.25 0.25],...
      'Units','Normalized','Position',[0.15 0.6 0.75 0.25],...
      'NextPlot','add');
else
   ax_top = ax;
end

hg = hggroup(ax_top,'Tag','Accelerometery Data','DisplayName','|acc|');
plot(hg,acc.t(acc.idx.BASAL)/60,acc.a_mag_cal(acc.idx.BASAL),...
   'b-','LineWidth',1.25);
% h = line(hg,ones(1,2)*acc.t(acc.idx.BASAL(end))/60,[-1.5 2.5],'Color',[0.55 0.55 0.55],...
%    'LineWidth',2,'LineStyle','--');
% h.Annotation.LegendInformation.IconDisplayStyle = 'off';
% text(hg,mean(acc.t(acc.idx.BASAL)/60)-2.5,-1.0,'BASAL','FontName','Arial',...
%    'FontSize',13,'FontWeight','bold','Color',[0.50 0.50 0.50]);

plot(hg,acc.t(acc.idx.STIM)/60,acc.a_mag_cal(acc.idx.STIM),...
   'r-','LineWidth',1.25);
% h = line(hg,ones(1,2)*acc.t(acc.idx.STIM(end))/60,[-1.5 2.5],'Color',[0.55 0.55 0.55],...
%    'LineWidth',2,'LineStyle','--');
% h.Annotation.LegendInformation.IconDisplayStyle = 'off';
% text(hg,mean(acc.t(acc.idx.STIM)/60)-3.0,-1.0,'STIM','FontName','Arial',...
%    'FontSize',13,'FontWeight','bold','Color',[0.50 0.50 0.50]);

F = setdiff(fieldnames(acc.idx),{'BASAL','STIM'});
for iF = 1:numel(F)
   plot(hg,acc.t(acc.idx.(F{iF}))/60,acc.a_mag_cal(acc.idx.(F{iF})),...
      'b-','LineWidth',1.25);
%    h = line(hg,ones(1,2)*acc.t(acc.idx.(F{iF})(end))/60,[-1.5 2.5],'Color',[0.55 0.55 0.55],...
%    'LineWidth',2,'LineStyle','--');
%    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
%    text(hg,mean(acc.t(acc.idx.(F{iF}))/60)-2.75,-1.0,F{iF},'FontName','Arial',...
%       'FontSize',13,'FontWeight','bold','Color',[0.50 0.50 0.50]);
end
hg.Annotation.LegendInformation.IconDisplayStyle = 'on';
l = plot(ax_top,acc.t/60,cumsum(abs(acc.a_mag_cal-1))/numel(acc.a_mag_cal)*20,...
   'k-','LineWidth',1.5,'Tag','Aux');
if exist('ax','var')~=0
   fig = l; % Assign 'fig' output as this line handle instead
end


ylim([-1.75 4.5]);
xlim([5 95]);

if exist('ax','var')~=0
   lgd = legend(ax_top,{'||a||','LFP Power (a.u.)'},...
      'Location','best','Orientation','horizontal');
else
   lgd = legend(ax_top,{'||acc||','\int||acc||'},...
      'Location','best','Orientation','horizontal');
end
lgd.FontSize = 12;
lgd.FontName = 'Arial';
lgd.TextColor = 'k';
lgd.Color = 'none';
lgd.Box = 'off';

addEpochLabelsToAxes(ax_top,'LABEL_OFFSET',3.0,'LABEL_HEIGHT',1.5);
title(ax_top,sprintf('%s: Accelerometer Data',acc.rat),...
   'FontName','Arial','Color','k','FontSize',16,'FontWeight','bold');
ylabel(ax_top,'|Acceleration| (g)','FontName','Arial','Color','k','FontSize',14);
xlabel(ax_top,'Time (mins)','FontName','Arial','Color','k','FontSize',14);

if exist('ax','var')~=0
   return;
end


% Make bottom axes
ax_bot = axes(fig,...
   'XColor','k','YColor','k',...
   'LineWidth',2.0,'FontName','Arial',...
   'XTick',1:(2+numel(F)),...
   'XColor',[0.50 0.50 0.50],...
   'XTickLabel',horzcat('BASAL','STIM',F(:)'),...
   'TickDir','out',...
   'Units','Normalized','Position',[0.15 0.15 0.75 0.25],...
   'NextPlot','add');
mu = mean(abs(acc.a_mag_cal(acc.idx.BASAL)-1));
sd = std(abs(acc.a_mag_cal(acc.idx.BASAL)-1));
barIndex = 1;
bar(ax_bot,barIndex,mu,0.85,'FaceColor','b','EdgeColor','none');
line(ax_bot,[barIndex barIndex],[mu mu+sd],...
   'LineWidth',1.25,'Color','k','LineStyle','-');

mu = mean(abs(acc.a_mag_cal(acc.idx.STIM)-1));
sd = std(abs(acc.a_mag_cal(acc.idx.STIM)-1));
barIndex = 2;
bar(ax_bot,barIndex,mu,0.85,'FaceColor','r','EdgeColor','none');
line(ax_bot,[barIndex barIndex],[mu mu+sd],...
   'LineWidth',1.25,'Color','k','LineStyle','-');


for iF = 1:numel(F)
   mu = mean(abs(acc.a_mag_cal(acc.idx.(F{iF}))-1));
   sd = std(abs(acc.a_mag_cal(acc.idx.(F{iF}))-1));
   barIndex = iF+2;
   bar(ax_bot,barIndex,mu,0.85,'FaceColor','b','EdgeColor','none');
   line(ax_bot,[barIndex barIndex],[mu mu+sd],...
      'LineWidth',1.25,'Color','k','LineStyle','-');
end

ylabel(ax_bot,'|Acceleration|_{mean} (g)','FontName','Arial','Color','k','FontSize',14);
xlabel(ax_bot,'Epoch','FontName','Arial','Color',[0.50 0.50 0.50],'FontSize',14);

% % % % % % % % % % % % % %

end