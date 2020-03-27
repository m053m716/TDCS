function extract_LFP_bandpower(F,varargin)
%EXTRACT_LFP_BANDPOWER  Extract LFP RMS in 1-sec non-overlapping epochs
%
%  extract_LFP_bandpower(F);
%  --> Uses `defs.LFP()` to obtain `pars`
%
%  extract_LFP_bandpower(F,pars); 
%  --> Assign `pars` directly
%
%  extract_LFP_bandpower(F,'NAME',value,...);
%  --> Uses `defs.LFP()` to obtain `pars`
%     --> Updates fields of `pars` using 'NAME',value,... syntax

% Iterate on all elements of "organization" struct array
if numel(F) > 1
   if nargout > 0
      P = cell(size(F));
   end
   for i = 1:numel(F)
      if nargout > 0
         P{i} = extract_LFP_bandpower(F(i),varargin{:});
      else
         extract_LFP_bandpower(F(i),varargin{:});
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
E = numel(pars.EPOCH_NAMES);

vec = (1:(size(ps_,2)-pars.NSAMPLES_COV+1)).';
vec = vec + (0:(pars.NSAMPLES_COV-1));
iOffset = floor(pars.NSAMPLES_COV/2);
iZ = ceil(pars.NSAMPLES_COV/2);

% Truncate t_ by amount that ps_ will be truncated
t_ = t_(iZ:(end-iOffset));

for i = 1:numel(pars.BANDS)
   fc = pars.FC.(pars.BANDS{i});
   f_idx = (f>=fc(1)) & (f<=fc(2));
   P.(pars.BANDS{i}) = struct;
   P.(pars.BANDS{i}).f  = f(f_idx);
   P.(pars.BANDS{i}).mu = nan(1,E);
   P.(pars.BANDS{i}).sd = nan(1,E);
   P.(pars.BANDS{i}).mu_z = nan(1,E);
   P.(pars.BANDS{i}).sd_z = nan(1,E);
   P.(pars.BANDS{i}).n  = nan(1,E);
   ps_f = ps_(f_idx,:);
   x = mean(ps_f,1).';
   x = (x - mean(x))/std(x); % Do initial offset and variance correction
   X = x(vec);
   C = cov(X);    %  Get covariance matrix
   W = C^(-0.5);  %  Get whitening matrix
   Z = W * (X.'); %  Apply whitening transformation
   z = Z(iZ,:);   %  Take row from "middle"
   P.(pars.BANDS{i}).z = z;
   for k = 1:E
      t_idx = ...
         (t_>=pars.EPOCH_ONSETS(k)) & ...
         (t_<=pars.EPOCH_OFFSETS(k));
      if sum(t_idx) == 0
         warning(['TDCS:' mfilename ':BadEpoch'],...
            '\n\t\t->\tNo "non-masked" times for %s: %s\n            \n',...
            name,pars.EPOCH_NAMES{k});
         continue;
      end
      P.(pars.BANDS{i}).mu(k) = mean(mean(ps_f,2),1);
      P.(pars.BANDS{i}).mu_z(k) = mean(mean(z(t_idx),1),2);
      P.(pars.BANDS{i}).sd(k) = mean(std(ps_f,[],2),1);
      P.(pars.BANDS{i}).sd_z(k) = mean(std(z(t_idx),[],1),2);
      P.(pars.BANDS{i}).n(k) = sum(t_idx);
      
   end
end

fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\bsaving...');
outname = fullfile(block,sprintf(pars.LFP_FILE,name));
save(outname,'P','f','t','ps','fs','pars','-v7.3');
fprintf(1,'\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');

end