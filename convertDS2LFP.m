function [LFP,f] = convertDS2LFP(T,varargin)
%CONVERTDS2LFP  Convert "downsampled" average LFP signal to frequency data
%
%  [LFP,f] = convertDS2LFP(T);
%  [LFP,f] = convertDS2LFP(T,pars);
%  [LFP,f] = convertDS2LFP(T,'NAME',value,...);
%
%  -- input --
%     T : From 'DS_TABLE' data file
%     varargin : (Optional) 'NAME',value input argument pairs
%        --> Modifies default `pars` struct from `defs.LFP`
%  
%  -- output --
%  --> LFP : Similar format to input table, but expands each row to have
%              elements for average band power for each element of
%              pars.BAND
%
%  --> f : Frequencies used in evaluation

pars = parseParameters('LFP',varargin{:});

for iT = 1:size(T,1)
   [~,f,~,T.data{iT}] = spectrogram(T.data{iT},1000,0,[],T.fs(iT));
   

end

end