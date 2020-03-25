%MAIN  Main code for processing and outline of figure generation
%
%  Main output data is kept in "Table struct" -- `T`
%  Main data organization struct array is `F`
%
%  Default parameters, etc. are found in the `+defs` package; any named
%  file in `+defs` can be parsed from `varargin` of a function call using
%  the syntax:
%  >> pars = parseParameters('defsFunctionName',varargin{:});
%  >> e.g.
%  >> pars = parseParameters('FileNames',varargin{:});

clear; clc;
maintic = tic;

%% Main path info is where is the data stored
dataTank = defs.FileNames('DIR');
addHelperRepos; % Add any helper repositories as needed

%% Export mask (see defs.Experiment('DS_BIN_WIDTH') for mask binning size)
F = loadOrganizationData;
make_RMS_mask(F);              % Makes RMS mask based on DS "common-reference" data
T = loadRMSMask_Table(F); % Organize all RMS data into a table
save(fullfile(dataTank,defs.FileNames('MASK_TABLE')),'T','-v7.3');
data.mask = T; clear T;
toc(maintic);

%% Export spike rates table using same bins as Mask & LFP data
T.raw_spikes = loadSpikeSeries_Table(F);
T.binned_spikes = compute_binned_FR(T.raw_spikes);
toc(maintic);

%% Export decimated (raw) data for LFP extraction
