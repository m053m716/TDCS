function [C,t,mask] = compute_xcorr_FR(T,blockID,varargin)
%COMPUTE_XCORR_FR  Computes cross-correlation for pairs of spike trains
%
%  C = compute_xcorr_FR(T); % Runs for all blockID in table
%  C = compute_xcorr_FR(T,blockID); % Runs for specific blockID
%  C = compute_xcorr_FR(T,blockID,'NAME',value,...);
%  --> Parameters are set from defs.XCorr
%
%  [C,t,mask] = ...
%  --> Returns `t` : Times corresponding to samples in each C.r cell
%  --> Returns `mask` : RMS-threshold mask
%
%  -- Inputs --
%   -> T : `data.binned_spikes` from `loadDataStruct`; table of spike rate
%   -> blockID : (Optional) If not specified, runs for all unique blockID
%                 --> Must be an element of T.BlockID
%
%  -- Output --
%   -> C : Table with similar columns as T, but more rows
%           (accounting for pairwise comparisons)

pars = parseParameters('XCorr',varargin{:});
addHelperRepos(); % Make sure helper repos are on path

if nargin < 2
   blockID = unique(T.BlockID);
elseif ~iscategorical(blockID)
   blockID = categorical(blockID);
end

if numel(blockID) > 1
   C = [];
   for i = 1:numel(blockID)
      C = [C; compute_xcorr_FR(T,blockID(i))];  %#ok<AGROW>
   end
   return;
end

% Reduce to just this Block for pairwise comparisons
T = T(ismember(T.BlockID,blockID),:);
nRow = sum(1:(size(T,1)-1)); % Total # comparisons
BlockID = repmat(T.BlockID(1),nRow,1);
AnimalID = repmat(T.AnimalID(1),nRow,1);
ConditionID = repmat(T.ConditionID(1),nRow,1);
Channel = repmat(T.Channel(1),nRow,1); % For maintaining type
Channel_Pair = repmat(T.Channel(1),nRow,1);
CurrentID = repmat(T.CurrentID(1),nRow,1);
r = cell(nRow,1);

% Compute channelwise thresholds/rate conversions
nCh = size(T.Rate,1);
chRate = cell(nCh,1);
for iCh = 1:nCh
   x = pars.TRANSFORM_FCN(T.Rate{iCh});
   xTh = nanmedian(x) + pars.NSD_THRESH*nanstd(x);
   x(x > xTh) = nan;
   y = (x-nanmean(x))/nanstd(x);
   Z = math__.chunkVector2Matrix(y,pars.N,pars.OVERLAP);
   sd_Z = nanmedian(nanstd(Z,[],1));
   mu_Z = nanmedian(nanmean(Z,1));
   chRate{iCh,1} = (Z - mu_Z) ./ sd_Z;
end
off = ceil(pars.N/2);

% Get mask and corresponding time (minutes) for data
mask = T.mask{1};
nSamples = numel(mask);
bw = T.Properties.UserData.DS_BIN_DURATION;
t = 0:bw:(bw*(nSamples-1));
% Convert to minutes (DS_BIN_DURATION is in seconds):
t = t ./60; 

mu = zeros(1,nSamples);
s = pars.N - pars.OVERLAP;
S = nSamples-pars.N+1;

% Iterate on all channel pairs
iRow = 0;
for i = 1:nCh
   % Use vector assignment for non-computed elements
   nThis = nCh - i;
   chVec = (iRow+1):(iRow+nThis);   
   Channel(chVec) = repmat(T.Channel(i),nThis,1);
   Channel_Pair(chVec) = T.Channel((i+1):nCh);
   for j = (i+1):nCh
      % Increment current row index tracker
      iRow = iRow + 1;
      
      % Pre-allocate correlation matrix
      r{iRow,1} = zeros(1,nSamples);
      for k = 1:s:S
         tmp = nancov(chRate{i}(:,k),chRate{j}(:,k));
         r{iRow,1}(1,k+off) = tmp(1,2);
      end
      
      % Set a cap to scale between zero and 1 for comparison
      m = nanmax(abs(r{iRow,1}));
      r{iRow,1} = r{iRow,1}./m;

      
      mu = mu + r{iRow,1}./nRow; % To be subtracted at end
   end   
end
% Remove mean correlation from array (we are interested in temporal
% changes; therefore, we want each correlation time-series to have
% zero-mean so they can be compared. By default, they should approximately
% scale within the same bounds).
r = cellfun(@(x)x-mu,r,'UniformOutput',false);

C = table(BlockID,AnimalID,CurrentID,ConditionID,Channel,Channel_Pair,r);
C.Properties.Description = 'Table of channel-wise cross-correlations';
C.Properties.UserData = pars; % Save parameters
C.Properties.UserData.BINNED_SPIKES_TABLE_PARS = T.Properties.UserData;
C.Properties.UserData.TABLE_TYPE = 'xcorr_FR';


end