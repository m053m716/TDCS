function [T,f] = convertDS2LFP(T)
%CONVERTDS2LFP  Convert "downsampled" average LFP signal to frequency data
%
%  [T,f] = convertDS2LFP(T);
%
%  -- input --
%     T : From 'DS_TABLE' data file
%  
%  -- output --
%  --> T : Same as input table but 'data' now represents PSD
%
%  --> f : Frequencies used in evaluation

for iT = 1:size(T,1)
   [~,f,~,T.data{iT}] = spectrogram(T.data{iT},1000,0,[],T.fs(iT));
end


end