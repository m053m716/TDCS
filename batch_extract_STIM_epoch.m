function batch_extract_STIM_epoch(F,tag)
%BATCH_EXTRACT_STIM_EPOCH  Extract `t_stim_start` and `t_stim_end`
%
%  batch_extract_STIM_epoch;
%  batch_extract_STIM_epoch(F);
%  batch_extract_STIM_epoch(F,tag);
%
%  F : If not provided, loaded using `loadOrganizationData` (struct array
%        with data file information)
%  tag : Sets the "Stim epoch times file" tag (optional)
%        --> If unset, uses `defs.FileNames('STIM_EPOCH_TIMES_FILE')`

if nargin < 2
   tag = defs.FileNames('STIM_EPOCH_TIMES_FILE');
end

if nargin < 1
   F = loadOrganizationData();
end

for iF = 1:numel(F)
   stimEpochTimesFile = fullfile(F(iF).block,[F(iF).base tag]);
   if exist(stimEpochTimesFile,'file')==2
      continue; % No need to re-extract
   end
   [~,~,ext] = fileparts(F(iF).recording);
   switch lower(ext) % Set "suppressAmp" to true to make this go faster
      case '.rhd' % Different data format requires different parsing
         read_Intan_RHD2000_file(F(iF).recording,true,stimEpochTimesFile);
      case '.rhs' % Different data format requires different parsing
         read_Intan_RHS2000_file(F(iF).recording,true,stimEpochTimesFile);
      otherwise
         error('Invalid recording filetype.');
   end
end

end