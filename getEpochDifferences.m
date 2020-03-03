function D = getEpochDifferences(S,varName,transformation,varNameOut)
%GETEPOCHDIFFERENCES  Returns differences between consecutive epochs
%
%  D = getEpochDifferences(S,varName);
%  --> S : Full data table from `getGrandEpochTable_Spikes`
%  --> varName : Variable (e.g. 'Rate' or 'Regularity')

if nargin < 2
   varName = 'Rate';
end

if nargin < 3
   transformation = @(x)log(x);
end

if nargin < 4
   varNameOut = '';
end

if isempty(transformation)
   data = S.(varName);
else
   data = transformation(S.(varName));
end

epoch = 2:6;
N = size(S,1);
Animal = nan(N,1);
Condition = nan(N,1);
Rat = cell(N,1);
Block = cell(N,1);
Epoch = nan(N,1);
Channel = nan(N,1);
Cluster = nan(N,1);
Orig = nan(N,1);
Diffed = nan(N,1);

for e = epoch
   iCur = S.Epoch == e;
   iPast = S.Epoch == (e-1);
   
   % Should be ordered to correspond 1:1
   Animal(iCur) = S.Animal(iCur);
   Condition(iCur) = S.Condition(iCur);
   Rat(iCur) = S.Rat(iCur);
   Block(iCur) = S.Block(iCur);
   Epoch(iCur) = S.Epoch(iCur);
   Channel(iCur) = S.Channel(iCur);
   Cluster(iCur) = S.Cluster(iCur);
   Orig(iCur) = data(iCur);
   Diffed(iCur) = data(iCur) - data(iPast);
end

D = table(Animal,Condition,Rat,Block,Epoch,Channel,Cluster,Orig,Diffed);
D(isnan(D.Orig),:) = [];
D.Properties.VariableNames{end-1} = varName;

if isempty(varNameOut)
   D.Properties.VariableNames{end} = sprintf('delta_%s',varName);
else
   D.Properties.VariableNames{end} = varNameOut;
end

end