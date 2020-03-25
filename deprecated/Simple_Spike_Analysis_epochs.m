%% Simple script to iterate spike analysis on each epoch
clear; clc;
F = loadOrganizationData();
[tStart,tStop] = defs.EpochLabels('EPOCH_ONSETS','EPOCH_OFFSETS');
% e = defs.EpochLabels('EPOCH_NAMES');
% D = struct; SPK = struct;
for iEpoch = 1:numel(tStart)
%    [D.(e{iEpoch}),SPK.(e{iEpoch})] = Simple_Spike_Analysis(F, ...
%       'TSTART',tStart(iEpoch),'TSTOP',tStop(iEpoch));
   Simple_Spike_Analysis(F,'TSTART',tStart(iEpoch),'TSTOP',tStop(iEpoch));
end