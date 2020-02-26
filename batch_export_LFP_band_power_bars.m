if exist('F','var')==0
   load(fullfile(defs.FileNames('DIR'),defs.FileNames('DATA_STRUCTURE')),'F');
end
F = F([F.included] & ~isnan([F.animalID]) & ~isnan([F.conditionID]));

%% Export by session
for iF = 1:numel(F)
   if ~F(iF).included
      continue;
   end
   in = load(fullfile(F(iF).block,sprintf(defs.LFP('LFP_FILE'),F(iF).base)),'P');
   addPowerBars3(in.P,...
      'TITLE',F(iF).base,...
      'BATCH',true,...
      'OUTPUT_FILE',fullfile(F(iF).block,'Figures',[F(iF).base '_LFP_Band_Power']));
end

%% Export by animal
uA = unique([F.animalID]);
fn = defs.LFP('BANDS');
nEpoch = numel(defs.Experiment('EPOCH_NAMES'));
for iA = 1:numel(uA)
   idx = find([F.animalID] == uA(iA));
   P = struct;
   for i = 1:numel(fn)
      P.(fn{i}) = struct('mu_z',zeros(1,nEpoch),'sd_z',zeros(1,nEpoch),'n',zeros(1,nEpoch));
   end
   for iF = 1:numel(idx)
      in = load(fullfile(F(idx(iF)).block,sprintf(defs.LFP('LFP_FILE'),F(idx(iF)).base)),'P');
      for i = 1:numel(fn)
         P.(fn{i}).mu_z = P.(fn{i}).mu_z + in.P.(fn{i}).mu_z / numel(idx);
         P.(fn{i}).sd_z = P.(fn{i}).sd_z + in.P.(fn{i}).sd_z / numel(idx);
         P.(fn{i}).n = P.(fn{i}).n + in.P.(fn{i}).n;
      end
   end
   aName = sprintf('R-TDCS-%g',uA(iA));
   addPowerBars3(P,...
      'TITLE',sprintf('%s (N = %g sessions)',aName,numel(idx)),...
      'BATCH',true,...
      'OUTPUT_FILE',...
      fullfile(defs.FileNames('OUTPUT_FIG_DIR'),'BARS_LFP-Band-Power',aName));
   
end

%% Export by condition
uC = unique([F.conditionID]);
fn = defs.LFP('BANDS');
nEpoch = numel(defs.Experiment('EPOCH_NAMES'));
tNames = defs.Experiment('NAME_KEY');
fNames = defs.Experiment('TREATMENT_FILE_KEY');
for iC = 1:numel(uC)
   idx = find([F.conditionID] == uC(iC));
   P = struct;
   for i = 1:numel(fn)
      P.(fn{i}) = struct('mu_z',zeros(1,nEpoch),'sd_z',zeros(1,nEpoch),'n',zeros(1,nEpoch));
   end
   for iF = 1:numel(idx)
      in = load(fullfile(F(idx(iF)).block,sprintf(defs.LFP('LFP_FILE'),F(idx(iF)).base)),'P');
      for i = 1:numel(fn)
         P.(fn{i}).mu_z = P.(fn{i}).mu_z + in.P.(fn{i}).mu_z / numel(idx);
         P.(fn{i}).sd_z = P.(fn{i}).sd_z + in.P.(fn{i}).sd_z / numel(idx);
         P.(fn{i}).n = P.(fn{i}).n + in.P.(fn{i}).n;
      end
   end
   cName = tNames{uC(iC)};
   fName = fNames{uC(iC)};
   addPowerBars3(P,...
      'TITLE',sprintf('%s (N = %g sessions)',cName,numel(idx)),...
      'BATCH',true,...
      'OUTPUT_FILE',...
      fullfile(defs.FileNames('OUTPUT_FIG_DIR'),'BARS_LFP-Band-Power',fName));
   
end