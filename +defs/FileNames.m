function varargout = FileNames(varargin)
%FILENAMES  Names of various files saved on KUMC server
%
%  pars = defs.FileNames();
%  [var1,var2,...] = defs.SpikeStats('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.DIR = 'P:\Rat\tDCS';
pars.DATABASE = 'Stats'; % Name of SQLExpress Statistics server on CPL-VISION
pars.DATABASE_LFP = struct('Atomic','Stats.dbo.LFPid','Key','Stats.dbo.LFPkey'); 
pars.OUTPUT_FIG_DIR = 'J:\Rat\tDCS\2020_Figures';
pars.OUTPUT_STATS_DIR_CSV = 'J:\Rat\tDCS\2020_Stats';
pars.OUTPUT_STATS_DIR_MAT = fullfile(pars.OUTPUT_STATS_DIR_CSV,'_mat');
pars.OUTPUT_STATS_DIR_SPIKES = 'J:\Rat\tDCS\2020_Stats\scratchwork\Spikes';
pars.RATE_CHANGES = '2017-07-18_Rate Changes.mat';
pars.WORKSPACE = '2017-07-20_tDCS Workspace.mat';
% pars.SPIKE_SERIES = '2017-11-22_Updated Spike Series.mat';
pars.SPIKE_SERIES = '2020-03-17_Spike-Trains-Table.mat';
pars.DS_TABLE = '2020-03-17_DS-Table.mat';
pars.LFP = '2017-07-13_LFP Data.mat';
pars.DATA_STRUCTURE = '2017 TDCS Data Structure Organization.mat';
pars.EPOCH_DATA = '2017-06-17_Concatenated Epoch Data.mat';
pars.ASSIGNMENT_FILE = '2017-06-14_Excluded Metric Subset.mat';

% SUBFOLDERS
pars.RAW_DIR_TAG = '_RawData';
pars.CAR_DIR_TAG = '_FilteredCAR';
pars.SPIKE_DIR_TAG = '_wav-sneo_CAR_Spikes';
pars.DS_DIR_TAG = '_DS';

% SPECIFIC FILES
pars.RMS_MASK_FILE = '%s_RMS-Mask.mat';
pars.LFP_FILE = '%s_LFP.mat';
pars.LFP_STATS_FILE = 'LFP_BandPower_Stats';
pars.LFP_RM_STATS_FILE = 'LFP_RM_BandPower_Stats';
pars.LFP_DETAILED_STATS_FILE = 'LFP_Detailed_BandPower_Stats';
pars.LFP_DETAILED_STATS_TS_FILE = 'LFP_Detailed_BandPower_Stats_TimeSeries';

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