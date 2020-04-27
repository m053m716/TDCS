function T = reduced_statistics_table(lvr)
%REDUCED_STATISTICS_TABLE  Make LvR reduced statistics table for JMP
%
%  T = make.lvr.reduced_statistics_table(lvr);
%  -> `lvr` : e.g. `data.LvR` from `loadDataStruct()`

if isstruct(lvr)
   lvr = lvr.LvR;
end

INTENSITY = ordinal([1,2,3],{'0.0 mA','0.2 mA','0.4 mA'},[1,2,3]);
POLARITY = categorical({'Anodal','Cathodal'});
EPOC = ordinal([1,2,3]);

iKeep = lvr.EpochID == EPOC(2);
LvR = lvr.LvR(iKeep);
delta_LvR = LvR - lvr.LvR(lvr.EpochID == EPOC(1));

BlockID = lvr.BlockID(iKeep);
AnimalID = lvr.AnimalID(iKeep);
Polarity = lvr.CurrentID(iKeep);
Intensity = lvr.ConditionID(iKeep);
Channel = lvr.Channel(iKeep);
T = table(BlockID,AnimalID,Channel,LvR,delta_LvR);

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

T.Properties.Description = ...
   ['LvR (reduced) statistics export table; ' newline ...
    'Anodal or Cathodal are each 0.4 mA'];
T.Properties.VariableDescriptions = {...
   'Recording block identifier', ...
   'Animal identifier',...
   'Treatment group',...
   'Recording channel identifier',...
   'LvR during Stim epoch',...
   'Difference between LvR during Stim epoch and LvR during Pre epoch' ...
   };

if nargout < 1
   [dataTank,fname] = defs.FileNames(...
      'DIR','LVR_REDUCED_STATISTICS_CSV_TABLE');
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
   clear T;
end

end