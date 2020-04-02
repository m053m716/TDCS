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

h = waitbar(0,'Running batch STIM epoch extraction...',...
   'Name','Running: batch_extract_STIM_epoch',...
   'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
nBlocks = numel(F);
for iF = 1:nBlocks
   stimEpochTimesFile = fullfile(F(iF).block,[F(iF).base tag]);
%    if exist(stimEpochTimesFile,'file')==2
%       continue; % No need to re-extract
%    end
   if getappdata(h,'canceling')
      clc;
      fprintf(1,'STIM epoch extraction <strong>canceled.</strong>\n');
      fprintf(1,'\t->\tQuit before extracting: <strong>%s</strong>\n',...
         F(iF).base);
      break;
   end
   pause(1); % Gives chance to cancel
   waitbar((iF-1)/nBlocks,h,...
      sprintf('Running batch STIM epoch extraction...%s',F(iF).name));
   [~,~,ext] = fileparts(F(iF).recording);
   try
      switch lower(ext) % Set "suppressAmp" to true to make this go faster
         case '.rhd' % Different data format requires different parsing
            read_Intan_RHD2000_file(F(iF).recording,true,stimEpochTimesFile);
         case '.rhs' % Different data format requires different parsing
            read_Intan_RHS2000_file(F(iF).recording,true,stimEpochTimesFile);
         otherwise
            error('Invalid recording filetype.');
      end
   catch me
      delete(h);
      rethrow(me);
   end
   waitbar(iF/nBlocks);
   pause(1); % Gives chance to cancel
end
delete(h);

end