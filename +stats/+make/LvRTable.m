function S = LvRTable(T)
%LVRTABLE  Makes table for computing LvR statistics
%
%  S = stats.make.LvRTable(T);
%
%  -- Inputs --
%  T : Table returned by `loadDeltaLvR`
%
%  -- Output --
%  S : Stats table for repeated-measures LvR model

% Remove invalid data
T = T(~isnan(T.LvR),:);

% Get grouping variables indices
% groupingVars = {'BlockID','AnimalID','ConditionID','CurrentID','Channel'};
groupingVars = {'BlockID','AnimalID','ConditionID','CurrentID'};
idx = ismember(T.Properties.VariableNames,groupingVars);

% Get subscripting matrix
subs = nan(size(T,1),2); % Initialize subscripting matrix variable
[subs(:,1),TID] = findgroups(T(:,idx));

% Set the `type` of model effects
if ~iscategorical(TID.CurrentID)
   TID.BlockID = categorical(TID.BlockID);
   TID.AnimalID = categorical(TID.AnimalID);
   TID.ConditionID = ordinal(TID.ConditionID);
   TID.CurrentID = categorical(TID.CurrentID,[-1,1],{'Anodal','Cathodal'});
%    TID.Channel = categorical(TID.Channel);
end
subs(:,2) = findgroups(T.EpochID,T.Channel);
% subs(:,2) = findgroups(T.EpochID);

LvR = accumarray(subs,T.LvR,[max(subs(:,1)),max(subs(:,2))],@(x)(x),nan);
S = [TID, table(LvR)];
S(any(isnan(S.LvR),2),:) = [];
S.Properties.VariableDescriptions{5} = 'LvR: Measure of variability (responses by Channel, Epoch)';
S.Properties.Description = 'Repeated-Measures LvR Table: Responses cycle by Channel, then repeat by Epoch (columns of LvR)';
% S.Properties.VariableDescriptions{6} = 'LvR: Measure of variability (responses by Epoch)';
% S.Properties.Description = 'Repeated-Measures LvR Table: Responses cycle by Epoch (columns of LvR)';

end