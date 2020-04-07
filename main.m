%MAIN  Main code for processing and outline of figure generation
%
%  Main output data is kept in "Table struct" -->  `data`
%  Main data organization struct array        -->  `F`
%
%  Most saved data tables *should* have `pars` (parameters struct) saved in
%  the UserData property, to give an indication of things like thresholds,
%  etc.
%
%  Default parameters, etc. are found in the `+defs` package; any named
%  file in `+defs` can be parsed from `varargin` of a function call using
%  the syntax:
%  >> pars = parseParameters('defsFunctionName',varargin{:});
%  >> e.g.
%  >> pars = parseParameters('FileNames',varargin{:});

%% Clear workspace and begin main timer
clear; clc;
maintic = tic;

%% Main path info is where is the data stored
dataTank = defs.FileNames('DIR');
data = struct;  % Initialize main data struct
addHelperRepos; % Add any helper repositories as needed

%% Export mask (see defs.Experiment('DS_BIN_WIDTH') for mask binning size)
F = loadOrganizationData;
make_RMS_mask(F);         % Makes RMS mask based on DS "common-reference" data
T = loadRMSMask_Table(F); % Organize all RMS data into a table
save(fullfile(dataTank,defs.FileNames('MASK_TABLE')),'T','-v7.3');
data.mask = T; clear T;
toc(maintic);

%% Export spike rates table using same bins as Mask & LFP data
data.raw_spikes = loadSpikeSeries_Table(F);
T = compute_binned_FR(data.raw_spikes);
save(fullfile(dataTank,defs.FileNames('SPIKE_SERIES_BINNED_TABLE')),'T','-v7.3');
data.binned_spikes = T; clear T;
T = compute_delta_FR(data.binned_spikes);
save(fullfile(dataTank,defs.FileNames('SPIKE_SERIES_DELTA_TABLE')),'T','-v7.3');
data.delta_spikes = T; clear T;
T = compute_epoch_LvR(data.raw_spikes);
save(fullfile(dataTank,defs.FileNames('SPIKE_SERIES_LVR_TABLE')),'T','-v7.3');
data.LvR = T; clear T;
toc(maintic);

% Export Spikes figures
batch_export_delta_Rate_Figs(data.delta_spikes,'SAVE_FIGS',true);
genSpikeRatePanelFigure(data.delta_spikes,...
   'TAG','_all-tests_Bonferroni',... 
   'AGGREGATE_SHAM',false,...
   'SIG_SHOW_PROBABILITY',true,...
   'SIG_TEST',@alltests); % Uses supremum of p[observed] of 4 tests
genSpikeRatePanelFigure(data.delta_spikes,...
   'TAG','_all-tests_Bonferroni_Brackets',... 
   'AGGREGATE_SHAM',false,...
   'SIG_SHOW_PROBABILITY',false,... % Plot only brackets instead of p[obs]
   'SIG_TEST',@alltests); % Uses supremum of p[obs] of 4 tests
genSpikeRatePanelFigure(data.delta_spikes,...
   'TAG','_all-tests_combine-SHAM_Bonferroni',... 
   'AGGREGATE_SHAM',true,...
   'SIG_SHOW_PROBABILITY',true,...
   'SIG_TEST',@alltests); % Uses supremum of p[observed] of 4 tests
genSpikeRatePanelFigure(data.delta_spikes,...
   'TAG','_all-tests_combine-SHAM_Bonferroni_Brackets',... 
   'AGGREGATE_SHAM',true,...
   'SIG_SHOW_PROBABILITY',false,... % Plot only brackets instead of p[obs]
   'SIG_TEST',@alltests); % Uses supremum of p[obs] of 4 tests

% Export LvR figures
if ~isfield(data,'LvR')
   data.LvR = loadLvR();
end
genRainCloudPlots(data.LvR);

% Export LvR stats
% S = stats.make.LvRTable(data.LvR);
% [rm,ranovatbl,A,C,D] = stats.fit.LvR_RM_Model(S);
% save(fullfile(dataTank,defs.FileNames('LVR_RM_ANOVA_FILE')),...
%       'S','rm','ranovatbl','A','C','D','-v7.3');

% Export Exemplar panels
getExemplar();

%% Export decimated (raw) data for LFP extraction

%% Export LFP statistics and figures
data.LFP = loadLFP_Table;

% Export "RainCloudPlots" for discrete Frequency-Band power
genLFPRainCloudPlots(data.LFP);

% Export LFP Spectra figures (def. alpha = 0.05)
genLFPSpectraPanelFigure(data.S,'SIG_SHOW_PROBABILITY',true); 
genLFPSpectraPanelFigure(data.S,'SIG_SHOW_PROBABILITY',false);