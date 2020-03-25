function genLFPChangeFig(SimpleLFPData)

%% DEFAULTS
TT = [5, 15; ...
      15, 35; ...
      35, 50; ...
      50, 65; ...
      65, 80; ...
      80, inf];
  
BAND = unique(SimpleLFPData{1,1}.Band);
GROUPS = {'Pre-Stim', ...
          'Stimulation', ...
          'Post-Stim1', ...
          'Post-Stim2', ...
          'Post-Stim3', ...
          'Post-Stim4'};
HISTOPT = 1.0;
DF = 0.3;
CMAP = 'parula';

%% GEN FIGURE

Condition = SimpleLFPData{1,1}.Condition;
Band = SimpleLFPData{1,1}.Band;

RMS_Change = (SimpleLFPData{1,2}.Power) - (SimpleLFPData{1,1}.Power);
% figure('Name','LFP mean power changes by treatment (subplots)', ...
%            'Units','Normalized',...
%            'Position',[0.1 0.1 0.8 0.8]);      
% for iB = 1:numel(BAND)
%     subplot(2,3,iB);
%     fname = sprintf('%s mean power change by treatment',BAND{iB});
%     Band_Index = ismember(SimpleLFPData{1,1}.Band,BAND{iB});
%     boxplot(RMS_Change(Band_Index),Condition(Band_Index));
%     ylabel('\DeltaRMS');
%     xlabel('Treatment');
%     title(fname);
% end
% 
% suptitle('LFP mean power changes by treatment');
% savefig(gcf,'LFP mean power changes by treatment - subplot.fig');
% saveas(gcf,'LFP mean power changes by treatment - subplot.jpeg');


figure('Name','LFP mean power changes by treatment (1 Figure)', ...
       'Color','w',...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]); 
c = colormap(CMAP);
G = [cellstr(num2str(Condition)),Band];
g = cell(size(G,1),1);
vec = true(size(g));
for iG = 1:numel(g)
    g{iG} = strjoin(G(iG,:),'-');
    if strcmp(G{iG,2}(1:3),'GAM')
        vec(iG) = false;
    end
end
% boxplot(RMS_Change(vec),g(vec), ...
%          'PlotStyle','compact');
distributionPlot(RMS_Change(vec)*1e3,'groups',g(vec), ...
                       'variableWidth', true, ...
                       'colormap', c, ...
                       'histOpt', HISTOPT, ...
                       'divFactor', DF, ...
                       'addBoxes', 0, ...
                       'addSpread',1); ...
%                        'xyOri','flipped');
     
ylabel('\DeltaRMS (mV)');
xlabel('Treatment');
ylim([-1 1]);

title('LFP mean power changes by treatment');
savefig(gcf,'LFP mean power changes by treatment - single.fig');
saveas(gcf,'LFP mean power changes by treatment - single.jpeg');

end