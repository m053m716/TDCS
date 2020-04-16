function T_LvR = compute_epoch_LvR(T,varargin)
%COMPUTE_EPOCH_LVR   Computes LvR by epoch (excludes masked segments)
%
%  T_LvR = compute_epoch_LvR(T);
%  T_LvR = compute_epoch_LvR(T,pars);
%  T_LvR = compute_epoch_LvR(T,'NAME',value,...);
%
%  -- Inputs --
%  T        :  Table with spike trains in 'Train' variable as sparse
%                     vectors sampled at rate in 'FS' variable.
%     --> Loaded using 
%        >> T = loadSpikeSeries_Table('D:\MATLAB\Data\tDCS');
%  e.g. `data.raw_spikes` in `main.m`
%
%  varargin :  Parameters struct or 'NAME',value input argument pairs to
%                 modify struct from `defs.Spikes`
%
%  -- Output --
%  T_LvR    :  Same as input except `Rate` variable is replaced by
%                 `LvR` variable, and the number of rows is multiplied by
%                 the total number of epochs 
%                 (by default: Pre; Stim; Post)

pars = parseParameters('Spikes',varargin{:});
nEpoch = numel(pars.EPOCH_ONSETS);
nRowOriginal = size(T,1);

BlockID = replicateColumnVar(T.BlockID,nEpoch);
AnimalID = replicateColumnVar(T.AnimalID,nEpoch);
ConditionID = replicateColumnVar(T.ConditionID,nEpoch);
CurrentID = replicateColumnVar(T.CurrentID,nEpoch);
EpochID = replicateColumnVar((1:nEpoch).',nRowOriginal,false);
Channel = replicateColumnVar(T.Channel,nEpoch);
Cluster = replicateColumnVar(T.Cluster,nEpoch);
FS = replicateColumnVar(T.FS,nEpoch);


N = nan(nEpoch*nRowOriginal,1);
LvR = nan(nEpoch*nRowOriginal,1);

% Get the epoch subset vector and make sure Mask is sampled at correct rate
vec = getEpochSampleIndices(T,1:nEpoch,pars);
% Mask = cellfun(@(C,fs)replicateColumnVar(C.',fs*pars.DS_BIN_DURATION),...
%    T.mask,num2cell(T.FS),'UniformOutput',false);

% Iterate on rows of original data table
h = waitbar(0,'Computing LvR...');
iRow = 0;
for ii = 1:nRowOriginal   
   train = T.Train{ii};
   % Get Mask at the correct sample rate:
%    Mask = replicateColumnVar(T.mask{ii},T.FS(ii)*pars.DS_BIN_DURATION).';
%    Mask = replicateColumnVar(T.fine_mask{ii},T.FS(ii));
   Mask = repmat(T.fine_mask{ii},T.FS(ii),1);
   Mask = (Mask(:)).';
   for iEpoch = 1:nEpoch
      iRow = iRow + 1;
      v = vec{ii,iEpoch};
      m = ~Mask(v);
      ts = find(train(v(m))) ./ T.FS(ii);
      LvR(iRow) = eqn.LvR(ts,pars.R);
      N(iRow) = numel(ts);
   end
   waitbar(ii/nRowOriginal);
end
delete(h);

T_LvR = table(BlockID,AnimalID,ConditionID,CurrentID,EpochID,Channel,Cluster,FS,N,LvR);
T_LvR.Properties.Description = ...
   ['Modified local coefficient of variation ' newline ...
    '`LvR` reflects spiking "regularity" within an epoch/channel/session'];
T_LvR.Properties.VariableDescriptions = {...
   'BlockID: Identifier for recording session'; ...
   'AnimalID: Identifier for rat'; ...
   'ConditionID: Identifier for current intensity'; ...
   'CurrentID: Identifier for current polarity'; ...
   'EpochID: Identifier for Pre|Stim|Post epoch'; ...
   'Channel: Microwire array channel identifier'; ...
   'Cluster: (Should all be 1 -- multi-unit) spike unit cluster'; ...
   'FS: Sample rate of original data record'; ...
   'N: Number of spikes in non-masked period of this epoch'; ...
   'LvR: Modified local coefficient of variation' ...
   };
T_LvR.Properties.UserData = pars;
T_LvR = setTableOutcomeVariable(T_LvR,'LvR');
T_LvR.TABLE_TYPE = 'LvR';
end