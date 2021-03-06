% SpikeData = LoadSpikeSummaries;
% AppendedSpikeData = AppendGroupAssignments(SpikeData);
% S = getGrandEpochTable_Spikes(AppendedSpikeData);

genWholeTrialFigs(S,'Rate',@(x)log(x));
genWholeTrialFigs(S,'Regularity',[],...
   'BY_ANIMAL_FILE_NAME','LvR_by-Animal',...
   'BY_TREATMENT_FILE_NAME','LvR_by-Treatment',...
   'BY_TREATMENT_BY_EPOCH_FILE_NAME','LvR_by-Treatment_by-Epoch',...
   'XLAB','LvR (Regularity)',...
   'YLAB','Density',...
   'XTICK',[1 2],...
   'YTICK',[0 1 2 3],...
   'YTICKLAB',{'0','','','3'},...
   'YLIM',[-0.5 4],...
   'XLIM',[0 3],...
   'TEXT_X_OFFSET',1,...
   'TEXT_TAGX_OFFSET',0.75,...
   'XTICK_CROSSED',[1 2 3],...
   'YLIM_CROSSED',[-1 15],...
   'XLIM_CROSSED',[0.5 3]);

%% Next part, want to take differences between consecutive epochs
epochNames = {'dSTIM','dPOST1','dPOST2','dPOST3','dPOST4'};
dRate = getEpochDifferences(S,'Rate',@(x)log(x),'delta_logRate');
genWholeTrialFigs(dRate,'delta_logRate',[],...
   'BY_ANIMAL_FILE_NAME','dRate_by-Animal',...
   'BY_TREATMENT_FILE_NAME','dRate_by-Treatment',...
   'BY_TREATMENT_BY_EPOCH_FILE_NAME','dRate_by-Treatment_by-Epoch',...
   'XLAB','\delta log(spikes/second)',...
   'YLAB','Density',...
   'XTICK',[-3 0 3],...
   'YTICK',[0 1 2],...
   'YTICKLAB',{'0','','2'},...
   'YLIM',[0 2],...
   'XLIM',[-3 3],...
   'EPOCH_NAMES',epochNames,...
   'KS_OFFSETS',0:3:12,...
   'TEXT_X_OFFSET',3.5,...
   'TEXT_TAGX_OFFSET',-2.5,...
   'XTICK_CROSSED',[-3 0 3],...
   'YLIM_CROSSED',[-1 15],...
   'XLIM_CROSSED',[-3 4]);

% Likewise, for LvR
dLvR = getEpochDifferences(S,'Regularity',[],'delta_LvR');
genWholeTrialFigs(dLvR,'delta_LvR',[],...
   'BY_ANIMAL_FILE_NAME','dLvR_by-Animal',...
   'BY_TREATMENT_FILE_NAME','dLvR_by-Treatment',...
   'BY_TREATMENT_BY_EPOCH_FILE_NAME','dLvR_by-Treatment_by-Epoch',...
   'XLAB','\delta LvR',...
   'YLAB','Density',...
   'XTICK',[-1 0 1],...
   'YTICK',[0 1 2 3],...
   'YTICKLAB',{'0','','','3'},...
   'YLIM',[0 3],...
   'XLIM',[-1.5 1.5],...
   'EPOCH_NAMES',epochNames,...
   'KS_OFFSETS',0:4:16,...
   'TEXT_X_OFFSET',2,...
   'TEXT_TAGX_OFFSET',-1.25,...
   'XTICK_CROSSED',[-1 0 1],...
   'YLIM_CROSSED',[-1 19],...
   'XLIM_CROSSED',[-1.5 2.5]);

