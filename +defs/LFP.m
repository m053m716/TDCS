function varargout = LFP(varargin)
%LFP  Pars describing each LFP "band" cutoff frequency.
%
%  pars = defs.LFP();
%  [var1,var2,...] = defs.LFP('var1Name','var2Name',...);


% DEFAULTS
% Main options
pars = struct;
pars.N_BIN_PER_BAND = 10;
pars.LFP_DATA_TAG = '_REF_';
pars.OUTPUT_FIG_DIR = defs.FileNames('OUTPUT_FIG_DIR');
pars.OUTPUT_STATS_DIR_CSV = defs.FileNames('OUTPUT_STATS_DIR_CSV');
pars.OUTPUT_STATS_DIR_MAT = defs.FileNames('OUTPUT_STATS_DIR_MAT');
pars.RMS_MASK_FILE = defs.FileNames('RMS_MASK_FILE');
pars.LFP_FILE = defs.FileNames('LFP_FILE');
pars.LFP_STATS_FILE = defs.FileNames('LFP_STATS_FILE');
pars.WLEN = defs.SlidingPower('WLEN');
pars.NSAMPLES_COV = 61; % How many samples "forward" and "backward" to use to estimate covariance matrix
pars.DESCRIPTION = struct(...
   'P', struct(...
      'BandName',struct(...
         'f',  'Frequencies averaged for this band',...
         'mu',   'Mean log-transformed/masked value for each epoch',...
         'mu_z', 'Mean log-transformed/masked + normalized/whitened value for each epoch',...
         'sd',   'Standard deviation of log-transformed/masked values for each epoch',...
         'sd_z', 'Standard deviation of log-transformed/masked + normalized/whitened values for each epoch',...
         'n',  'Total number of time-samples in each band/epoch combination',...
         'z',  'Whitened (masked & log-transformed) power values for full recording')),...
   'f', 'Frequencies for obtained estimates in rows of `ps`',...
   't', 'Time of each column of `ps`',...
   'ps','Spectral POWER (not PSD) estimates',...
   'fs','Sample rate of channel-average LFP used to compute `ps`');

% LFP band names can be anything, as fields of .FC; ranges are in Hz as 
%  >> pars.FC.('bandName') = [fc_lower  fc_higher];
pars.FC = struct;
pars.FC.Delta        = [2    4];
pars.FC.Theta        = [4    8];
pars.FC.Alpha        = [8   12];
pars.FC.Beta         = [12  30];
pars.FC.Low_Gamma    = [30  50];
pars.FC.High_Gamma   = [70 105];

% From generic "Experiment" defaults:
pars.EPOCH_NAMES = defs.Experiment('EPOCH_NAMES'); % {'BASAL','STIM','POST1','POST2','POST3','POST4'}; % Labels of epochs
pars.EPOCH_ONSETS = defs.Experiment('EPOCH_ONSETS'); % [5  15 35 50 65 80]; % (Values in minutes)
pars.EPOCH_OFFSETS = defs.Experiment('EPOCH_OFFSETS'); % [15 35 50 65 80 95]; % (Values in minutes)


% These are parsed based on fields of pars.FC (LFP bands)
pars.BANDS = fieldnames(pars.FC);
pars.FREQS = [];
for i = 1:numel(pars.BANDS)
   fc = pars.FC.(pars.BANDS{i});
   pars.FREQS = [pars.FREQS, ...
      logspace(log10(fc(1)),log10(fc(2)),pars.N_BIN_PER_BAND)];
end
pars.FREQS = sort(pars.FREQS,'ascend');
   
if nargin < 1
   varargout = {pars};   
else
   F = fieldnames(pars);   
   if (nargout == 1) && (numel(varargin) > 1)
      varargout{1} = struct;
      for iV = 1:numel(varargin)
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{1}.(F{idx}) = pars.(F{idx});
         end
      end
   elseif nargout > 0
      varargout = cell(1,nargout);
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{iV} = pars.(F{idx});
         end
      end
   else
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end