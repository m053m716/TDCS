function T = loadRMSMask_Table(F,varargin)
%LOADRMSMASK_TABLE  Gets RMS mask files and puts them into table
%
%  T = loadRMSMask_Table;
%  T = loadRMSMask_Table(F);
%  T = loadRMSMask_Table(F,'NAME',value,...);

pars = parseParameters('RefactorDuration',varargin{:});
if nargin < 1
   in = load(fullfile(pars.TANK,defs.FileNames('DATA_STRUCTURE')));
   F = in.F;
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
AnimalID = [F.animalID].';
ConditionID = ceil([F.conditionID].'/2);
CurrentID = [F.currentID].';
N = numel(F);
mask = cell(N,1);
h = waitbar(0,'Organizing RMS mask...');
for ii = 1:N
   blockDir = F(ii).block;
   name = F(ii).base;
   maskFile = fullfile(blockDir,sprintf(pars.FILE,name));
   if exist(maskFile,'file')==2
      in = load(maskFile,'mask');
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

T = table(Name,AnimalID,ConditionID,CurrentID,mask);
delete(h);
toc(maintic);


end