function [LFP,S] = extract_LFP_bands(ds_data,mask,fs,F,varargin)
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
%                 * Name
%                 * animalID
%                 * conditionID
%                 * currentID
%
%  -- outputs --
%  LFP      :  Data table that has the following variables:
%                 * 'BlockID'    (Corresponds to recording Block)
%                 * 'AnimalID'   (Corresponds to Rat number)
%                 * 'ConditionID'(Corresponds to [0.0, 0.2, 0.4] mA)
%                 * 'CurrentID'  (Corresponds to ['Anodal','Cathodal'])
%                 * 'EpochID'    (Corresponds to ['Pre','Stim','Post'])
%                 * 'BandID'     (Corresponds to ['Delta','Theta',...])
%                 * 'Mean'       (Log-transformed power spectrum mean)
%                 * 'Median'     (Log-transformed power spectrum median)
%                 * 'NSamples'   (Non-masked time-series samples)
%                 * 'SD'         (Log-transformed power spectrum standard deviation)
%
%  S        :  Data table that has the following variables:
%                 * 'BlockID'       (Corresponds to recording Block)
%                 * 'AnimalID'      (Corresponds to Rat number)
%                 * 'ConditionID'   (Corresponds to [0.0, 0.2, 0.4] mA)
%                 * 'CurrentID'     (Corresponds to ['Anodal','Cathodal'])
%                 * 'EpochID'       (Corresponds to ['Pre','Stim','Post'])
%                 * 'NSamples'      (Non-masked time-series samples)
%                 * 'Spectrum_Mean' (Log-transformed average power spectrum)
%                 * 'Spectrum_SD'   (Log-transformed power spectrum SD)

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
      S = table.empty;
      for iRow = 1:size(ds_data,1)
         [tmpLFP,tmpS] = extract_LFP_bands(ds_data(iRow,:),varargin{:});
         LFP = vertcat(LFP,tmpLFP); %#ok<AGROW>
         S = vertcat(S,tmpS); %#ok<AGROW>
      end
      return;      
   end
   
   F = struct(...
      'Name',ds_data.BlockID,...
      'animalID',ds_data.AnimalID,...
      'conditionID',ds_data.ConditionID,...
      'currentID',ds_data.CurrentID...
      );
   fs = ds_data.fs;
   mask = ds_data.mask{:};
   ds_data = ds_data.data{:};
end
if ischar(F.Name)
   fprintf(1,'\t->\t[%s]: ',F.Name);
   blockID = strsplit(F.Name,'-');
   blockID = str2double(blockID{end});
elseif isnumeric(F.Name)
   fprintf(1,'\t->\t[TDCS-%02g]: ',F.Name);
   blockID = F.Name;
else
   error(['tDCS:' mfilename ':BadFormat'],...
      ['\n\t->\t<strong>[EXTRACT_LFP_BANDS]:</strong> '...
      'Unexpected class for `F.Name`: %s\n'],class(F.Name));
end

% Import parameters/parse input parameters
pars = parseParameters('LFP',varargin{:});
% Create reduced parameters struct
p = reduceParameters(pars,fs);
clear pars;

% Do not apply the mask yet; first compute PSD then apply mask. Note: we
% must subtract by 1 from window length (compared to the power spectrum
% estimate) in order to get the correct number of window points)
fprintf(1,'computing...');
[~,f,t,ps] = spectrogram(ds_data,p.WLEN,p.WIN_OVERLAP,p.FREQS,p.FS,'power');
fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\baveraging...');

ps_ = log(ps(:,~mask)); % Remove mask samples here (do not save version with removed samples)
t_ = t(1,~mask)./60; % Convert to minutes for comparison purposes
   
nEpoch = numel(p.EPOCH_NAMES);
nBand = numel(p.BANDS);
nRow = nBand * nEpoch;

                                             % Example formatting for
                                             % single recording Block (one
                                             % row of table, or vector of
                                             % `ds_data`):
