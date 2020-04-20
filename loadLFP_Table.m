function T = loadLFP_Table(F,varargin)
%LOADLFP_TABLE  Loads LFP data table with metadata and LFP time-series
%
%  T = loadLFP_Table():
%  --> Loads LFP_Table using `parseLFP_Table.m`
%
%  T = loadLFP_Table(LFP_Table);
%  --> Loads LFP_Table using specified LFP_Table.
%  --> T is the same as LFP_Table, but has an additional variable (column)
%      which contains the LFP data.

pars = parseParameters('FileNames',varargin{:});
if exist(fullfile(pars.DIR,pars.LFP_TABLE),'file')==2
   fprintf(1,'<strong>Found</strong> extracted LFP Table. Loading...');
   in = load(fullfile(pars.DIR,pars.LFP_TABLE),'LFP');
   T = in.LFP;
   fprintf(1,'<strong>Complete</strong>\n');
   return;
end

if nargin < 1
   in = load(fullfile(pars.DIR,pars.DATA_STRUCTURE),'F');
   F = in.F;
elseif ischar(F)
   if exist(F,'file')==2
      in = load(F,'T');
      T = in.T;
      return;
   elseif exist(F,'dir')==7
      F = fullfile(F,defs.FileNames('DS_TABLE'));
      if exist(F,'file')~=2
         error(['tDCS:' mfilename ':MissingFile'],...
            '<strong>[TDCS]:</strong> Could not find file: %s\n',F);
      end
      in = load(F,'T');
      T = in.T;
      return;
   else
      error(['tDCS:' mfilename ':MissingFile'],...
         '<strong>[TDCS]:</strong> Could not find file: %s\n',F);
   end
end

maintic = tic;
Name = {F.name}.';
AnimalID = [F.animalID].';
AnimalID = categorical(AnimalID);
ConditionID = ceil([F.conditionID].'/2);
ConditionID = ordinal(ConditionID,{'0.0 mA','0.2 mA','0.4 mA'},[1 2 3]);
CurrentID = [F.currentID].';
CurrentID = categorical(CurrentID,{'Anodal','Cathodal'},[-1 1]);

N = numel(F);
data = cell(N,1);
fs = nan(N,1);

h = waitbar(0,'Extracting downsampled data table...');
for i = 1:N
   [data{i},fs(i)] = loadDS_Data(Name{i},pars.DIR);
   waitbar(i/N,h);
end
BlockID = convertName2BlockID(Name);
BlockID = categorical(BlockID);
T = table(BlockID,AnimalID,ConditionID,CurrentID,data,fs);
delete(h);
p = defs.LFP('EPOCH_NAMES','EPOCH_ONSETS',...
   'EPOCH_OFFSETS','BANDS',...
   'FC','WLEN',...
   'FREQS','DESCRIPTION');
p.WIN_OVERLAP = 0; % Hard-coded
p.FS = defs.Experiment('FS_DECIMATED');
T.Properties.UserData = p;
T = setTableOutcomeVariable(T,'Mean','');
T.Properties.UserData.TABLE_TYPE = 'DS';

toc(maintic);

end