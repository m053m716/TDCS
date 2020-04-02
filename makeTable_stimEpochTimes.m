function E = makeTable_stimEpochTimes(F,addMfileVariable,varargin)
%MAKETABLE_STIMEPOCHTIMES  Make table to organize stim Epoch time data
%
%  E = makeTable_stimEpochTimes;
%  E = makeTable_stimEpochTimes(F);
%  E = makeTable_stimEpochTimes(F,addMfileVariable);
%  --> By default, `addMfileVariable` is false; if true, then a 5th column
%        is added to `E` for `m,` the matfile containing extracted info
%  E = makeTable_stimEpochTimes(__,'NAME',value,...);
%  --> Can set parameters listed in `defs.Make_Stim_Epoch_Table`
%
%  -- Inputs --
%  F  :     Struct array for organizing filename data etc.
%              --> If not specified, loaded using `loadOrganizationData`
%
%  addMfileVariable : Default: false; if true, adds `m` to output table.
%
%  varargin : (Optional) set parameters using <'NAME',value> syntax
%
%  -- Output --
%  E  :     Table containing the following variables:
%           --> `BlockID`        Numeric ID of recording block
%           --> `EpochsMarked`   If true, Epochs marked in digital record
%           --> `tStart`         Time (minutes) of start of stim epoch
%           --> `tStop`          Time (minutes) of stop of stim epoch
%           --> `m` (optional)   Matfile containing all data

if nargin < 2
   addMfileVariable = false;
elseif ischar(addMfileVariable)
   varargin = [addMfileVariable, varargin];
   addMfileVariable = false;
elseif islogical(F)
   varargin = [addMfileVariable, varargin];
   addMfileVariable = F;
   F = loadOrganizationData;
end

if nargin < 1
   F = loadOrganizationData;
elseif isempty(F)
   F = loadOrganizationData;
elseif islogical(F)
   addMfileVariable = F;
   F = loadOrganizationData;
end

pars = parseParameters('Make_Stim_Epoch_Table',varargin{:});

nBlock = numel(F);
BlockID = nan(nBlock,1);
EpochsMarked = false(nBlock,1);
tStart = nan(nBlock,1);
tStop = nan(nBlock,1);
if addMfileVariable
   m = cell(nBlock,1);
end

mainTic = tic;
h = waitbar(0,'Aggregating epoch timing table...');
for iBlock = 1:nBlock
   fname = fullfile(F(iBlock).block,[F(iBlock).base pars.TAG]);
   if addMfileVariable
      m{iBlock} = matfile(fname,'Writable',false);
      in = m{iBlock};
   else
      in = load(fname);
   end
   
   BlockID(iBlock) = convertName2BlockID(F(iBlock).name);
   EpochsMarked(iBlock) = in.has_dig_epoch_saved;
   tStart(iBlock) = in.t_stim_start;
   tStop(iBlock) = in.t_stim_stop;
   waitbar(iBlock/nBlock);
end
delete(h);

E = table(BlockID,EpochsMarked,tStart,tStop);
E.Properties.Description = 'Start and stop times of STIM epoch';
E.Properties.VariableDescriptions = {...
   'BlockID: Numeric recording identifier';...
   'EpochsMarked: True if digital record was marked during experiment';...
   'tStart: Start time (minutes) of STIM epoch'; ...
   'tStop:  Stop time (minutes) of STIM epoch' ...
   };

if addMfileVariable
   E = [E, table(m)];
   E.Properties.VariableDescriptions{end} = ...
      'm: Cell array of MatFile objects that contain epoch-related data';
end

E.Properties.UserData = struct('OrganizationData','F');

f_out = fullfile(pars.OUT_DIR,pars.OUT_NAME);
if exist(f_out,'file')~=2
   fprintf(1,'Table (''<strong>%s</strong>'') is unsaved\n',pars.OUT_NAME);
   fprintf(1,'\t->\t<strong>saving...</strong>');
   save(f_out,'E','-v7.3');
   fprintf(1,'complete\n');
end
toc(mainTic);

end