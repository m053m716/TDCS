function F = getDSData(F)
%% GETDSDATA    Down-sample (DS) data for LFP estimates for tDCS analysis.
%
% By: Max Murphy    v1.0    08/15/2017  Original version (R2017a)

%% LOOP THROUGH BLOCKS AND DOWNSAMPLE RAW DATA
tStart = tic; 
for iF = 1:numel(F)
    mmDS('DIR',F(iF).block);
    F(iF).DS = true;
end

ElapsedTime(tStart);

end