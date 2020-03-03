function F = addAssignmentToOrganizationStruct(F)
%ADDASSIGNMENTTOORGANIZATIONSTRUCT  Adds group, animal ID to org struct
%
%  F = addAssignmentToOrganizationStruct(F);

load(fullfile(defs.Spikes('DIR'),defs.Spikes('ASSIGNMENT_FILE')),...
   'Assignment');

currentID_assignment = defs.Experiment('CURRENT_ID');

sessionID = {F.name}';
sessionID = cellfun(@(x)x(6:7),sessionID,'UniformOutput',false);
sessionID = str2double(sessionID);

idx = nan(size(F));
vec = true(size(idx));
for i = 1:numel(F)
   tmp = find(Assignment.SessionID == sessionID(i),1,'first');
   if isempty(tmp)
      vec(i) = false;
   else
      idx(i) = tmp;
   end
end

animalID = nan(size(idx));
conditionID = nan(size(idx));

animalID(vec) = Assignment.Animal(idx(vec));
conditionID(vec) = Assignment.Condition(idx(vec));
currentID = currentID_assignment(conditionID);

animalID = num2cell(animalID);
conditionID = num2cell(conditionID);
currentID = num2cell(currentID);

[F.animalID] = deal(animalID{:});
[F.conditionID] = deal(conditionID{:});
[F.currentID] = deal(currentID{:});

end