function T = export_LFP_bandpower__stats_detailed_timeseries(F,varargin)
%EXPORT_LFP_BANDPOWER__STATS_DETAILED_TIMESERIES LFP RMS for JMP timeseries
%
%  T = EXPORT_LFP_BANDPOWER__STATS_DETAILED_TIMESERIES(F);
%  --> Uses `defs.LFP()` to obtain `pars`
%
%  T = EXPORT_LFP_BANDPOWER__STATS_DETAILED_TIMESERIES(F,pars); 
%  --> Assign `pars` directly
%
%  T = EXPORT_LFP_BANDPOWER__STATS_DETAILED_TIMESERIES(F,'NAME',value,...);
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
         if ~isempty(T)
            T = innerjoin(T,export_LFP_bandpower__stats_detailed_timeseries(F(i),varargin{:}));
         else
            T = export_LFP_bandpower__stats_detailed_timeseries(F(i),varargin{:});
         end
      else
         export_LFP_bandpower__stats_detailed_timeseries(F(i),varargin{:});
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

t_ = t./60; % Convert to minutes for comparison purposes
t_bound_idx = (t_>=pars.EPOCH_ONSETS(1)) & (t_<=pars.EPOCH_OFFSETS(end));
t_ = t_(t_bound_idx); % Format as column for table
ps_ = log(ps(:,t_bound_idx));

nBand = numel(pars.BANDS);
N = numel(t_);


% Pre-allocate variables
ts = reshape(t_,N,1);
PS = nan(N,nBand);

mask = ~rmsdata.mask(t_bound_idx);

ps_matrix_name = sprintf('PS_Anim%g_Cond%g_Curr%g_Band',...
      F.animalID,ceil(F.conditionID/2),(F.currentID+1)/2);
colName = {'ts',ps_matrix_name};

for i = 1:nBand
   fc = pars.FC.(pars.BANDS{i});
   f_idx = (f>=fc(1)) & (f<=fc(2));
   ps_f = ps_(f_idx,mask); % Note: ps_ is log-transformed, has mask applied
   p = mean(ps_f,1).';     % Keep this for assignment
   PS(mask,i) = p;         % Assign to data matrix of power values
end
T = table(ts,PS,'VariableNames',colName);

fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');



end