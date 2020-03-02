function S = getGrandEpochTable_Spikes(AppendedSpikeData)
%GETGRANDEPOCHTABLE_SPIKES  Concatenates "epoch" data into larger table
%
%  S = getGrandEpochTable_Spikes(AppendedSpikeData);

N = size(AppendedSpikeData{1},1);
M = numel(AppendedSpikeData);
Epoch = repmat(1:M,N,1);
Epoch = Epoch(:);

S = [];

for i = 1:M
   S = [S; AppendedSpikeData{i}]; %#ok<AGROW>
end

S = [S, table(Epoch)];

end