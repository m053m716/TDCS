function [RateStats,Comparisons] = SpikeSeries2Stats(SpikeSeries,varargin)
% SPIKESERIES2STATS Extract statistics from spike rate series
%
%  RateStats = SPIKESERIES2STATS(SpikeSeries)
%  --> Uses `pars` from `defs.SpikeStats()`
%
%  --------
%   INPUTS
%  --------
%  SpikeSeries :  1 x 6 cell array. Each cell contains a table, in which
%                 each unit is a row, with identification metadata and
%                 spike times converted to rates using the adaptive kernel
%                 bandwidth optimization method of Shimazaki and Shinomoto
%                 (2010). See SSVKERNEL.m. Y is the column containing
%                 rates; T is the column containing the times where the
%                 rate is sampled.
%
%  varargin :     (Optional) 'NAME', value input argument pairs.
%
%  --------
%   OUTPUT
%  --------
%  RateStats   :  1 x 6 cell array of tables. Each table contains
%                 statistics for a given unit: the average rate during that
%                 period and the variance. Prior to taking mean and
%                 variance, rates are transformed using square root
%                 transformation to help them become approximately normally
%                 distributed.
%
%                 -> mu: Average square root IFR for unit during that epoch
%                 -> sigsq: Variance square root IFR
%
%  Comparisons :  Table containing outputs for each unit comparing the
%                 first pars.BASAL session to the stimulus session (cell 1 vs
%                 cell 2). Comparisons are made using the Wilcoxon rank sum
%                 test, which tests the null hypothesis that the data in
%                 pars.BASAL and pars.STIM sessions are samples from continuous
%                 distributions with equal medians, and allows the sample
%                 vectors to take different lengths.
%
%                 -> h : Hypothesis test. h = 1 rejects the null hypothesis
%                 -> p : p-value from z-statistic approximated by Wilcoxon
%                        rank sum test.


% DEFAULT CONSTANTS
switch nargin
   case 0
      pars = defs.SpikeStats();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.SpikeStats();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% GET MEAN AND VARIANCE
nEpoch = numel(SpikeSeries);
nUnits = size(SpikeSeries{pars.BASAL},1);

Name = SpikeSeries{pars.BASAL}.Name;
Channel = SpikeSeries{pars.BASAL}.Channel;
Cluster = SpikeSeries{pars.BASAL}.Cluster;
Animal = SpikeSeries{pars.BASAL}.Animal;
Condition = SpikeSeries{pars.BASAL}.Condition;

RateStats = cell(1,nEpoch);

for iEpoch = 1:nEpoch
   mu = nan(nUnits,1);
   sigsq = nan(nUnits,1);
   for iUnit = 1:nUnits
      mu(iUnit) = mean(sqrt(SpikeSeries{iEpoch}.Y{iUnit}));
      sigsq(iUnit) = var(sqrt(SpikeSeries{iEpoch}.Y{iUnit}));
   end
   RateStats{iEpoch} = table(Name,Channel,Cluster,Animal,Condition,mu,sigsq);
end

% MAKE COMPARISONS BETWEEN BASAL AND STIM

p = nan(nUnits,1);
h = nan(nUnits,1);
direction = repmat({'same'},nUnits,1);
for iUnit = 1:nUnits
   if ~any(isnan(SpikeSeries{pars.BASAL}.Y{iUnit})) && ...
         ~any(isnan(SpikeSeries{pars.STIM}.Y{iUnit}))
      x = sqrt(SpikeSeries{pars.BASAL}.Y{iUnit});
      y = sqrt(SpikeSeries{pars.STIM}.Y{iUnit});
      [p(iUnit),h(iUnit)] = ranksum(x,y,'alpha',0.01/nUnits);
      if h(iUnit) > 0
         if median(x) > median(y)
            direction{iUnit} = 'decrease';
         else
            direction{iUnit} = 'increase';
         end
      end
   end
end
vec = ~isnan(p); % Remove invalid comparisons
dispnames = find(~vec);
for iD = 1:numel(dispnames)
   fprintf(1,'\nSpikeSeries row %d (%s) is invalid.\n',...
      dispnames(iD),SpikeSeries{1}.Name{dispnames(iD)});
   
   % Note: used this to find rows where rate estimates were NaN during both
   %       epochs. If both were NaN, then they were specified as belonging
   %       to the same distribution during those epochs; if one or the
   %       other was NaN, then they were specified as different.
end

Comparisons = table(Name,Channel,Cluster,...
                    Animal,Condition,h,p,direction);
% Comparisons.Properties.VariableNames = {'Name','Channel','Cluster',...
%    'Animal','Condition','h','p'};

if exist(pars.FILENAME,'file')==0
   writetable(Comparisons,pars.FILENAME);
end

end