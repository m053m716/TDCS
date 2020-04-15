function [glm,glmtbl,A,C,D] = LvR_LME_Model(S)
%LVR_LME_MODEL  Generates linear mixed-effects model
%
%  lme = stats.fit.LvR_LME_Model(S);
%  [lme,lmetbl,A,C,D] = stats.fit.LvR_LME_Model(S);
%
%  -- Inputs --
%  S : Table generated by `stats.make.LvRTable`
%
%  -- Output --
%  lme : Matlab `` object for running statistical
%        analysis of LvR distributions observed during Pre, Stim, and Post
%        epochs of the tDCS experiments.
%
%  [ranovatbl,A,C,D] : See documentation for `ranova()` Matlab function

N_EPOCH = numel(defs.Experiment('EPOCH_NAMES'));

nColumns = size(S.LvR,2);

numChannels = nColumns/N_EPOCH; % Three unique epochs: Pre, Stim, Post

if rem(numChannels,1) > 0
   error(['tDCS:' mfilename ':BadInputSize'],...
      ['\n\t->\t<strong>[TDCS.STATS.FIT.LVR_RM_MODEL]:</strong> ' ...
       'Data matrix # columns (%g) must be evenly-divisible by %g (epochs)\n'],...
       nColumns,N_EPOCH);
end

% Specify between-subject model terms
BetweenModel = sprintf('LvR_%g-LvR_%g~1+ConditionID*CurrentID',1,nColumns);
% BetweenModel = 'LvR_1-LvR_3 ~ 1 + CurrentID*ConditionID';

% Specify within-subject response terms
Time = repmat(1:N_EPOCH,numChannels,1);
Time = Time(:);
Channel = categorical(repmat((1:numChannels).',N_EPOCH,1));
WithinDesign = table(Time,Channel);
WithinModel = 'Channel*Time';

% Time = ordinal((1:N_EPOCH).');
% WithinDesign = table(Time);
% WithinModel = 'orthogonalcontrasts';

% Reorganize S
S = splitvars(S,'LvR');
S = S(3:end,:);

rm = fitrm(S,BetweenModel,...
   'WithinDesign',WithinDesign,...
   'WithinModel',WithinModel);
[ranovatbl,A,C,D] = ranova(rm);
disp(ranovatbl(2:(end-1),1:5));

end