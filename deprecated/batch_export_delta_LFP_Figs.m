%BATCH_EXPORT_UPDATED_DELTA_LFP_FIGS  Export delta FR, delta LFP stats, figs
% (Start: 2020-03-23 tDCS update)

clear; clc

% % % % % % If `LFP` table not yet extracted % % % % % % % %
% % Load data (should be fast: < 1 second)
% [dataTank,maskFile,dsFile,lfpFile,lfpSpreadsheet] = ...
%    defs.FileNames('DIR','MASK_TABLE','DS_TABLE','LFP_TABLE','LFP_SPREADSHEET');
% mask = load(fullfile(dataTank,maskFile),'T'); % "Full trial" RMS data mask
% data = load(fullfile(dataTank,dsFile),'T'); % "By-epoch" cell of spike rate tables
% 
% T = innerjoin(data.T,mask.T);
% clear mask data
% LFP = extract_LFP_bands(T); % (couple of minutes)
% clear T
% save(fullfile(dataTank,lfpFile),'LFP','-v7.3'); % (small file)
% writetable(LFP,fullfile(dataTank,lfpSpreadsheet));

% % % % % % If `LFP` table already extracted % % % % % % % %
[dataTank,lfpFile] = defs.FileNames('DIR','LFP_TABLE');
load(fullfile(dataTank,lfpFile),'LFP');

