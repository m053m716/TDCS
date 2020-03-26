function [vec,ts] = getEpochSampleIndices(T,epochIndex,varargin)
%GETEPOCHSAMPLEINDICES  Return sample indices for a given epoch
%
%  vec = getEpochSampleIndices(T,epochIndex);
%  vec = getEpochSampleIndices(T,epochIndex,pars);
%  vec = getEpochSampleIndices(T,epochIndex,'NAME',value,...);
%
%  -- Inputs --
%     T  :  Table with variables 'N' and 'FS' that give # of samples used
%           to generate each datapoint, and the original record sample
%           rate, respectively.
%  epochIndex :   Index of the epoch to recover vector of sample indices
%
%  -- Output --
%  vec : Cell array corresponding to rows of `T`, with sample indexing for
%        the data samples corresponding to times defined for epoch
%        specified by `epochIndex`
%
%  (optional) ts : Times corresponding to samples in `vec`

if ~ismember(T.Properties.VariableNames,'N')
   error(['tDCS:' mfilename ':BadTableFormat'],...
      ['\n\t->\t<strong>[GETEPOCHSAMPLEINDICES]:</strong> ' ...
      'Missing table variable: `N`\n']);
end

if ~ismember(T.Properties.VariableNames,'FS')
   error(['tDCS:' mfilename ':BadTableFormat'],...
      ['\n\t->\t<strong>[GETEPOCHSAMPLEINDICES]:</strong> ' ...
      'Missing table variable: `FS`\n']);
end

% Iterate if multiple epochs given
if numel(epochIndex) > 1
   if nargout > 1
      error(['tDCS:' mfilename ':TooManyOutputs'],...
         ['\n\t->\t<strong>[GETEPOCHSAMPLEINDICES]:</strong> ' ...
         'Cannot request both outputs with multiple epochIndices\n']);
   end
   vec = [];
   for iEpoch = 1:numel(epochIndex)
      vec = horzcat(vec,...
         getEpochSampleIndices(T,epochIndex(iEpoch),varargin{:})); %#ok<AGROW>
   end
end

pars = parseParameters('EpochIndexing',varargin{:});

[N,iN,idx] = unique(T.N);
FS = T.FS(iN);
n = numel(N);
tStep = N ./ FS; % Yields timestep (seconds)
vec = cell(n,1);
ts = cell(n,1);
tStart = pars.EPOCH_ONSETS(epochIndex)*60; % Seconds
tStop = pars.EPOCH_OFFSETS(epochIndex)*60; % Seconds
for iU = 1:n
   vecTotal = round(tStep/2):tStep(iU):(95*60); % Time vector
   v = find(vecTotal>=tStart & vecTotal < tStop);
   t = vecTotal(v);
   vec(idx == iU,1) = {v};
   ts(idx == iU,1) = {t};
end

end