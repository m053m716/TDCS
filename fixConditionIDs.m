function T = fixConditionIDs(T)
%FIXCONDITIONIDS Ensure ConditionIDs are scaled properly [1,3] not [1,6]
%
%  T = fixConditionIDs(T);
%  T : Any table containing the `ConditionID` and `BlockID` variables

if max(T.ConditionID) <= 3
   return; % Then do nothing
end

if ismember('Rat',T.Properties.VariableNames)
   blockNameID = 'Rat';
elseif ismember('Name',T.Properties.VariableNames)
   blockNameID = 'Name';
else
   blockNameID = 'BlockID';
end

if ismember('Condition',T.Properties.VariableNames)
   cNameID = 'Condition';
else
   cNameID = 'ConditionID';
end

U = unique(T.(blockNameID));
if ~iscell(U)
   U = num2cell(U);
end
CurrentID = nan(size(T,1),1);
for ii = 1:numel(U)
   idx = ismember(T.(blockNameID),U{ii});
   C = T.(cNameID)(idx);
   CurrentID(idx) = rem(C,2).*-2+1;
   T.(cNameID)(idx) = ceil(C./2);
end
T = [T, table(CurrentID)];
T = movevars(T, 'CurrentID', 'Before', 'EpochID');

end