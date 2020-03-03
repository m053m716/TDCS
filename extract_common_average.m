function [data,fs] = extract_common_average(F,varargin)
%EXTRACT_COMMON_AVERAGE  Extracts common-average of ALL files in F
%
%  [data,fs] = extract_common_average(F);
%
%  F  :  Struct array as returned by `dir` that contains all channels to
%        average together. If this is passed as a cell array, it treates
%        each cell array element as a different call to
%        `extract_common_average` using the contents of that cell.
%        --> This is a way to pass 2 different probes for example if you
%              want to keep their means separate.
%        --> F should be the struct array "list" of files in _Filtered
%              folder (that have had bandpass filter applied).
%
%  [data,fs] = extract_common_average(F,pars);
%  [data,fs] = extract_common_average(F,'NAME',value,...);
%  --> pars struct can be given directly or use default in `+defs` and
%        modify specific fields
%
% data : Output that is also saved in the containing folder of the first
%        element of F(1).folder. If F is given as a cell array, then data 
%        is returned as a cell array of identical size.
%
%  fs  : Sample rate of this recording
%
%  data and fs will both be saved in a file with _REF_ replacing _Filt_ in
%  the name, but in the _FilteredCAR folder within the block.

pars = parseParameters('extract_common_average',varargin{:});

if iscell(F)
   mu = cell(size(F));
   for i = 1:numel(F)
      mu{i} = extract_common_average(F{i},varargin{:});
   end
   return;
end

[outfolder,tmp] = fileparts(F(1).folder);
outfolder = fullfile(outfolder,strrep(tmp,...
   pars.INFILE_TYPE_TAG,pars.OUTFILE_TYPE_TAG));
str = strsplit(F(1).name,pars.INFILE_DELIM);
name = str{1};

N = numel(F);
k = 1/N;
m = matfile(fullfile(F(1).folder,F(1).name));

fs = m.fs;
data = m.data .* k;
fprintf(1,'\t->\tExtracting <strong>CAR</strong> for %s...%03g%%\n',...
   name,round(k*100));
for i = 2:N
   m = matfile(fullfile(F(i).folder,F(i).name));
   data = data + (m.data .* k);
   fprintf(1,'\b\b\b\b\b%03g%%\n',round(i/N * 100));
end

idx = regexp(F(1).name,pars.INFILE_CHANNEL_TOKEN,'once');
name = strrep(F(1).name(1:(idx-1)),pars.INFILE_DELIM,pars.OUTFILE_DELIM);
output = fullfile(outfolder,[name '.mat']);

fprintf(1,'\b\b\b\b\bsaving...\n');
save(output,'data','fs','-v7.3');
fprintf(1,'\b\b\b\b\b\b\b\b\b\bcomplete\n');

end