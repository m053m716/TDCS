function generateBasicSpikeFigures(AppendedSpikeData,varargin)
%GENERATEBASICSPIKEFIGURES    Gets spike figures for the prelim analysis
%
%  GENERATEBASICSPIKEFIGURES(AppendedSpikeData);
%  --> Uses defs.Spikes for `pars`
%
%  GENERATEBASICSPIKEFIGURES(AppendedSpikeData,pars);
%  --> Give `pars` directly as second input.
%
%  GENERATEBASICSPIKEFIGURES(AppendedSpikeData,'NAME',value,...);
%  --> Uses defs.Spikes for `pars`
%     --> Modify fields using `'NAME',value`,... syntax

% DEFAULT CONSTANTS
switch nargin
   case 0
      pars = defs.Spikes();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.Spikes();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

if abs(numel(pars.GROUPS) - numel(AppendedSpikeData)) > eps
    error('Mismatch between number of group names and number of epochs.');
end

% GET ANIMAL AND CONDITION VARIABLES
Animal = AppendedSpikeData{1,1}.Animal;
Condition = AppendedSpikeData{1,1}.Condition;

% COMPARE SESSION LOG-RATES BY PERIOD
figure('Name','Spike Cluster Log-Rate by Period', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);
  
LogRate = [];

for iEpoch = 1:numel(AppendedSpikeData)
    LogRate = [LogRate,log(AppendedSpikeData{1,iEpoch}.Rate)]; %#ok<AGROW>
end
           
boxplot(LogRate, pars.GROUPS);
ylabel('log(spikes/sec)');
title('Spike Cluster Log-Rates by Period');
savefig(gcf,'SpikeRatebyPeriod.fig');
saveas(gcf,'SpikeRatebyPeriod.jpeg');
delete(gcf);

% COMPARE SESSION LOG-RATES BY PERIOD WITHIN CONDITIONS
figure('Name','Spike Cluster Log-Rate by Period and Condition', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);       

for iCondition = 1:6
    subplot(3,2,iCondition);
    Condition_Index = abs(Condition-iCondition)<eps;
    boxplot(LogRate(Condition_Index,:), pars.GROUPS);
    ylabel('log(spikes/sec)');
    title(['Condition ' num2str(iCondition)]);
end
suptitle('Spike Cluster Log-Rates by Period and Condition');
savefig(gcf,'SpikeRatebyPeriodandCondition.fig');
saveas(gcf,'SpikeRatebyPeriodandCondition.jpeg');
delete(gcf);

% COMPARE PRE-POST RATE CHANGES BY CONDITION
figure('Name','Spike Cluster Rate Changes by Condition (Boxplot)', ...
       'Units','Normalized', ...
       'Position',[0.1 0.1 0.8 0.8]);

Rates = [];
for iEpoch = 1:numel(AppendedSpikeData)
    Rates = [Rates,AppendedSpikeData{1,iEpoch}.Rate]; %#ok<AGROW>
end
   
RateChange = Rates(:,2) - Rates(:,1);
   
boxplot(RateChange,Condition);
ylabel('\Deltaspikes/sec');
title('Spike Cluster Rate Changes by Condition');
savefig(gcf,'SpikeRateChangesbyCondition.fig');
saveas(gcf,'SpikeRateChangesbyCondition.jpeg');
delete(gcf);

figure('Name','Spike Cluster Rate Changes by Condition (Histogram)', ...
       'Units','Normalized', ...
       'Position',[0.1 0.1 0.8 0.8]);
   
for iCondition = 1:6
    subplot(3,2,iCondition);
    Condition_Index = abs(Condition-iCondition)<eps;
    histogram(RateChange(Condition_Index),-1:0.2:1);
    ylabel('Count'); xlabel('\Deltaspikes/sec');
    xlim([-1 1]); ylim([0 20]);
    title(['Condition ' num2str(iCondition)]);
end
suptitle('Spike Cluster Rate Changes');
savefig(gcf,'SpikeRatebyConditionHist.fig');
saveas(gcf,'SpikeRatebyConditionHist.jpeg');
delete(gcf);

