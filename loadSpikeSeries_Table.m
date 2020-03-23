function T = loadSpikeSeries_Table(F,varargin)
%LOADSPIKESERIES_TABLE Load all channel spike series into a data table
%
%  T = loadSpikeSeries_Table(F);

if nargin < 1
   F = loadOrganizationData;
end

pars = parseParameters('FileNames',varargin{:});

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

Name = repmat({F.name},numel(D),1);

T = table(Name,Channel,Cluster,Train,FS,AnimalID,ConditionID,CurrentID);

end