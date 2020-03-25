function T = export_LFP_bandpower__stats(F,varargin)
%EXPORT_LFP_BANDPOWER__GROUPED  Extract LFP (band) RMS 
%
%  T = EXPORT_LFP_BANDPOWER__GROUPED(F);
%  --> Uses `defs.LFP()` to obtain `pars`
%
%  T = EXPORT_LFP_BANDPOWER__GROUPED(F,pars); 
%  --> Assign `pars` directly
%
%  T = EXPORT_LFP_BANDPOWER__GROUPED(F,'NAME',value,...);
%  --> Uses `defs.LFP()` to obtain `pars`
%     --> Updates fields of `pars` using 'NAME',value,... syntax
%
%  -- outputs --
%  T : Table of stats data that is exported to SQL database

% Iterate on all elements of "organization" struct array
if numel(F) > 1
   % Exclude any "bad" elements of F
   F = F([F.included] & ~isnan([F.animalID]) & ~isnan([F.conditionID]));
   
   if nargout > 0
      T = struct('id',[],'key',[]);
   end
   for i = 1:numel(F)
      if nargout > 0
         tmp = export_LFP_bandpower__stats(F(i),varargin{:}); 
         T.id = [T.id; tmp.id];
         T.key = [T.key; tmp.key];
      else
         export_LFP_bandpower__stats(F(i),varargin{:});
      end
   end
   return;
end

% If this is an excluded element, then skip it
if ~F.included
   fprintf(1,'\t\t->\t%s skipped\n',F.base);
   return;
end

% Parse input parameters for LFP
pars = parseParameters('LFP',varargin{:});

% Variables from organization struct
ds_dir = F.wav.ds;
block = F.block;
name = F.base;

% Load LFP data (if present)
f = dir(fullfile(ds_dir,[name pars.LFP_DATA_TAG '*.mat']));
if isempty(f)
   fprintf(1,'\t->\t<strong>Missing %s file</strong>\n',pars.LFP_DATA_TAG);
   fprintf(1,'\t\t->\t%s skipped\n\n',F.base);
   return;
else
   fprintf(1,'\t->\t<strong>LFP power</strong> (%s)...loading...',name);
   lfp = load(fullfile(f(1).folder,f(1).name),'data','fs');
   fs = lfp.fs;
   fprintf(1,'\b\b\b\b\b\b\b\b\b\bcomputing...');
end


% Do not apply the mask yet; first compute PSD then apply mask. Note: we
% must subtract by 1 from window length (compared to the power spectrum
% estimate) in order to get the correct number of window points)
[~,f,t,ps] = spectrogram(lfp.data,pars.WLEN-1,0,pars.FREQS,fs,'power');

fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\baveraging...');

% Next, load mask and make sure we remove parts that are unwanted
rmsdata = load(fullfile(block,sprintf(pars.RMS_MASK_FILE,name)),'mask');

ps_ = log(ps(:,~rmsdata.mask)); % Remove mask samples here (do not save version with removed samples)
t_ = t(1,~rmsdata.mask)./60; % Convert to minutes for comparison purposes

P = struct;
nEpoch = numel(pars.EPOCH_NAMES);

vec = (1:(size(ps_,2)-pars.NSAMPLES_COV+1)).';
vec = vec + (0:(pars.NSAMPLES_COV-1));
iOffset = floor(pars.NSAMPLES_COV/2);
iZ = ceil(pars.NSAMPLES_COV/2);

% Truncate t_ by amount that ps_ will be truncated
t_z = t_(iZ:(end-iOffset));
nBand = numel(pars.BANDS);
nBin = pars.N_BIN_PER_EPOCH;

BandID   = nan(nBand*nEpoch,1);
EpochID  = nan(nBand*nEpoch,1);
AnimalID = ones(nBand*nEpoch,1).*F.animalID;
ConditionID = ones(nBand*nEpoch,1).*F.conditionID;
% AnimalID = repmat({sprintf('R-TDCS-%g',F.animalID)},nBand*nEpoch,1);
% c = defs.Experiment('NAME_KEY');
% ConditionID = repmat(c(F.conditionID),nBand*nEpoch,1);
TZ = nan(nBand*nEpoch,nBin);
TP = nan(nBand*nEpoch,nBin);
TT = (1:nBin).'; % Indexing vector to write


tmpID = struct;
tmpID = table(AnimalID,ConditionID,BandID,EpochID);

