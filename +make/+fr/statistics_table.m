function T = statistics_table(binned_spikes)
%STATISTICS_TABLE  Make binned spike rate statistics table for JMP
%
%  T = make.fr.statistics_table(binned_spikes);
%  -> `binned_spikes` : e.g. `data.binned_spikes` from `loadDataStruct()`

if isstruct(binned_spikes)
   binned_spikes = binned_spikes.binned_spikes;
end

sqrt_FR = cellfun(@median,binned_spikes.sqrt_Stim);
delta_sqrt_FR = cellfun(@(x,y)median(x) - median(y),...
   binned_spikes.sqrt_Stim,binned_spikes.sqrt_Pre);
BlockID = binned_spikes.BlockID;
AnimalID = binned_spikes.AnimalID;
Polarity = binned_spikes.CurrentID;
Intensity = binned_spikes.ConditionID;
Channel = binned_spikes.Channel;
T = table(BlockID,AnimalID,Polarity,Intensity,Channel,sqrt_FR,delta_sqrt_FR);
T.Properties.Description = 'Statistics export table';
T.Properties.VariableDescriptions = {...
   'Recording block identifier', ...
   'Animal identifier',...
   'tDCS current polarity',...
   'tDCS current intensity',...
   'Recording channel identifier',...
   'Median square-root rate during Stim epoch',...
   'Difference between median square-root rate during Stim epoch and median square-root rate during Pre epoch' ...
   };

end