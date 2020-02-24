function ISI_Response_Data = getISIresponders(SpikeTrainData,SigUnits,Assignment)
%GETISIRESPONDERS  Get rates for units that respond per ISI criteria
%
%  ISI_Response_Data = getISIresponders(SpikeTrainData,SigUnits,Assignment)

% GET RESPONSIVE UNITS
nEpoch= numel(SpikeTrainData);
Y = cell(1,nEpoch);

for iEpoch = 1:nEpoch
    X = SpikeTrainData{iEpoch}(SigUnits,:);
    R = nan(size(X,1),1);
    for iX = 1:size(X,1)
        R(iX) = numel(find(X.Train{iX}))/(numel(X.Train{iX})/X.FS(iX));
    end
    Y{1,iEpoch} = R;
end

Y = cell2mat(Y);

% ASSIGN ANIMAL/CONDITION
Names = SpikeTrainData{1,1}.Name(SigUnits);

Condition = nan(numel(Names),1);                   
Animal = nan(numel(Names),1);

keepvec = true(numel(Names),1);
for iN = 1:numel(Names)
    n = str2double(Names{iN}(6:7));
    ind = abs(Assignment.SessionID-n)<eps;
    if sum(ind)<1
        keepvec(iN) = false;
        continue;
    end
    Condition(iN) = Assignment.Condition(ind);
    Animal(iN) = Assignment.Animal(ind);    
end
Condition = Condition(keepvec);
Animal = Animal(keepvec);
Rate = Y(keepvec,:);

ISI_Response_Data = table(Animal,Condition,Rate);

end