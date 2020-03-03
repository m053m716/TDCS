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

% Rearrange elements of S
S = S(:,[9 1:8 10:end]);
S = S(:,[1 10 2:9 end]);
S = S(:,[1:4 11 5:10]);

outPath = defs.FileNames('OUTPUT_STATS_DIR_SPIKES');
if exist(outPath,'dir')==0
   mkdir(outPath);
end

S = refactorDurationUsingRMS_mask(S); % Ensure that RMS mask is included

S = sortrows(S,'Rate','ascend');
S = sortrows(S,'Block','ascend');
S = sortrows(S,'Epoch','ascend');
S = sortrows(S,'Channel','ascend');
S = sortrows(S,'Block','ascend');

writetable(S,fullfile(outPath,'TDCS_Spikes.csv'));

end