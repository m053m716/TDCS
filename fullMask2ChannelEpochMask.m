function T_mask = fullMask2ChannelEpochMask(T,FR_table,idx)
%FULLMASK2CHANNELEPOCHMASK  Convert "full-trial" mask to channel/epoch mask
%
%  T_mask = fullMask2ChannelEpochMask(T);
%
%  -- input --
%  T : Table of RMS-mask vectors, by animalID and conditionID, based on RMS
%        amplitude (high value == ARTIFACT / > 500uV RMS)
%  FR_table : Table of spike rate in 1-s bins, by epoch
%  idx : Sample indices to use from (original) Mask vector
%
%  -- output --
%  T_mask : Cell array of tables to match FR_table, etc.

if nargin < 3
   idx = defs.Experiment('EPOCH_MASK_INDICES');
end

if iscell(FR_table)
   T_mask = cell(size(FR_table));
   for i = 1:numel(FR_table)
      T_mask{i} = fullMask2ChannelEpochMask(T,FR_table{i},idx{i});
   end
   return;
end

T_mask = innerjoin(T,FR_table(:,1:5));
T_mask.mask = cellfun(@(C)C(idx),T_mask.mask,'UniformOutput',false);

end