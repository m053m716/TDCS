%BATCH_EXPORT_UPDATED_DELTA_LFP_FIGS  Export delta FR, delta LFP stats, figs
% (Start: 2020-03-23 tDCS update)

clear; clc

% Load data (should be fast: < 1 second)
[dataTank,maskFile,dsFile] = ...
   defs.FileNames('DIR','MASK_TABLE','DS_TABLE');
mask = load(fullfile(dataTank,maskFile),'T'); % "Full trial" RMS data mask
data = load(fullfile(dataTank,dsFile),'T'); % "By-epoch" cell of spike rate tables

T = innerjoin(data.T,mask.T);
clear mask data

[T,f] = convertDS2LFP(T);

% Compute change in firing rate
% dFR_table = compute_delta_FR(FR_table,T_mask); % fast ( < 1 second )

%
% batch_export_delta_Rate_Figs(dFR_table);
