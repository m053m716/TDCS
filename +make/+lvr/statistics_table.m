function T = statistics_table(lvr)
%STATISTICS_TABLE  Make statistics table for JMP
%
%  T = make.lvr.statistics_table(lvr);
%
%  -- Inputs --
%  lvr : Table of LvR data by epoch (`data.LvR` from `loadDataStruct()`)
%
%  -- Output --
%  T   : Table of LvR data for statistics in JMP

if nargin < 1
   in = load(fullfile(defs.FileNames('DIR'),...
      defs.FileNames('SPIKE_SERIES_LVR_TABLE')),'T');
   lvr = in.T;
end

uA = unique(lvr.AnimalID);
if numel(uA) > 1
   T = table.empty;
   for i = 1:numel(uA)
      l = lvr(lvr.AnimalID == uA(i),:);
      T = [T; make.lvr.statistics_table(l)]; %#ok<*AGROW>
   end   
   return;
end

EPOC = ordinal([1,2,3]);
CON = ordinal([1,2,3],{'0.0 mA','0.2 mA','0.4 mA'},[1,2,3]);

stim_data = lvr(lvr.EpochID == EPOC(2),:);
pre_data = lvr(lvr.EpochID == EPOC(1),:);

dLvR = stim_data.LvR - pre_data.LvR;
uCh = unique(stim_data.Channel);

norm_dLvR = [];
Channel = [];
Intensity = [];
Polarity = [];
BlockID = [];
AnimalID = [];
for i = 1:numel(uCh)
   iCh = stim_data.Channel == uCh(i);
   iCON = stim_data.ConditionID == CON(1);
   iEXP = ~iCON;
   controlVal = mean(dLvR(iCh & iCON));
   idx = iCh & iEXP;
   norm_dLvR = [norm_dLvR; (dLvR(idx) - controlVal)]; 
   Channel = [Channel; stim_data.Channel(idx)];
   Intensity = [Intensity; stim_data.ConditionID(idx)];
   Polarity = [Polarity; stim_data.CurrentID(idx)];
   BlockID = [BlockID; stim_data.BlockID(idx)];
   AnimalID = [AnimalID; stim_data.AnimalID(idx)];
end
Intensity = droplevels(Intensity,'0.0 mA');
T = table(BlockID,AnimalID,Intensity,Polarity,Channel,norm_dLvR);
T.Properties.Description = 'Difference in change in LvR between experimental conditions and sham stimuli';
T.Properties.VariableDescriptions = {...
   'Recording Identifier', ...
   'Animal Identifier', ...
   'tDCS current intensity', ...
   'tDCS current polarity',...
   'Recording channel Identifier',...
   'Difference in change between LvR from Pre to Stim for this channel vs average in SHAM conditions'...
   };

end