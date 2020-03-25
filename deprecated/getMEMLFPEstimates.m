function F = getMEMLFPEstimates(F)
%% GETMEMLFPESTIMATES  Get MEM LFP estimates for each recording.
%
% By: Max Murphy    v1.0    08/15/2017 Original version (R2017a)

%% Loop through and do each frequency estimate
tStart = tic; 
for iF = 1:numel(F)
    mmMEMfreq('DIR',F(iF).block);
    F(iF).LFP = true;
end
ElapsedTime(tStart);

end