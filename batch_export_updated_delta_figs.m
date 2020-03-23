%BATCH_EXPORT_UPDATED_DELTA_FIGS  Export delta FR, delta LFP stats, figs
% (Start: 2020-03-23 tDCS update)

clear; clc

% Load data (should be fast: < 1 second)
[dataTank,maskFile,rateFile] = ...
   defs.FileNames('DIR','MASK_TABLE','RATE_SERIES_TABLE');
load(fullfile(dataTank,maskFile),'T'); % "Full trial" RMS data mask
load(fullfile(dataTank,rateFile),'FR_table'); % "By-epoch" cell of spike rate tables
T_mask = fullMask2ChannelEpochMask(T,FR_table); % "By-epoch" cell of mask tables

% Compute change in firing rate
dFR_table = compute_delta_FR(FR_table,T_mask); % fast ( < 1 second )
clear FR_table T

%
batch_export_delta_Rate_Figs(dFR_table);
