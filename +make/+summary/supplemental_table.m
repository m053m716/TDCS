function T = supplemental_table(binned_spikes,lvr,F)
%SUPPLEMENTAL_TABLE  Create table of supplemental info
%
%  T = make.summary.supplemental_table(binned_spikes,lvr);
%  --> Automatically uses `F` from loadOrganizationData
%
%  T = make.summary.supplemental_table(binned_spikes,lvr,F);
%
%  e.g.
%  ```
%     d = loadDataStruct();
%     T = make.summary.supplemental_table(d.binned_spikes,d.LvR,d.F);
%  ```
%
%  --------
%   INPUTS
%  --------
%  binned_spikes  : Spike rates data table (`data.binned_spikes` from
%                    `loadDataStruct()` function)
%
%    lvr          : LvR data table (`data.LvR` from `loadDataStruct()`
%                    function)
%
%     F        : Struct as returned by `loadOrganizationData()`, which is
%                  used to load it if not specified.
%
%  --------
%   OUTPUT
%  --------
%     T        : Summary table for supplemental section, with generic
%                 parameters from the recording

if nargin < 1
   d = loadDataStruct();
   T = make.summary.supplemental_table(d.binned_spikes,d.LvR,d.F);
   return;
end

if nargin < 2
   if isstruct(binned_spikes)
      lvr = binned_spikes.LvR;
      binned_spikes = binned_spikes.binned_spikes;
   else
      T = make.summary.supplemental_table();
      return;
   end
end

if nargin < 3
   F = loadOrganizationData();
end

if numel(F) > 1
   T = table.empty;
   recName_r = catID2Name(binned_spikes.BlockID);
   recName_l = catID2Name(lvr.BlockID);
   fprintf(1,'Aggregating table...%03g%%\n',0);
   N = numel(F);
   for i = 1:N
      r = binned_spikes(ismember(recName_r,F(i).name),:);
      l = lvr(ismember(recName_l,F(i).name),:);
      T = [T; make.summary.supplemental_table(r,l,F(i))]; %#ok<AGROW>
      fprintf(1,'\b\b\b\b\b%03g%%\n',round(i/N * 100));
   end
   fprintf(1,'\t->\t<strong>complete</strong>\n');
   return;   
end

% Initialize indexing and matching vectors
vec = getEpochSampleIndices(binned_spikes(1,:),1:3);
EPOC = ordinal([1,2,3]);

% Get basic properties parsed from tables
Name = F.name;
fs = binned_spikes.FS(1);
samples = zeros(1,3);
avg_spikes = nan(1,3);
avg_lvr = nan(1,3);
for i = 1:3
   samples(i) = sum(~binned_spikes.mask{1}(vec{i}));
   l = lvr(lvr.EpochID == EPOC(i),:);
   avg_spikes(i) = median(l.N);
   avg_lvr(i) = median(l.LvR);
end
Channels = size(binned_spikes,1);
Date = base2date(F.base);

% Get thresholds used during spike detection
S = dir(fullfile(F.block,[F.base '_FilteredCAR'],'*FiltCAR_P*.mat'));
thresh = struct('sneo',cell(Channels,1),'data',cell(Channels,1));
pars = struct('SNEO_N',5,'MULTCOEFF',4.5,'NS_AROUND',7,'PLP',20); % Defaults
T = 15:30:((numel(binned_spikes.mask{1})-1)*30 + 15); % seconds
idx = find(~binned_spikes.mask{1} & (T > 300),1,'first');
sampleIndex = T(idx) * fs;
sampleVec = (sampleIndex-(5*fs)):(sampleIndex+(5*fs)); % Only use 10 seconds of data to compute

nFiles = numel(S);
h = waitbar(0,sprintf('[%s]: Extracting spike thresholds...',Name));
for i = 1:nFiles
   in = matfile(fullfile(S(i).folder,S(i).name));
   x = in.data(1,sampleVec);
   [~,msgid] = lastwarn;
   if strcmp(msgid,'MATLAB:MatFile:OlderFormat')
      data = in.data(1,:);
      fs = in.fs;
      clear in;
      save(fullfile(S(i).folder,S(i).name),'data','fs','-v7.3');
      % Update last warning ID
      lastwarn(sprintf([...
         '\n\t->\t<strong>[''%s'']</strong>: ' ...
         'File updated with -v7.3 flag.'],...
         fullfile(S(i).folder,S(i).name)),...
         'TDCS:load:fixedSaveVersion');
   end
   [~,~,~,~,~,~,thresh(i)] = eqn.SNEO_Threshold(x,pars,[],true);
   waitbar(i/nFiles);
end
delete(h);
save(fullfile(F.block,[F.base '_SpikeThresholds.mat']),'thresh','-v7.3');
avg_thresh_data = median([thresh.data]);
avg_thresh_sneo = median([thresh.sneo]);
Name = string(Name);
Date = string(Date);
T = table(Name,Date,Channels,fs,samples,avg_spikes,avg_lvr,avg_thresh_data,avg_thresh_sneo);
T.Properties.Description = 'Recordings summary table (all averages are median)';
T.Properties.VariableDescriptions = {...
   'Name of recording',...
   'Date of recording',...
   'Number of channels in recording',...
   'Amplifier sample rate',...
   'Number of non-excluded samples by epoch', ...
   'Average number of spikes by epoch',...
   'Average LvR by epoch',...
   'Average spike time-series threshold',...
   'Average spike SNEO threshold'...
   };
end