BlockID  = ones(nRow,1).*blockID;            % [91;91;91;91;91;91;...]
AnimalID = ones(nRow,1).*F.animalID;         % [ 7; 7; 7; 7; 7; 7;...]
ConditionID = ones(nRow,1).*F.conditionID;   % [ 2; 2; 2; 2; 2; 2;...]
CurrentID = ones(nRow,1).*F.currentID;       % [-1;-1;-1;-1;-1;-1;...]
EpochID  = repmat((1:nEpoch).',nBand,1);     % [ 1; 2; 3; 1; 2; 3;...]
BandID   = repmat((1:nBand),nEpoch,1);     
BandID   = BandID(:);                        % [ 1; 1; 1; 2; 2; 2;...]

Mean = nan(nRow,1);
Median = nan(nRow,1);
NSamples = nan(nRow,1);
SD = nan(nRow,1);

iRow = 0;
for i = 1:nBand
   fc = p.FC.(p.BANDS{i});
   f_idx = (f>=fc(1)) & (f<=fc(2));
   ps_f = ps_(f_idx,:); % Note: ps_ is log-transformed, has mask applied
   p_mu = mean(ps_f,1);    % Keep for assignment
   p_med = median(ps_f,1); % Keep for assignment
   
   for k = 1:nEpoch
      iRow = iRow + 1;
      t_idx = (t_>=p.EPOCH_ONSETS(k)) & ...
              (t_<=p.EPOCH_OFFSETS(k));
      NSamples(iRow) = sum(t_idx);
      Mean(iRow) = mean(p_mu(t_idx));
      Median(iRow) = median(p_med(t_idx));
      SD(iRow) = std(p_mu(t_idx));
   end
end
LFP = table(BlockID,AnimalID,ConditionID,CurrentID,EpochID,BandID,...
   Mean,Median,NSamples,SD);
LFP.Properties.Description = ...
   'Contains "frequency band" statistics for the local field potential';
LFP.Properties.VariableDescriptions = ...
   {...
   'BlockID: (Corresponds to recording Block)'; ...
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
LFP.Properties.UserData = p; % Store parameters
LFP = setTableOutcomeVariable(LFP,'Mean');

BlockID = BlockID(1:nEpoch);
AnimalID = AnimalID(1:nEpoch);
ConditionID = ConditionID(1:nEpoch);
CurrentID = CurrentID(1:nEpoch);
EpochID = EpochID(1:nEpoch);
NSamples = NSamples(1:nEpoch);
Spectrum_Mean = zeros(nEpoch,numel(f));
Spectrum_SD = zeros(nEpoch,numel(f));
for k = 1:nEpoch
   t_idx = (t_>=p.EPOCH_ONSETS(k)) & ...
           (t_<=p.EPOCH_OFFSETS(k));
   Spectrum_Mean(k,:) = mean(ps_(:,t_idx),2).';
   Spectrum_SD(k,:) = std(ps_(:,t_idx),[],2).';
end
S = table(BlockID,AnimalID,ConditionID,CurrentID,EpochID,NSamples,...
   Spectrum_Mean,Spectrum_SD);
S.Properties.Description = ...
   'Contains full frequency power spectrum for each epoch';
S.Properties.VariableDescriptions = ...
   {...
   'BlockID: (Corresponds to recording Block)'; ...
   'AnimalID: (Corresponds to Rat number)'; ...
   'ConditionID: (Corresponds to [0.0, 0.2, 0.4] mA)'; ...
   'CurrentID: (Corresponds to {''Anodal'',''Cathodal''})'; ...
   'EpochID: (Corresponds to {''Pre'',''Stim'',''Post''})'; ...
   'NSamples: (Non-masked time-series samples)'; ...
   'Spectrum_Mean: (Log-transformed average power spectrum)'; ...
   'Spectrum_SD:   (Log-transformed power spectrum standard deviation)'...
   };
S.Properties.UserData = p;
S = setTableOutcomeVariable(S,'Spectrum_Mean');
fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');

   function p = reduceParameters(pars,fs)
      p = struct;
      p.EPOCH_NAMES = pars.EPOCH_NAMES;
      p.EPOCH_ONSETS = pars.EPOCH_ONSETS;
      p.EPOCH_OFFSETS = pars.EPOCH_OFFSETS;
      p.BANDS = pars.BANDS;
      p.FC = pars.FC;
      p.WLEN = pars.WLEN-1;
      p.WIN_OVERLAP = 0;
      p.FREQS = pars.FREQS; 
      p.FS = fs; 
      p.DESCRIPTIONS = struct(...
               'EPOCH_NAMES','Name of each epoch',...
               'EPOCH_ONSETS','Onset time of each epoch (minutes)',...
               'EPOCH_OFFSETS','Offset time of each epoch (minutes)',...
               'BANDS','Name of each frequency band (BandID indexes these)',...
               'FC','Cutoff frequency struct for each band (Hz)',...
               'WLEN','Length of segments used for fft',...
               'WIN_OVERLAP','Number of samples overlapped for fft segments',...
               'FREQS','Output frequencies returned by fft',...
               'FS','Sample rate of decimated dataset'...
            );
   end

end