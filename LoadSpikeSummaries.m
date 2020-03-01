function [SpikeData,F] = LoadSpikeSummaries(varargin)
%LOADSPIKESUMMARIES   Load spike summaries for tDCS study
%
%  [SpikeData,F] = LOADSPIKESUMMARIES
%  --> Uses `pars` from defs.Spikes()
%
%  [SpikeData,F] = LOADSPIKESUMMARIES(pars);
%  --> Gives `pars` directly as input argument
%
%  [SpikeData,F] = LOADSPIKESUMMARIES('NAME',value,...);
%  --> Sets `pars` from defs.Spikes()
%     --> Modify specific fields using 'NAME', value pairs:
%        * 'DIR'   : ('P:\Rat\tDCS')
%        * 'FILE'  : ('2017 TDCS Data Structure Organization.mat')
%        * 'SUM_ID': ('_SpikeSummary.mat')
%        * 'MIN_SIZE' : 200000 (Min summary file size; bytes)

% DEFAULT CONSTANTS
pars = parseParameters('Spikes',varargin{:});

% INITIALIZE
if isfield(pars,'F')
   F = pars.F;
else
   in = load(fullfile(pars.DIR,pars.FILE),'F');
   F = in.F;
end

% LOOP AND LOAD ALL TABLES INTO CELL BASED ON EPOCH
nRec = numel(F);

SpikeData = cell(1,6);
iBlock = 1;
ticStart = tic;
fprintf(1,'Beginning extracted summary epoch concatenation...\n');
for ii = 1:nRec
   rec_name = fullfile(pars.DIR,F(ii).name);
   fprintf(1,'\t-------------------\n');
   fprintf(1,'\t%s\n',rec_name);
   fprintf(1,'\t-------------------\n');
   block = dir(fullfile(rec_name,[F(ii).name '*']));
   for iB = 1:numel(block) % Should only have 1 "block" folder at this level
      block_name = fullfile(rec_name,block(iB).name);
      fprintf(1,'\t->\t%s\n',block_name);
      block_contents = dir(fullfile(block_name, ...
         [block(iB).name '*' pars.SUM_ID]));
      % File-size exclusion is heuristic
      if any([block_contents.bytes] < pars.MIN_SIZE) || (~F(ii).included)
         F(ii).included = false;
         fprintf(1,'\t-->\t%s <strong>skipped</strong>\n',block(iB).name);
         continue;
      else
         F(ii).included = true;
         fprintf(1,'\t-->\t%s included\n',block(iB).name);
         for iC = 1:numel(block_contents)
            temp = strsplit(block_contents(iC).name,'_');
            if numel(temp) < 7
               fprintf(1,'\t\t-->\t%s <strong>found</strong> (but not assigned)\n', ...
                     block_contents(iC).name);
               continue;
            end
            tStart = str2double(temp{6});
            tStop = str2double(temp{7});
            
            idx = ismember(pars.EPOCH_ONSETS,tStart) & ismember(pars.EPOCH_OFFSETS,tStop);
            if sum(idx) == 1
               iContents = find(idx,1,'first');
               fprintf(1,'\t\t-->\t%s <strong>added</strong>\n', ...
                     pars.GROUPS{iContents});
            else
               fprintf(1,'\t\t-->\t%s <strong>found</strong> (but not assigned)\n', ...
                     block_contents(iC).name);
               continue;
            end
            load(fullfile(block_name,block_contents(iC).name),'D');
            SpikeData{1,iContents} = [SpikeData{1,iContents}; D];
         end
      end
   end
end
save(fullfile(pars.DIR,pars.FILE),'F','-v7.3');

fprintf(1,'\n\nSpike Summary concatenation <strong>complete!</strong>\n');
ElapsedTime(ticStart);
end
