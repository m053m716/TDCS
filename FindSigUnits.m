function [PD,SigUnits] = FindSigUnits(SpikeTrainData,varargin)
%FINDSIGUNITS Find units with significant rate change in tDCS analysis
%
%  [PD,SigUnits] = FINDSIGUNITS(SpikeTrainData)
%  --> Loads parameters from `pars.Spikes()`
%
%  [PD,SigUnits] = FINDSIGUNITS(SpikeTrainData,pars)
%  --> Load `pars` directly
%
%  [PD,SigUnits] = FINDSIGUNITS(SpikeTrainData,'NAME',value,...)
%  --> Loads parameters from `pars.Spikes()`
%     --> Allows to set 'NAME', value parameter pairs
%
%   --------
%    INPUTS
%   --------
%   SpikeTrainData  :       1x6 cell where cell {1,1} is the PRE-stim spike
%                           series table and cell {1,2} is the STIM data.
%
%   --------
%    OUTPUT
%   --------
%     PD            :       Output of fit Gamma PDF for each ISI.
%
%   SigUnits        :       List of units to include for significant
%                           changes.

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

% LOOP THROUGH EACH UNIT AND FIT ISI GAMMA DISTRIBUTION
X = SpikeTrainData{1,1};
Y = SpikeTrainData{1,2};
PD = cell(1,2);
nX = size(X,1);
PD{1,1} = cell(nX,1);
PD{1,2} = cell(nX,1);

for iX = 1:nX
    % Get PRE-STIM ISI distribution  
    x = diff(find(X.Train{iX})/X.FS(iX))*1e3;
    x = x(x <= pars.MAX_ISI);
    y = diff(find(Y.Train{iX})/Y.FS(iX))*1e3;
    y = y(y <= pars.MAX_ISI);
    
    if (numel(x) >= MIN_SPIKES_X && numel(y) >= MIN_SPIKES_Y)
        PD{1,1}{iX,1} = fitdist(x,pars.DIST_TO_FIT);
        PD{1,2}{iX,1} = fitdist(y,pars.DIST_TO_FIT);
    else
        PD{1,1}{iX,1} = nan;
        PD{1,2}{iX,1} = nan;
    end
end

% FROM EACH GAMMA DISTRIBUTION, CHECK IF THERE IS A SIGNIFICANT CHANGE
SigUnits = false(nX,1);
for iX = 1:nX
    if (~isa(PD{1,1}{iX,1},'prob.GammaDistribution') || ...
        ~isa(PD{1,2}{iX,1},'prob.GammaDistribution'))
        continue
    end
    
    CI_pre = paramci(PD{1,1}{iX,1});
    CI_stim = paramci(PD{1,2}{iX,1});
    
    sigdif = [min(CI_pre) > max(CI_stim), ...
              min(CI_stim) > max(CI_pre)];
          
    SigUnits(iX) = any(sigdif);    
end


end