% COMPARE PRE-POST RATE CHANGES BY ANIMAL BY CONDITION
figure('Name','Change in Rate by Animal and Condition', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);

Animal_List = unique(Animal);
Animal_List = reshape(Animal_List,1,numel(Animal_List));

row = ceil(sqrt(numel(Animal_List)));
col = row;

for iA = 1:numel(Animal_List)
    subplot(row,col,iA);
    Animal_Index = abs(Animal - Animal_List(iA)) < eps;
    boxplot(RateChange(Animal_Index),Condition(Animal_Index));
    title(['Animal ' num2str(Animal_List(iA))]);
    xlabel('Condition'); ylabel('\Deltaspikes/sec');
end
suptitle('\Deltaspikes/sec by Animal and Condition');

savefig(gcf,'SpikeRateChangesByAnimal.fig');
saveas(gcf,'SpikeRateChangesByAnimal.jpeg');
delete(gcf);

% COMPARE SESSION LOCAL VARIATION BY PERIOD
figure('Name','Spike Cluster LvR by Period', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);
   
LvR = [];
for iEpoch = 1:numel(AppendedSpikeData)
    LvR = [LvR, AppendedSpikeData{1,iEpoch}.Regularity]; %#ok<AGROW>
end
            
boxplot(LvR, pars.GROUPS);
ylabel('LvR');
title('Spike Cluster LvR by Period');
savefig(gcf,'LvRbyPeriod.fig');
saveas(gcf,'LvRbyPeriod.jpeg');
delete(gcf);

% COMPARE SESSION LOCAL VARIATION BY PERIOD WITHIN CONDITIONS
figure('Name','Spike Cluster LvR by Period and Condition', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);       

for iCondition = 1:6
    subplot(3,2,iCondition);
    Condition_Index = abs(Condition-iCondition)<eps;
    boxplot(LvR(Condition_Index,:), pars.GROUPS);
    ylabel('LvR');
    title(['Condition ' num2str(iCondition)]);
end
suptitle('Spike Cluster LvR by Period and Condition');
savefig(gcf,'LvRbyPeriodandCondition.fig');
saveas(gcf,'LvRbyPeriodandCondition.jpeg');
delete(gcf);

% %% COMPARE PRE-POST LOCAL VARIATION CHANGES BY SESSION
% figure('Name','Spike Cluster LvR Changes by Session', ...
%        'Units','Normalized', ...
%        'Position',[0.1 0.1 0.8 0.8]);
%    
% LvRChange = LvR(:,3) - LvR(:,1);
% 
% boxplot(LvRChange,D_PRE.Rat);
% ylabel('\DeltaLvR');
% title('Spike Cluster LvR Changes by Session');
% savefig(gcf,'LvRChangesbySession.fig');
% saveas(gcf,'LvRChangesbySession.jpeg');

% COMPARE PRE-POST LOCAL VARIATION CHANGES BY CONDITION
figure('Name','Spike Cluster LvR Changes by Condition (Boxplot)', ...
       'Units','Normalized', ...
       'Position',[0.1 0.1 0.8 0.8]);

LvRChange = LvR(:,2) - LvR(:,1);
boxplot(LvRChange,Condition);
ylabel('\DeltaLvR');
title('Spike Cluster LvR Changes by Condition');
savefig(gcf,'LvRChangesbyCondition.fig');
saveas(gcf,'LvRChangesbyCondition.jpeg');

figure('Name','Spike Cluster LvR Changes by Condition (Histogram)', ...
       'Units','Normalized', ...
       'Position',[0.1 0.1 0.8 0.8]);
for iCondition = 1:6
    subplot(3,2,iCondition);
    Condition_Index = abs(Condition-iCondition)<eps;
    histogram(LvRChange(Condition_Index),-1:0.1:1);
    ylabel('Count'); xlabel('\DeltaLvR');
    xlim([-1 1]);
    title(['Condition ' num2str(iCondition)]);
