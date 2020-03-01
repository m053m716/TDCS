function C = GetExclusionCounts(F,varargin)
%GETEXCLUSIONCOUNTS   Get exclusion/inclusion/detected/clustered counts
%
%   C = GETEXCLUSIONCOUNTS(F,'NAME',value,...);

% Parse inputs
pars = parseParameters('Spikes',varargin{:});

% GET COUNTS FOR EACH FILE IN F
C = [];
for iF = 1:numel(F)
    temp = fullfile(F(iF).block,[F(iF).base '_ad-PT_SPC_Clusters']);
    C = [C; countUnits('DIR',temp,'SAVE',true)]; %#ok<AGROW>
end

% SET EXCLUSIONS BASED ON RATE
C(C.Rate < pars.MIN_RATE & ismember(C.Status,'inc'),:).Status = ...
    repmat({'exc'},sum(C.Rate< pars.MIN_RATE & ...
    ismember(C.Status,'inc')),1);

end