function T = reduced_statistics_table(binned_spikes)
%REDUCED_STATISTICS_TABLE  Make binned spike rate statistics table for JMP
%
%  T = make.fr.reduced_statistics_table(binned_spikes);
%  -> `binned_spikes` : e.g. `data.binned_spikes` from `loadDataStruct()`

if isstruct(binned_spikes)
   binned_spikes = binned_spikes.binned_spikes;
end

INTENSITY = ordinal([1,2,3],{'0.0 mA','0.2 mA','0.4 mA'},[1,2,3]);
POLARITY = categorical({'Anodal','Cathodal'});

sqrt_FR = cellfun(@median,binned_spikes.sqrt_Stim);
delta_sqrt_FR = cellfun(@(x,y)median(x) - median(y),...
   binned_spikes.sqrt_Stim,binned_spikes.sqrt_Pre);
BlockID = binned_spikes.BlockID;
AnimalID = binned_spikes.AnimalID;
Polarity = binned_spikes.CurrentID;
Intensity = binned_spikes.ConditionID;
Channel = binned_spikes.Channel;
T = table(BlockID,AnimalID,Channel,sqrt_FR,delta_sqrt_FR);

% Now, reduce table
SHAM = Intensity == INTENSITY(1);
ANOD = (Intensity == INTENSITY(3)) & ...
       (Polarity == POLARITY(1));
CATH = (Intensity == INTENSITY(3)) & ...
       (Polarity == POLARITY(2));

POLARITY = addcats(POLARITY,{'Sham'});
POLARITY = [POLARITY, categorical({'Sham'},{'Anodal','Cathodal','Sham'})];

Treatment = repmat(POLARITY(1),sum(ANOD),1);
T_anod = T(ANOD,:);

Treatment = [Treatment; repmat(POLARITY(2),sum(CATH),1)];
T_cath = T(CATH,:);

Treatment = [Treatment; repmat(POLARITY(3),sum(SHAM),1)];
T_sham = T(SHAM,:);

T = vertcat(T_anod,T_cath,T_sham);
T = horzcat(T,table(Treatment));

T = T(:,[1,2,6,3,4,5]);

T.Properties.Description = 'Statistics export table; Anodal or Cathodal are each 0.4 mA';
T.Properties.VariableDescriptions = {...
   'Recording block identifier', ...
   'Animal identifier',...
   'Treatment group',...
   'Recording channel identifier',...
   'Median square-root rate during Stim epoch',...
   'Difference between median square-root rate during Stim epoch and median square-root rate during Pre epoch' ...
   };

if nargout < 1
   [dataTank,fname] = defs.FileNames(...
      'DIR','SPIKE_REDUCED_STATISTICS_CSV_TABLE');
   outFile = fullfile(dataTank,fname);
   if exist(outFile,'file')~=0
      str = questdlg('Overwrite file?','Confirm overwrite','Yes','Cancel','Yes');
      if strcmpi(str,'Yes')
         writetable(T,outFile);
         fprintf(1,'<strong>File saved successfully:</strong>\n\t->\t''%s''\n',...
            outFile);
      else
         fprintf(1,'<strong>''%s''</strong> already exists. Overwrite canceled.\n',...
            outFile);
      end
   else
      writetable(T,outFile);
      fprintf(1,'<strong>File saved successfully:</strong>\n\t->\t''%s''\n',...
         outFile);
   end
end

end