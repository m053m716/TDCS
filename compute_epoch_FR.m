function varargout = compute_epoch_FR(T,epoch_indices,varargin)
%COMPUTE_EPOCH_FR  Compute FR for a given epoch or set of epochs
%
%  epoch_FR = compute_epoch_FR(T,1);
%  -> Returns single column vector for "Pre" epoch
%
%  [pre,stim,post] = compute_epoch_FR(T,1:3);
%  -> Returns as 3 separate column vector variables
%
%  Note that all returned rates are square-root transformed
%
%  Input : `T` -- Table that is the "binned_spikes" (e.g.
%                 data.binned_spikes from `loadDataStruct()`)

pars = parseParameters('Spikes',varargin{:});

if nargin < 2
   epoch_indices = 1:numel(pars.EPOCH_ONSETS); % Default is all epochs
end

if isstruct(T)
   T = T.binned_spikes;
end

vec = getEpochSampleIndices(T,epoch_indices,pars);
varargout = cell(1,numel(epoch_indices));
for i = 1:numel(epoch_indices)
   varargout{i} = cellfun(@(x,m,v)sqrt(x(v(~m(v)))),...
      T.Rate,T.mask,vec(:,i),'UniformOutput',false);
end

if (nargout == 1) && (numel(epoch_indices) > 1)
   varargout = {varargout};
end

end