function [T,f] = loadLvR_old()
%LOADLVR_OLD  Loads table of 'LvR' data
%
%  [T,f] = loadLvR_old()
%  --> T : Table with data
%  --> f : Name of file

[dataPath,filename] = defs.FileNames(...
   'OUTPUT_STATS_DIR_SPIKES','OLD_CSV_SPIKES');
f = fullfile(dataPath,filename);
if exist(f,'file')~=2
   warning('%s does not exist.',f);
   T = table.empty;
   return;
end
T = import_TDCS_Spikes_old_csv(f);
T = T(ismember(T.EpochID,[1,2,3]),:); % Ensure correct epochs
T(isnan(T.logFR)|isinf(T.logFR),:) = [];

end