conn = database(defs.FileNames('DATABASE'),'dbo','');
if ~isempty(conn.Message)
   error(['TDCS:' mfilename ':BadDatabase'],...
      'Failed to connect to database');
end

dbNames = defs.FileNames('DATABASE_LFP');
lfp_id_db_tab = dbNames.Atomic;
col_id = {'AnimalID','ConditionID','BandID','EpochID'};
lfp_key_db_tab = dbNames.Key;
col_key = {'AnimalID','ConditionID','BandID','EpochID','T','P','Z'};

iTable = 0;

tmpKey = [];
for i = 1:nBand
   bandName = pars.BANDS{i};
   fc = pars.FC.(pars.BANDS{i});
   f_idx = (f>=fc(1)) & (f<=fc(2));
   ps_f = ps_(f_idx,:); % Note: ps_ is log-transformed, has mask applied
   p = mean(ps_f,1); % Keep this for assignment
   x = p.';
   % Subtract time-series average divide by time-series standard-deviation
   muX = mean(x); 
   sdX = std(x);
   xnorm = (x - muX)/sdX; 
   X = xnorm(vec);
   C = cov(X);    %  Get covariance matrix
   W = C^(-0.5);  %  Get whitening matrix
   Z = W * (X.'); %  Apply whitening transformation
   z = Z(iZ,:);   %  Take row from "middle"
   for k = 1:nEpoch
      epochName = pars.EPOCH_NAMES{k};
      iTable = iTable + 1;
      tmpID.BandID(iTable) = i;
      tmpID.EpochID(iTable) = k;
      t_idx = ...
         find( (t_>=pars.EPOCH_ONSETS(k)) & ...
               (t_<=pars.EPOCH_OFFSETS(k)));
      
      tz_idx = ...
         find( (t_z>=pars.EPOCH_ONSETS(k)) & ...
               (t_z<=pars.EPOCH_OFFSETS(k)));
            
      nSamples_z = numel(tz_idx);
      nSamples_p = numel(t_idx);
      if nSamples_z < nBin
         warning(['TDCS:' mfilename ':BadEpoch'],...
            '\n\t\t->\tInsufficient "non-masked" samples for %s: %s\n            \n',...
            name,epochName);
         continue;
      end
      
      % Get "selected" indices by equally dividing `nBin` points
      short_idx = round(linspace(1,nSamples_z,nBin));
      norm_idx = round(linspace(1,nSamples_p,nBin));
      TZ(iTable,:) = z(tz_idx(short_idx));
      TP(iTable,:) = (p(t_idx(norm_idx)) - muX)/sdX;
      
      fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\bwriting...');
      
      Tkey = table(...
         ones(nBin,1).*F.animalID,...
         ones(nBin,1).*F.conditionID,...
         ones(nBin,1).*i,...
         ones(nBin,1).*k,...
         TT,...
         TP(iTable,:).',...
         TZ(iTable,:).',...
         'VariableNames',col_key);
      if strcmpi(pars.DB_INTERACTION_MODE,'update')
         whereclause = sprintf(...
            ['WHERE (Stats.dbo.LFPkey.AnimalID = %g) AND ' ...
            '(Stats.dbo.LFPkey.ConditionID = %g) AND ' ...
            '(Stats.dbo.LFPkey.BandID = %g) AND '...
            '(Stats.dbo.LFPkey.EpochID = %g)'],...
            F.animalID,F.conditionID,i,k);
         update(conn,lfp_key_db_tab,col_key,Tkey,whereclause);
      else
         datainsert(conn,lfp_key_db_tab,col_key,Tkey); % if table has no dat
      end
      
%       % Write to the "Key" file for each time-sample
%       for iSample = 1:nBin
%          % AnimalID  ConditionID  BandID  EpochID  T P Z
%          datainsert(conn,lfp_key_db_tab,col_key,...
%             );
%       end
      tmpKey = [tmpKey; Tkey]; %#ok<AGROW>
      fprintf(1,'\b\b\b\b\b\b\b\b\b\bindexing... ');
   end
end


fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\bsaving...');
if strcmpi(pars.DB_INTERACTION_MODE,'update')
   whereclause = sprintf('WHERE Stats.dbo.LFPid.AnimalID = %g',F.animalID);
   update(conn,lfp_id_db_tab,col_id,tmpID,whereclause);
else
   datainsert(conn,lfp_id_db_tab,col_id,tmpID);   
end
T = struct('id',tmpID,'key',tmpKey);
fprintf(1,'\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');
close(conn);


end