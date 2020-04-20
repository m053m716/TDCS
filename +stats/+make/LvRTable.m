function S = LvRTable(T)
%LVRTABLE  Makes table for computing LvR statistics
%
%  S = stats.make.LvRTable(T);
%
%  -- Inputs --
%  T : Table returned by `loadDeltaLvR`
%     
%     ```
%        data = loadDataStruct();
%        S = stats.make.LvRTable(data.LvR);
%        [rm,ranovatbl,A,C,D] = stats.fit.LvR_RM_Model(S);
%     ```
%
%  -- Output --
%  S : Stats table for repeated-measures LvR model


% u = unique(T.AnimalID);
% % Iterate for each animal
% if numel(u) > 1
%    S = table.empty;
%    for i = 1:numel(u)
%       S = [S; stats.make.LvRTable(T(T.AnimalID==u(i),:))]; %#ok<AGROW>
%    end
%    return;
% end
% 
% % Iterate for each polarity
% u = unique(T.CurrentID);
% if numel(u) > 1
%    S = table.empty;
%    for i = 1:numel(u)
%       S = [S; stats.make.LvRTable(T(T.CurrentID==u(i),:))]; %#ok<AGROW>
%    end   
%    return;
% end
% 
% % Remove invalid data
% T = T(~isnan(T.LvR),:);
% if isempty(T)
%    S = table.empty;
%    return;
% end

% Get grouping variables indices
% groupingVars = {'BlockID','AnimalID','ConditionID','CurrentID','Channel'};
groupingVars = {'BlockID','AnimalID','ConditionID','CurrentID'};
idx = ismember(T.Properties.VariableNames,groupingVars);

% Get subscripting matrix
subs = nan(size(T,1),2); % Initialize subscripting matrix variable
[subs(:,1),TID] = findgroups(T(:,idx));

% % Set the `type` of model effects
% if ~iscategorical(TID.CurrentID)
%    TID.BlockID = categorical(TID.BlockID);
%    TID.AnimalID = categorical(TID.AnimalID);
%    TID.ConditionID = ordinal(TID.ConditionID);
%    TID.CurrentID = categorical(TID.CurrentID,[-1,1],{'Anodal','Cathodal'});
%    TID.Channel = categorical(TID.Channel);
% end
iCurID = find(ismember(TID.Properties.VariableNames,'CurrentID'),1,'first');
TID.Properties.VariableNames{iCurID} = 'Polarity';
iConID = find(ismember(TID.Properties.VariableNames,'ConditionID'),1,'first');
TID.Properties.VariableNames{iConID} = 'Intensity';

subs(:,2) = findgroups(T.EpochID,T.Channel);
% subs(:,2) = findgroups(T.EpochID);

LvR = accumarray(subs,T.LvR,[max(subs(:,1)),max(subs(:,2))],@(x)(x),nan);
S = [TID, table(LvR)];
S(any(isnan(S.LvR),2),:) = [];
idxLvR = find(ismember(S.Properties.VariableNames,'LvR'),1,'first');
S.Properties.VariableDescriptions{idxLvR} = 'LvR: Measure of variability (responses by Channel, Epoch)';
S.Properties.Description = 'Repeated-Measures LvR Table: Responses cycle by Channel, then repeat by Epoch (columns of LvR)';
S.Properties.UserData.Design = 'Time*Channel';
% S.Properties.VariableDescriptions{idxLvR} = 'LvR: Variability (responses by Epoch)';
% S.Properties.Description = 'Repeated-Measures LvR Table: Responses cycle by Epoch (columns of dLvR)';
% S.Properties.UserData.Design = 'Time';

% % Reorganize and subtract control conditions
% % If this polarity does not have a 0-mA control, then skip animal/polarity
% % combination
% iControl = ismember(S.Intensity,ordinal(1,{'0.0 mA','0.2 mA','0.4 mA'},[1,2,3]));
% if sum(iControl) == 0
%    S = table.empty;
%    return;
% else
%    c = S(iControl,:);
%    S(iControl,:) = [];
% end
% 
% if ismember('Channel',S.Properties.VariableNames)
%    uCh = unique(S.Channel);
%    for i = 1:numel(uCh)
%       iCh_S = S.Channel == uCh(i);
%       iCh_c = c.Channel == uCh(i);
%       S.dLvR(iCh_S,:) = S.dLvR(iCh_S,:) - repmat(mean(c.dLvR(iCh_c,:),1),sum(iCh_S),1);
%    end
% else
%    S.dLvR = S.dLvR - repmat(mean(c.dLvR,1),size(S,1),1);
%    S.Properties.UserData.Design = 'Time*Channel';
% end
% 
% S.Intensity = droplevels(S.Intensity,{'0.0 mA'});

end