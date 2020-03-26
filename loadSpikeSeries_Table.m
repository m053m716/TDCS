function T = loadSpikeSeries_Table(F,varargin)
%LOADSPIKESERIES_TABLE Load all channel spike series into a data table
%
%  T = loadSpikeSeries_Table(F);

if nargin < 1
   F = loadOrganizationData;
end

pars = parseParameters('FileNames',varargin{:});
seriesFile = fullfile(pars.DIR,pars.SPIKE_SERIES_TABLE);
mask = load(fullfile(pars.DIR,pars.MASK_TABLE),'T');

if exist(seriesFile,'file')==2
   fprintf(1,'\t->\t<strong>Found</strong> Spike-Series file\n');
   fprintf(1,'\t\t->\t(Loading...)');
   in = load(seriesFile,'T');
   T = in.T;
   nameIndex = ismember(T.Properties.VariableNames,'Name');
   if sum(nameIndex)==1
      fprintf(1,'\b\b\b\b\b\b\b\b\b\b\bFixing...)');
      T.Name = convertName2BlockID(T.Name);
      T.Properties.VariableNames{nameIndex} = 'BlockID';
      T = innerjoin(T,mask.T);
      clear mask;
      T.Properties.Description = ...
         ['Multi-unit activity ' newline ...
         '`Train` is sparse matrix indicating time of spike peaks'];
      fprintf(1,'\b\b\b\b\b\b\b\b\b\bSaving...) ');
      save(seriesFile,'T','-v7.3');
   end
   fprintf(1,'\b\b\b\b\b\b\b\b\b\b\bComplete)\n');
   return;
end


if numel(F) > 1
   T = table.empty;
   for iF = 1:numel(F)
      T = [T; loadSpikeSeries_Table(F(iF))]; %#ok<AGROW>
   end
   return;
end

D = dir(fullfile(F.block,[F.base pars.SPIKE_DIR_TAG],[F.base '*.mat']));
ConditionID = ones(size(D)) .* (ceil(F.conditionID/2));
CurrentID = ones(size(D)) .* F.currentID;
AnimalID = ones(size(D)) .* F.animalID;
Train = cell(size(D));
FS = nan(size(D));
Channel = ones(size(D));
Cluster = ones(size(D));
for iD = 1:numel(D)
   in = load(fullfile(D(iD).folder,D(iD).name),'peak_train','pars');
   FS(iD) = in.pars.FS;
   Train{iD} = in.peak_train;
   ch = strsplit(D(iD).name,'_');
   ch = strsplit(ch{end},'.');
   Channel(iD) = str2double(ch{1});
end

BlockID = convertName2BlockID(repmat({F.name},numel(D),1));
T = table(BlockID,Channel,Cluster,Train,FS,AnimalID,ConditionID,CurrentID);
T = innerjoin(T,mask.T);
T.Properties.Description = ...
         ['Multi-unit activity ' newline ...
         '`Train` is sparse matrix indicating time of spike peaks'];
end