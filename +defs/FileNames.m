function varargout = FileNames(varargin)
%FILENAMES  Names of various files saved on KUMC server
%
%  pars = defs.FileNames();
%  [var1,var2,...] = defs.SpikeStats('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
% Major parameters
pars.DIR = local.Configuration('DIR');
pars.RAW_BINARY_LOCATION = 'R:\Rat\Intan\TDCS';
pars.DATA_STRUCTURE = '2017 TDCS Data Structure Organization.mat';

% Figures
pars.OUTPUT_FIG_DIR = fullfile(pars.DIR,'Figures');
pars.RAINCLOUD_FIG_DIR = fullfile(pars.OUTPUT_FIG_DIR,'RainCloudPlots');
pars.BY_ANIMAL_FIG_NAME = 'Whole-trial: by Rat';
pars.BY_ANIMAL_FILE_NAME = 'by-Animal';
pars.BY_TREATMENT_FIG_NAME = 'Whole-trial: by Treatment';
pars.BY_TREATMENT_FILE_NAME = 'by-Treatment';
pars.BY_TREATMENT_BY_EPOCH_FIG_NAME = 'Whole-Trial: by Treatment and Epoch';
pars.BY_TREATMENT_BY_EPOCH_FILE_NAME = 'by-Treatment_by-Epoch';

% Block Sub-folders & Tags
pars.RAW_DIR_TAG = '_RawData';
pars.CAR_DIR_TAG = '_FilteredCAR';
pars.SPIKE_DIR_TAG = '_wav-sneo_CAR_Spikes';
pars.DS_DIR_TAG = '_DS';
pars.SUMMARY_TAG = '_SpikeSummary.mat';   % Spike summary file ID
pars.STIM_EPOCH_TIMES_FILE = '_StimEpochTimes.mat';

% Specific Tables/Files
pars.SUPP_MAT_TABLE = 'Supplementary_Recordings_Table.mat';
pars.SUPP_CSV_TABLE = 'Supplementary_Recordings_Table.csv';
pars.RMS_MASK_FILE = '%s_RMS-Mask_30-sec.mat';
pars.LFP_FILE = '%s_LFP.mat';
pars.LFP_STATS_FILE = 'LFP_BandPower_Stats';
pars.LFP_RM_STATS_FILE = 'LFP_RM_BandPower_Stats';
pars.LFP_DETAILED_STATS_FILE = 'LFP_Detailed_BandPower_Stats';
pars.LFP_DETAILED_STATS_TS_FILE = 'LFP_Detailed_BandPower_Stats_TimeSeries';
pars.STIM_EPOCH_TABLE = '2020-04-02_Stim-Epoch-Times-Table.mat';
pars.RATE_CHANGES = '2017-07-18_Rate Changes.mat';
pars.WORKSPACE = '2017-07-20_tDCS Workspace.mat';
pars.DS_TABLE = '2020-03-17_DS-Table.mat';
pars.MASK_TABLE = '2020-03-25_Mask-Table_30-sec.mat';
pars.RATE_SERIES_TABLE = '2020-03-17_Rate-Table.mat';
pars.SPIKE_EPOCHS_TABLE = '2020-03-31_Spikes-Epochs.mat';
pars.SPIKE_EPOCHS_SPREADSHEET = '2020-03-31_Spikes-Epochs.csv';
pars.SPIKE_SERIES_TABLE = '2020-03-23_Full-Spike-Series.mat';
pars.SPIKE_SERIES_BINNED_TABLE = '2020-03-25_Full-Spike-Series_Binned.mat';
pars.SPIKE_SERIES_DELTA_TABLE = '2020-03-25_Full-Spike-Series_Deltas.mat';
pars.SPIKE_SERIES_LVR_TABLE = '2020-03-26_Full-Spike-Series_LvR.mat';
pars.SPIKE_SERIES_LVR_SPREADSHEET = '2020-03-26_Full-Spike-Series_LvR.csv';
pars.SPIKE_DELTAS_TABLE = '2020-03-31_Spike-Deltas-Table.mat';
pars.SPIKE_DELTAS_SPREADSHEET = '2020-03-31_Spike-Deltas-Table.csv';
pars.SPIKE_DELTAS_MEDIAN_TABLE = '2020-03-31_Spike-Deltas-Medians-Table.mat';
pars.SPIKE_DELTAS_MEDIAN_SPREADSHEET = '2020-03-31_Spike-Deltas-Medians-Table.csv';
pars.SPECTRUM_TABLE = '2020-03-26_LFP-Spectrum-Table.mat';
pars.PANEL_SPECTRUM_FIGURE_NAME = 'LFP Spectrum Panelized Changes';
pars.PANEL_RATE_FIGURE_NAME = 'Spike Rate Panelized Changes';
pars.LFP_TABLE = '2020-03-25_LFP-Table.mat';
pars.LFP_SPREADSHEET = '2020-03-25_LFP-Table.csv';
pars.LVR_RM_ANOVA_FILE = '2020-04-07_RM-ANOVA-LvR.mat'; % Results of stats.fit.LvR_RM_Model


% Deprecated
pars.OUTPUT_STATS_DIR_CSV = 'J:\Rat\tDCS\2020_Stats';
pars.OUTPUT_STATS_DIR_MAT = fullfile(pars.OUTPUT_STATS_DIR_CSV,'_mat');
pars.OUTPUT_STATS_DIR_SPIKES = 'J:\Rat\tDCS\2020_Stats\2020-03-17_1s-bin_Analyses\scratchwork\Spikes';
pars.OLD_CSV_SPIKES = 'TDCS_Spikes.csv';
pars.DATABASE = 'Stats'; % Name of SQLExpress Statistics server on CPL-VISION
pars.DATABASE_LFP = struct('Atomic','Stats.dbo.LFPid','Key','Stats.dbo.LFPkey'); 
pars.LFP = '2017-07-13_LFP Data.mat';
pars.EPOCH_DATA = '2017-06-17_Concatenated Epoch Data.mat';
pars.ASSIGNMENT_FILE = '2017-06-14_Excluded Metric Subset.mat';
% pars.SPIKE_SERIES = '2017-11-22_Updated Spike Series.mat';
% pars.SPIKE_SERIES = '2020-03-17_Spike-Trains-Table.mat';

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
      for iV = 1:nargin
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end