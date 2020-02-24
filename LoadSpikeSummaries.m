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
switch nargin
   case 0
      pars = defs.Spikes();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.Spikes();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% INITIALIZE
if isfield(pars,'F')
   F = pars.F;
else
   in = load(fullfile(pars.DIR,pars.FILE),'F');
   F = in.F;
end
tStart = tic;

% LOOP AND LOAD ALL TABLES INTO CELL BASED ON EPOCH
nRec = numel(F);

SpikeData = cell(1,6);
iBlock = 1;
tStart = tic;
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
      
      if any([block_contents.bytes] < pars.MIN_SIZE) || (~F(ii).included)
         F(ii).included = false;
         fprintf(1,'\t-->\t%s <strong>skipped</strong>\n',block(iB).name);
         continue;
      else
         F(ii).included = true;
         fprintf(1,'\t-->\t%s included\n',block(iB).name);
         for iC = 1:numel(block_contents)
            temp = strsplit(block_contents(iC).name,'_');
            temp = temp{6};
            switch temp
               case '0005'
                  iContents = 1;
               case '0015'
                  iContents = 2;
               case '0035'
                  iContents = 3;
               case '0050'
                  iContents = 4;
               case '0065'
                  iContents = 5;
               case '0080'
                  iContents = 6;
               otherwise
                  warning('\n\t\t-->\t%s <strong>found</strong> (but not assigned)\n', ...
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
ElapsedTime(tStart);
end
