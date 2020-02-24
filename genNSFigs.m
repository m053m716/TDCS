function genNSFigs(NSData,AppendedSpikeData,varargin)
%% GENNSFIGS    Generate stationarity statistics figures for tDCS analysis.
%
%   GENNSFIGS(NSData,AppendedSpikeData,'NAME',value,...)
%
%   By: Max Murphy  v1.0    07/20/2017  Original version (R2017a)

%% DEFAULTS
CMAP = 'parula';
XLIM = [0 300];
HISTOPT = 1.0;
DF = 0.95;
PERIOD = 2;

%% PARSE VARARGIN
for iV = 1:2:numel(varargin)
    eval([upper(varargin{iV}) '=varargin{iV+1};']);
end

%% FIG 5b) NS ONSET FIG
NS_START = NSData.NS_START(~isnan(NSData.NS_START));
Condition = NSData.Condition(~isnan(NSData.NS_START));

figure('Name','Nonstationarity Onset', ...
       'Color', 'w', ...
       'Units','Normalized', ...
       'Position', [0.4 0.4 0.4 0.4]);
   
c = colormap(CMAP);

distributionPlot(NS_START,'groups',Condition, ...
                       'variableWidth', true, ...
                       'colormap', c, ...
                       'histOpt', HISTOPT, ...
                       'divFactor', DF, ...
                       'addBoxes', 0, ...
                       'addSpread',1, ...
                       'xyOri','flipped');

title('Time-to-onset of IFR nonstationarity');
ylabel('Treatment');
xlabel('Time (sec)');
xlim([0 300]);

savefig(gcf,'NonstationarityOnset.fig');
saveas(gcf,'NonstationarityOnset.jpeg');
delete(gcf);

%% FIG 5c) NS DURATION FIG
figure('Name','Nonstationarity Duration', ...
       'Color', 'w', ...
       'Units','Normalized', ...
       'Position', [0.3 0.3 0.4 0.4]);
   
c = colormap(CMAP);
% distributionPlot(NSData.NS_DUR,'groups',NSData.Condition, ...
%                    'variableWidth', true, ...
%                    'colormap', c, ...
%                    'histOpt', HISTOPT, ...
%                    'divFactor', DF, ...
%                    'addBoxes', 0, ...
%                    'addSpread',1, ...
%                    'xyOri','flipped');
boxplot(NSData.NS_DUR,NSData.Condition,...
        'PlotStyle','compact');

title('Duration of IFR nonstationarity');
xlabel('Treatment');
ylabel('Time (sec)');
ylim([0 300]);

savefig(gcf,'NonstationarityDuration.fig');
saveas(gcf,'NonstationarityDuration.jpeg');
delete(gcf);


%% FIG 5d) PROPORTIONS OF UNITS USED
% Get proportions etc.
uCondition = unique(Condition);
uCondition = reshape(uCondition,1,numel(uCondition));
nC = numel(uCondition);
CTotal = nan(nC,1);
CIncluded = nan(nC,1);
CNonstationary = nan(nC,1);
for iC = 1:nC
    CTotal(iC) = sum(abs(AppendedSpikeData{1,PERIOD}.Condition ...
                         - uCondition(iC)) < eps);
                     
    CIncluded(iC) = sum(abs(NSData.Condition - uCondition(iC))<eps);
    CNonstationary(iC) = sum(abs(NSData.Condition-uCondition(iC))<eps & ...
                         ~isnan(NSData.NS_START));
end

% Plot
figure('Name','Units Included and Nonstationarity Proportions', ...
       'Color', 'w', ...
       'Units','Normalized', ...
       'Position', [0.3 0.4 0.4 0.4]);
   
C = [CTotal, CIncluded, CNonstationary];
bar(uCondition,C);

xlabel('Treatment');
ylabel('Number of Units');

legend({'Total Units Isolated'; ...
        'Units > 5 spikes/sec during first 5-minutes of STIM'; ...
        'Units Demonstrating IFR Nonstationarity'});

 
savefig(gcf,'NSUnitsIncluded.fig');
saveas(gcf,'NSUnitsIncluded.jpeg');
delete(gcf); 

end