end
suptitle('Spike Cluster LvR Changes by Condition');
savefig(gcf,'LvRChangesbyConditionHist.fig');
saveas(gcf,'LvRChangesbyConditionHist.jpeg');
delete(gcf);

% COMPARE PRE-POST LOCAL VARIABILITY CHANGES BY ANIMAL BY CONDITION
figure('Name','Change in LvR by Animal and Condition', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);

Animal_List = unique(Animal);
Animal_List = reshape(Animal_List,1,numel(Animal_List));

row = ceil(sqrt(numel(Animal_List)));
col = row;

for iA = 1:numel(Animal_List)
    subplot(row,col,iA);
    Animal_Index = abs(Animal - Animal_List(iA)) < eps;
    boxplot(LvRChange(Animal_Index),Condition(Animal_Index));
    title(['Animal ' num2str(Animal_List(iA))]);
    xlabel('Condition'); ylabel('\DeltaLvR');
end
suptitle('\DeltaLvR by Animal and Condition');

savefig(gcf,'LvRChangesByAnimal.fig');
saveas(gcf,'LvRChangesByAnimal.jpeg');
delete(gcf);

% GENERATE COMBINED LVR AND RATE FIGURE
LogRateChange = LogRate(:,2) - LogRate(:,1);

figure('Name','LvR and Rate Changes by Condition (Violin Plot)', ...
       'Units','Normalized', ...
       'Color','w',...
       'Position',[0.25 0.075 0.40 0.8]);
   
subplot(2,1,1);
c = colormap('parula');
distributionPlot(RateChange,'groups',Condition, ...
                               'variableWidth', true, ...
                               'colormap', c, ...
                               'histOpt', 1.1, ...
                               'divFactor', 0.8, ...
                               'addBoxes', 0, ...
                               'addSpread',1);
                        
title('\DeltaRate_{spike} by Treatment');
ylabel('\Deltaspikes/sec');
xlabel('Treatment');
% ylim([-5 5]);
ylim([-25 25]);

subplot(2,1,2);
distributionPlot(LvRChange,'groups',Condition, ...
                            'variableWidth', true, ...
                            'colormap', c, ...
                            'histOpt', 1.1, ...
                            'divFactor', 0.8, ...
                            'addBoxes', 0, ...
                            'addSpread',1);
                        
title('\DeltaLvR by Treatment');
ylabel('\DeltaLvR');
xlabel('Treatment');
ylim([-1 1]);

savefig(gcf,'ViolinGlobalChanges.fig');
saveas(gcf,'ViolinGlobalChanges.jpeg');
delete(gcf);

% GENERATE GLOBAL RATE FIGURES - BY TREATMENT & BY ANIMAL
NumSpikesTotal = zeros(size(AppendedSpikeData{1,1},1),1);
DurationTotal = zeros(size(AppendedSpikeData{1,1},1),1);
for iEpoch = 1:6
    NumSpikesTotal = NumSpikesTotal + AppendedSpikeData{iEpoch}.NumSpikes;
    DurationTotal = DurationTotal + AppendedSpikeData{iEpoch}.Duration;
end
RateTotal = NumSpikesTotal./DurationTotal;

% Move variables to base workspace
mtb(NumSpikesTotal);
mtb(DurationTotal);
mtb(RateTotal);

figure('Name','Fig 2: Total Rate Distributions', ...
       'Units','Normalized', ...
       'Color','w', ...
       'Position',[0.25 0.075 0.40 0.80]);
   
subplot(2,1,1);
boxplot(log(RateTotal),Animal);
title('Total Rate by Animal');
ylabel('log(spikes/sec)');
xlabel('Animal');

subplot(2,1,2);
boxplot(log(RateTotal),Condition);
title('Total Rate by Treatment');
ylabel('log(spikes/sec)');
xlabel('Treatment');

savefig(gcf,'TotalRateChangesbyAnimalorTreatment.fig');
saveas(gcf,'TotalRateChangesbyAnimalorTreatment.jpeg');

 
end