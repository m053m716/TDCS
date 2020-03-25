%BATCH_EXPORT_UPDATED_DELTA_FIGS  Export delta FR, delta LFP stats, figs
% (Start: 2020-03-23 tDCS update)

clear; clc

% % % % % To create "formattedRateFile" % % % % % %
% Load data (should be fast: < 1 second)
% [dataTank,maskFile,rateFile,formattedRateFile] = ...
%    defs.FileNames('DIR','MASK_TABLE','SPIKE_SERIES_TABLE','SPIKE_SERIES_FORMATTED');
% mask = load(fullfile(dataTank,maskFile),'T'); % "Full trial" RMS data mask
% series = load(fullfile(dataTank,rateFile),'T'); % "By-epoch" cell of spike rate tables
% T = fullMask2ChannelEpochMask(mask.T,series.T); % "By-epoch" cell of mask tables
% 
% clear mask series
% 
% % Compute change in firing rate
% T = compute_binned_FR(T);
% T = compute_delta_FR(T); % fast ( < 1 second )
% T = fixChannelIDs(T); % Should all be "8-23"
% 
% save(fullfile(dataTank,formattedRateFile),'T','-v7.3');

% % % % % If "formattedRateFile" already exists % % % % %
[dataTank,formattedRateFile] = ...
   defs.FileNames('DIR','SPIKE_SERIES_FORMATTED');
load(fullfile(dataTank,formattedRateFile),'T');

%
batch_export_delta_Rate_Figs(T);
