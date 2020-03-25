function UnitCounts = getExclusionSpikeTrains(SpikeTrainData,SpikeSeries,C)
%GETEXCLUSIONSPIKETRAINS   Get exclusions for spike trains
%
%   UnitCounts = GETEXCLUSIONSPIKETRAINS(SpikeTrainData,SpikeSeries,C
%
%   --------
%    INPUTS
%   --------
%   SpikeTrainData :    Output from LOADSPIKETRAINS
%
%   SpikeSeries   :     Output from SPIKETRAIN2SERIES
%  
%      C        :       Table of units with inclusion/cluster/detect
%                       status, obtained using COUNTUNITS.
%
%   --------
%    OUTPUT
%   --------
%    UnitCounts :       Exclusion counts structure, which has one field for
%                       counts by animal, a field for counts by
%                       animal and recording, and a field for counts by
%                       condition, a field for counts by condition and
%                       recording.

% DEFAULTS
UnitCounts = struct; % output table


% APPEND GROUP ASSIGNMENTS
if ~ismember({'Animal'},C.Properties.VariableNames)
    C = appendGA(C);
end
Animal = unique(C.Animal); nA = numel(Animal);
Condition = unique(C.Condition); nC = numel(Condition);

% MAKE TABLE FOR COUNTS BY ANIMALS
X = SpikeTrainData{1,1}; clear SpikeTrainData
Y = SpikeSeries{1,1}; clear SpikeSeries

Included = nan(nA,1);
Sorted = nan(nA,1);
Detected = nan(nA,1);
for iA = 1:nA
   % Counts
   Detected(iA,1) = sum(abs(C.Animal-Animal(iA))<eps);
   Sorted(iA,1) =  sum(abs(X.Animal-Animal(iA))<eps);
   Included(iA,1) = sum(abs(Y.Animal-Animal(iA))<eps);
end
Rat = Animal;
UnitCounts.animal = table(Rat,Detected,Sorted,Included);

% MAKE TABLE FOR COUNTS BY ANIMAL AND CONDITION
Included = nan(nA*nC,1);
Sorted = nan(nA*nC,1);
Detected = nan(nA*nC,1);
Rat = nan(nA*nC,1);
Treatment = nan(nA*nC,1);

ii = 0;
for iA = 1:nA
    for iC = 1:nC
        ii = ii + 1;
        Rat(ii) = Animal(iA);
        Treatment(ii) = Condition(iC);
        
        % Counts
        Detected(ii,1) = sum(abs(C.Animal-Animal(iA))<eps & ...
                             abs(C.Condition-Condition(iC))<eps);
        Sorted(ii,1) =  sum(abs(X.Animal-Animal(iA))<eps & ...
                             abs(X.Condition-Condition(iC))<eps);
        Included(ii,1) = sum(abs(Y.Animal-Animal(iA))<eps & ...
                             abs(Y.Condition-Condition(iC))<eps);
    end
end
UnitCounts.both = table(Rat,Treatment,Detected,Sorted,Included);

% MAKE TABLE FOR COUNTS BY CONDITION
Included = nan(nC,1);
Sorted = nan(nC,1);
Detected = nan(nC,1);
for iC = 1:nC
    % Counts
    Detected(iC,1) = sum(abs(C.Condition-Condition(iC))<eps);
    Sorted(iC,1) =  sum(abs(X.Condition-Condition(iC))<eps);
    Included(iC,1) = sum(abs(Y.Condition-Condition(iC))<eps);
end
Treatment = Condition;
UnitCounts.treatment = table(Treatment,Detected,Sorted,Included);


end