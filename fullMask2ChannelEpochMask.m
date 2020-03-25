function T = fullMask2ChannelEpochMask(T_mask,T_series)
%FULLMASK2CHANNELEPOCHMASK  Convert "full-trial" mask to channel/epoch mask
%
%  T = fullMask2ChannelEpochMask(T_mask,T_series);
%
%  -- input --
%  T_mask : Table of RMS-mask vectors, by animalID and conditionID, based on RMS
%        amplitude (high value == ARTIFACT / > 500uV RMS)
%  T_series : Table of spike rate in 1-s bins, by epoch
%  idx : Sample indices to use from (original) Mask vector
%
%  -- output --
%  T : Table to match FR_table, etc.

T = innerjoin(T_mask,T_series);

end