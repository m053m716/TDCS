function ax = batch_export_delta_Rate_Boxplots(dFR_table,varargin)
%BATCH_EXPORT_DELTA_RATE_Boxplots  Export boxplots regarding delta-firing rate
%
%  batch_export_delta_Rate_Boxplots(dFR_table,'NAME',value,...);
%  --> dFR_table : Output by `compute_delta_FR`
%     * Should have 3 cells: 
%        + {1,1} -- 'BASAL' or 'PRE' (10 mins)
%        + {1,2} -- 'STIM'           (20 mins)
%        + {1,3} -- 'POST'           (15 mins)
%
%  --> <'NAME',value> pair syntax for setting optional parameters
%     * Default parameters are loaded from `defs.Export_Delta_Figs`

pars = parseParameters('Export_Delta_Figs',varargin{:});
T = [];

figName = 'Boxplots--Change in Firing Rate';
fig = figure('Name',figName,...
      'Units','Normalized',...
      'Color','w',...
      'Position',pars.FIG_POS);
ax = axes(fig,'FontName','Arial',...
   'XColor','k','YColor','k',...
   'NextPlot','add',...
   'XLim',pars.XLIM,...
   'YLim',pars.YLIM);
xlabel(ax,'Time (min)','FontName','Arial','FontSize',14,'Color','k');
ylabel(ax,'\Delta \surd (FR)', 'FontName','Arial','FontSize',14,'Color','k'); 
title(ax,figName,'FontName','Arial','FontSize',16,'Color','k');

for iEpoch = 1:3
   T = [T; [dFR_table{iEpoch}, ...
      table(ones(size(dFR_table{iEpoch},1),1).*iEpoch,...
      'VariableNames',{'Epoch'})]];   
end

YData = cell2mat(T.delta_sqrt_Rate);
XData = repmat(pars.EPOCH_TS,size(YData,1),1);
XData = XData(:);
YData = YData(:);
MaskData = cell2mat(T.mask);
MaskData = MaskData(:);
YData(MaskData) = [];
XData(MaskData) = [];

ConditionData = T.ConditionID;
CurrentData = T.CurrentID;
ColorGroup = ConditionData .* CurrentData;

XData = XData ./ 60 + 5; % Account for initial offset
GroupData = [XData,ConditionData,CurrentData];
CGroupData = pars.CONDITION_CUR_COL(:);
CGroupData = cell2mat(CGroupData);
boxplot(ax,YData,GroupData,...
   'BoxStyle','filled',...
   'PlotStyle','compact',...
   'Colors',CGroupData,...
   'ColorGroup',ColorGroup,...
   'Widths',0.1);

addEpochLabelsToAxes(ax,...
         'LABEL_HEIGHT',15,...
         'EPOCH_COL',ones(1,3).*pars.EPOCH_COL_FACTOR,...
         'TEXT_COL',[0 0 0]);
if exist(pars.OUT_FOLDER,'dir')==0
   mkdir(pars.OUT_FOLDER);
end

% expAI(fig,fullfile(pars.OUT_FOLDER,figName));
savefig(fig,fullfile(pars.OUT_FOLDER,[figName '.fig']));
saveas(fig,fullfile(pars.OUT_FOLDER,[figName '.png']));
% delete(fig);
   

end