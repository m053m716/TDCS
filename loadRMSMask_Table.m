function T = loadRMSMask_Table(F,varargin)
%LOADRMSMASK_TABLE  Gets RMS mask files and puts them into table
%
%  T = loadRMSMask_Table;
%  T = loadRMSMask_Table(F);
%  T = loadRMSMask_Table(F,'NAME',value,...);

pars = parseParameters('RefactorDuration',varargin{:});
if nargin < 1
   F = loadOrganizationData;
elseif ischar(F)
   if exist(F,'file')==2
      in = load(F,'T');
      T = in.T;
      return;
   elseif exist(F,'dir')==7
      in = load(fullfile(F,defs.FileNames('MASK_TABLE')),'T');
      T = in.T;
      return;
   else
      warning(['tDCS:' mfilename ':BadFileInfo'],...
         ['\n\t->\t<strong>[tDCS]:</strong> Could not parse '...
         'file info for string: %s (using defaults instead)\n'],F);
      in = load(fullfile(defs.FileNames('DIR'),defs.FileNames('MASK_TABLE')),'T');
      T = in.T;
      return;
   end
end

maintic = tic;
Name = {F.name}.';
BlockID = cellfun(@(C)str2double(C((regexp(C,'-','once')+1):end)),Name);
AnimalID = [F.animalID].';
ConditionID = ceil([F.conditionID].'/2);
CurrentID = [F.currentID].';
N = numel(F);
mask = cell(N,1);
h = waitbar(0,'Organizing RMS mask...');
for ii = 1:N
   if ~F(ii).included
      continue;
   end
   blockDir = F(ii).block;
   name = F(ii).base;
   maskFile = fullfile(blockDir,sprintf(pars.FILE,name));
   if exist(maskFile,'file')==2
      in = load(maskFile,'mask','pars');
   else
      warning(['tDCS:' mfilename ':MissingFile'],...
         ['\n\t->\t<strong>[tDCS]:</strong> ' ...
         'Missing file: %s (skipped)\n'],maskFile);
      continue;
   end
   if ~isfield(in,'mask')
      warning(['tDCS:' mfilename ':MissingFile'],...
         ['\n\t->\t<strong>[tDCS]:</strong> ' ...
         'Invalid file: %s (missing mask; skipped)\n'],maskFile);
      continue;
   end
   mask{ii} = in.mask;
   
   waitbar(ii/N,h);
end

T = table(BlockID,AnimalID,ConditionID,CurrentID,mask);
T.Properties.Description = 'Where `mask` is HIGH (1), signal is artifact.';
T.Properties.VariableDescriptions = {...
   'BlockID:      Identifier for recording session'; ...
   'AnimalID:     Identifier for rat'; ...
   'ConditionID:  Identifier for intensity {1: 0.0mA, 2: 0.2mA, 3: 0.4mA}'; ...
   'CurrentID:    Identifier for polarity {-1: ''Anodal'', 1: ''Cathodal''}';...
   'mask:         Vector for binned samples; [0: include, 1: exclude]' ...
   };
T.Properties.UserData = in.pars;
delete(h);
toc(maintic);


end