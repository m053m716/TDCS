function T = export_LFP_bandpower__rm_stats(F,varargin)
%EXPORT_LFP_BANDPOWER__RM_STATS Export LFP RMS for repeated-measures
%
%  T = EXPORT_LFP_BANDPOWER__RM_STATS(F);
%  --> Uses `defs.LFP()` to obtain `pars`
%
%  T = EXPORT_LFP_BANDPOWER__RM_STATS(F,pars); 
%  --> Assign `pars` directly
%
%  T = EXPORT_LFP_BANDPOWER__RM_STATS(F,'NAME',value,...);
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
      T = [];
   end
   for i = 1:numel(F)
      if nargout > 0
         T = [T; export_LFP_bandpower__rm_stats(F(i),varargin{:})];  %#ok<AGROW>
      else
         export_LFP_bandpower__rm_stats(F(i),varargin{:});
      end
   end
   return;
end

% If this is an excluded element, then skip it
if ~F.included
   fprintf(1,'\t\t->\t%s skipped\n',F.base);
   T = [];
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

nEpoch = numel(pars.EPOCH_NAMES);
nBand = numel(pars.BANDS);

BandID   = (1:nBand).';
AnimalID = ones(nBand,1).*F.animalID;
ConditionID = ones(nBand,1).*F.conditionID;
ConditionID = ceil(ConditionID/2); % Only have 3 levels of ConditionID
CurrentID = ones(nBand,1).*F.currentID;
T = table(AnimalID,ConditionID,CurrentID,BandID);
for i = 1:nEpoch
   T = [T, table(nan(nBand,1),'VariableNames',pars.EPOCH_NAMES(i))]; %#ok<AGROW>
end

for i = 1:nBand
   fc = pars.FC.(pars.BANDS{i});
   f_idx = (f>=fc(1)) & (f<=fc(2));
   ps_f = ps_(f_idx,:); % Note: ps_ is log-transformed, has mask applied
   p = mean(ps_f,1);    % Keep this for assignment
   
   for k = 1:nEpoch
      epochName = pars.EPOCH_NAMES{k};
      t_idx = (t_>=pars.EPOCH_ONSETS(k)) & ...
              (t_<=pars.EPOCH_OFFSETS(k));
      T.(epochName)(i) = mean(p(t_idx));
   end
end

fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');



end