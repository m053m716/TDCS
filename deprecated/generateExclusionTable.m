function [C,E] = generateExclusionTable(C)
%GENERATEEXCLUSIONTABLE   Make formatted table for unit exclusions in TDCS study.
%
%   [C,E] = GENERATEEXCLUSIONTABLE(C)
%
%   --------
%    INPUTS
%   --------
%      C        :       Table of units with inclusion/cluster/detect
%                       status, obtained using COUNTUNITS.
%
%   --------
%    OUTPUT
%   --------
%      C        :       Same as input, but with appended conditions and
%                       animal numbers.
%
%      E        :       Exclusion counts structure, which has one field for
%                       counts by animal, a field for counts by
%                       animal and recording, and a field for counts by
%                       condition, a field for counts by condition and
%                       recording.

% DEFAULTS
E = struct; % output table

% APPEND GROUP ASSIGNMENTS
if ~ismember({'Animal'},C.Properties.VariableNames)
    C = appendGA(C);
end
Animal = unique(C.Animal); nA = numel(Animal);
Condition = unique(C.Condition); nC = numel(Condition);

% MAKE TABLE FOR COUNTS BY ANIMALS

Included = nan(nA,5);
Detected = nan(nA,5);
for iA = 1:nA
    % Counts
    Included(iA,1) =  sum(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'inc'));
    Detected(iA,1) = sum(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'clu'));
                    
    % Rate - mean
    Included(iA,2) =  mean(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'inc'),:).Rate);
    Detected(iA,2) = mean(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'clu'),:).Rate);
                    
    % Rate - std
    Included(iA,3) =  std(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'inc'),:).Rate);
    Detected(iA,3) = std(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'clu'),:).Rate);
                    
    % LvR - mean
    Included(iA,4) =  mean(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'inc'),:).Regularity);
    Detected(iA,4) = mean(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'clu'),:).Regularity);
                    
    % LvR - std
    Included(iA,5) =  std(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'inc'),:).Regularity);
    Detected(iA,5) = std(C(abs(C.Animal-Animal(iA))<eps & ...
                        ismember(C.Status,'clu'),:).Regularity); 
end
Rat = Animal;
E.animal = table(Rat,Detected,Included);

% MAKE TABLE FOR COUNTS BY ANIMAL AND CONDITION
Included = nan(nA*nC,5);
Detected = nan(nA*nC,5);
Rat = nan(nA*nC,1);
Treatment = nan(nA*nC,1);

ii = 0;
for iA = 1:nA
    for iC = 1:nC
        ii = ii + 1;
        Rat(ii) = Animal(iA);
        Treatment(ii) = Condition(iC);
        
        % Counts
        Included(ii,1) = sum(abs(C.Animal-Animal(iA))<eps & ...
                           ismember(C.Status,'inc') & ...
                           abs(C.Condition-Condition(iC))<eps);
        Detected(ii,1) = sum(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'clu') & ...
                            abs(C.Condition-Condition(iC))<eps);
                        
        % Rate - mean
        Included(ii,2) =  mean(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'inc') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Rate);
        Detected(ii,2) = mean(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'clu') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Rate);

        % Rate - std
        Included(ii,3) =  std(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'inc') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Rate);
        Detected(ii,3) = std(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'clu') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Rate);

        % LvR - mean
        Included(ii,4) =  mean(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'inc') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Regularity);
        Detected(ii,4) = mean(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'clu') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Regularity);

        % LvR - std
        Included(ii,5) =  std(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'inc') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Regularity);
        Detected(ii,5) = std(C(abs(C.Animal-Animal(iA))<eps & ...
                            ismember(C.Status,'clu') & ...
                            abs(C.Condition-Condition(iC))<eps,:).Regularity); 
        
    end
end
E.both = table(Rat,Treatment,Detected,Included);

% MAKE TABLE FOR COUNTS BY CONDITION
Included = nan(nC,5);
Detected = nan(nC,5);
for iC = 1:nC
    % Counts
    Included(iC,1) = sum(abs(C.Condition-Condition(iC))<eps & ...
                        ismember(C.Status,'inc'));
    Detected(iC,1) = sum(abs(C.Condition-Condition(iC))<eps & ...
                        ismember(C.Status,'clu'));
    
    % Rate - mean
    Included(iC,2) =  mean(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'inc'),:).Rate);
    Detected(iC,2) = mean(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'clu'),:).Rate);

    % Rate - std
    Included(iC,3) =  std(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'inc'),:).Rate);
    Detected(iC,3) = std(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'clu'),:).Rate);

    % LvR - mean
    Included(iC,4) =  mean(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'inc'),:).Regularity);
    Detected(iC,4) = mean(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'clu'),:).Regularity);

    % LvR - std
    Included(iC,5) =  std(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'inc'),:).Regularity);
    Detected(iC,5) = std(C(abs(C.Animal-Animal(iC))<eps & ...
                        ismember(C.Status,'clu'),:).Regularity);
end
Treatment = Condition;
E.treatment = table(Treatment,Detected,Included);


end