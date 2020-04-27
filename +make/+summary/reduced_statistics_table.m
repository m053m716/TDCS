function T = reduced_statistics_table(data)
%REDUCED_STATISTICS_TABLE  Make FULL reduced statistics table for JMP
%
%  T = make.summary.reduced_statistics_table(data);
%  -> `data` : e.g. data = loadDataStruct();

if nargin < 1
   data = loadDataStruct();
end

RESPONDER_CAT = categorical({'Decrease','No Change','Increase'});

T = make.lvr.reduced_statistics_table(data.LvR);
T_rate = make.fr.reduced_statistics_table(data.binned_spikes);
T.LvR = T_rate.delta_sqrt_FR;
Response = repmat(RESPONDER_CAT(2),size(T,1),1);

nRespond = round(0.05 * numel(Response));
del_FR = T_rate.delta_sqrt_FR;
del_FR(isnan(del_FR)) = 0; % Don't count NaN values one way or other, but keep for indexing
[del_FR,iResponse] = sort(del_FR,'ascend');
Response(iResponse(1:nRespond)) = repmat(RESPONDER_CAT(1),nRespond,1);
Response(iResponse((end-nRespond+1):end)) = repmat(RESPONDER_CAT(3),nRespond,1);
T.Response = Response;


T.Properties.Description = ...
   ['(Reduced) combined statistics export table; ' newline ...
    'Anodal or Cathodal are each 0.4 mA'];
T.Properties.VariableDescriptions = {...
   'Recording block identifier', ...
   'Animal identifier',...
   'Treatment group',...
   'Recording channel identifier',...
   'Difference between median square-root rate during Stim epoch and median square-root rate during Pre epoch', ...
   'Difference between LvR during Stim epoch and LvR during Pre epoch', ...
   'Classification of Unit Response' ...
   };
idx = strcmp(T.Properties.VariableNames,'LvR');
T.Properties.VariableNames{idx} = 'delta_sqrt_FR';
T = sortrows(T,{'BlockID'},'ascend');

if nargout < 1
   [dataTank,fname] = defs.FileNames(...
      'DIR','REDUCED_COMBINED_CSV_TABLE');
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