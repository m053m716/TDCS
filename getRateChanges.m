function [cAnimal,cCondition,cTotal] = getRateChanges(UnitData,AppendedSpikeData)
%GETRATECHANGES   Get number of units for each tDCS condition that change
%
%  [cAnimal,cCondition,cTotal] = GETRATECHANGES(UnitData,AppendedSpikeData)

% GET PARAMETERS
Y = UnitData.AvgRateSTIM - UnitData.AvgRateBASAL;
TotalAnimal = AppendedSpikeData{1,1}.Animal;
TotalCondition = AppendedSpikeData{1,1}.Condition;

% GET CHANGES BY ANIMAL
Animal = unique(UnitData.Animal);
nA = numel(Animal);
Decreases = zeros(nA,1);
Increases = zeros(nA,1);
TotalUnits = zeros(nA,1);

for iA = 1:nA
    TotalUnits(iA) = sum(ismember(TotalAnimal,Animal(iA)));
    Decreases(iA) = sum(Y(ismember(UnitData.Animal,Animal(iA)))<0);
    Increases(iA) = sum(Y(ismember(UnitData.Animal,Animal(iA)))>0);
end

cAnimal = table(Animal,TotalUnits,Decreases,Increases);

% GET CHANGES BY CONDITION
Condition = unique(UnitData.Condition);
nC = numel(Condition);
Decreases = zeros(nC,1);
Increases = zeros(nC,1);
TotalUnits = zeros(nC,1);

for iC = 1:nC
    TotalUnits(iC) = sum(ismember(TotalCondition,Condition(iC)));
    Decreases(iC) = sum(Y(ismember(UnitData.Condition,Condition(iC)))<0);
    Increases(iC) = sum(Y(ismember(UnitData.Condition,Condition(iC)))>0);
end

cCondition = table(Condition,TotalUnits,Decreases,Increases);

% GET CHANGES BY BOTH
Condition = repmat(Condition,nA,1);
tempAnimal = [];
TotalUnits = zeros(nC*nA,1);
Decreases = zeros(nC*nA,1);
Increases = zeros(nC*nA,1);

ii = 1;
for iC = 1:nC
    for iA = 1:nA
        tempAnimal = [tempAnimal; Animal(iA)]; %#ok<AGROW>
        TotalUnits(ii) = sum(ismember(TotalCondition,Condition(iC)) & ...
                             ismember(TotalAnimal,Animal(iA)));
        Decreases(ii) = sum(Y(ismember(UnitData.Condition,Condition(iC))...
                            & ismember(UnitData.Animal,Animal(iA)))<0);
        Increases(ii) = sum(Y(ismember(UnitData.Condition,Condition(iC))...
                            & ismember(UnitData.Animal,Animal(iA)))>0);
        ii = ii + 1;
    end    
end
Animal = tempAnimal; clear tempAnimal

cTotal = table(Condition,Animal,TotalUnits,Decreases,Increases);

end