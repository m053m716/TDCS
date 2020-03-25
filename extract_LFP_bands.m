function LFP = extract_LFP_bands(ds_data,mask,fs,F,varargin)
%EXTRACT_LFP_BANDS  Extract LFP band power for data in `ds_data` to Table
%
%  LFP = extract_LFP_bands(T);
%  LFP = extract_LFP_bands(T,'NAME',value,...);
%
%  -- or --
%
%  LFP = extract_LFP_bands(ds_data,mask,fs,F);
%  LFP = extract_LFP_bands(ds_data,mask,fs,F,pars);
%  LFP = extract_LFP_bands(ds_data,mask,fs,F,'NAME',value,...);
%
%  -- inputs --
%  T        :  Data table from file in `defs.FileNames('DS_TABLE')` after
%                 adding data from table in `defs.FileNames('MASK_TABLE')`
%                 using `innerjoin` (see `batch_export_delta_LFP_Figs`)
%
%  -- or --
%
%  ds_data  :  downsampled data series (vector; same size as mask)
%  mask     :  RMS mask, where high value indicates artifact (to exclude)
%  fs       :  Sample rate after downsampling (fs for ds_data)
%  F        :  Struct with fields:
%                 * animalID
%                 * conditionID
%                 * currentID
%
%  -- outputs --
%  LFP      :  Data table that has the following variables:
%                 * 'Name'       (Name of recording Block)
%                 * 'AnimalID'   (Corresponds to Rat number)
%                 * 'ConditionID'(Corresponds to [0.0, 0.2, 0.4] mA)
%                 * 'CurrentID'  (Corresponds to ['Anodal','Cathodal'])
%                 * 'EpochID'    (Corresponds to ['Pre','Stim','Post'])
%                 * 'BandID'     (Corresponds to ['Delta','Theta',...])
%                 * 'Mean'       (Log-transformed power spectrum)
%                 * 'Median'     (Log-transformed power spectrum)
%                 * 'NSamples'   (Non-masked time-series samples)
%                 * 'SD'         (Log-transformed power spectrum)

% Parse number of inputs
if istable(ds_data)   
   switch nargin
      case 1 % Do nothing
         varargin = cell.empty;
      case 2
         if isstruct(mask)
            varargin = {mask};
         end
      case 3
         varargin = {mask, fs};
      case 4
         varargin = {mask, fs, F};
      otherwise
         varargin = [mask, fs, F, varargin];
   end
   
   if size(ds_data,1) > 1
      LFP = table.empty;
      for iRow = 1:size(ds_data,1)
         LFP = vertcat(LFP,extract_LFP_bands(ds_data(iRow,:),varargin{:})); %#ok<AGROW>
      end
      return;      
   end
   ds_data = T.data;
   mask = T.mask;
   fs = T.fs;
   
end

pars = parseParameters('LFP',varargin{:});

% Do not apply the mask yet; first compute PSD then apply mask. Note: we
% must subtract by 1 from window length (compared to the power spectrum
% estimate) in order to get the correct number of window points)
[~,f,t,ps] = spectrogram(ds_data,pars.WLEN-1,0,pars.FREQS,fs,'power');

fprintf(1,'averaging...');


ps_ = log(ps(:,~mask)); % Remove mask samples here (do not save version with removed samples)
t_ = t(1,~mask)./60; % Convert to minutes for comparison purposes

nEpoch = numel(pars.EPOCH_NAMES);
nBand = numel(pars.BANDS);
nRow = nBand * nEpoch;

BandID   = (1:nBand).';
AnimalID = ones(nBand,1).*F.animalID;
ConditionID = ones(nBand,1).*F.conditionID;
ConditionID = ceil(ConditionID/2); % Only have 3 levels of ConditionID
CurrentID = ones(nBand,1).*F.currentID;

for i = 1:nEpoch
   LFP = [LFP, table(nan(nBand,1),'VariableNames',pars.EPOCH_NAMES(i))]; %#ok<AGROW>
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
      LFP.(epochName)(i) = mean(p(t_idx));
   end
end
fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');

LFP = table(Name,AnimalID,ConditionID,CurrentID,EpochID,BandID,Mean,Median,NSamples,SD);
LFP.Properties.VariableDescriptions = ...
   {...
   'Name: (Name of recording Block)'; ...
   'AnimalID: (Corresponds to Rat number)'; ...
   'ConditionID: (Corresponds to [0.0, 0.2, 0.4] mA)'; ...
   'CurrentID: (Corresponds to {''Anodal'',''Cathodal''})'; ...
   'EpochID: (Corresponds to {''Pre'',''Stim'',''Post''})'; ...
   'BandID: (Corresponds to {''Delta'',''Theta'',...})'; ...
   'Mean: (Log-transformed power spectrum)'; ...
   'Median: (Log-transformed power spectrum)'; ...
   'NSamples: (Non-masked time-series samples)'; ...
   'SD: (Log-transformed power spectrum)' ...
   };

end