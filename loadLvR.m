function [T,f] = loadLvR()
%LOADDELTASPIKERATE  Loads table of 'Delta LvR' data
%
%  [T,f] = loadLvR()
%  --> T : Table with data
%  --> f : Name of file

[dataTank,filename] = defs.FileNames('DIR','SPIKE_SERIES_LVR_TABLE');
f = fullfile(dataTank,filename);
if exist(f,'file')~=2
   warning('%s does not exist.',f);
   T = table.empty;
   return;
end
in = load(f,'T');
if ~isfield(in,'T')
   warning('Missing table variable `T` in file %s',f);
   T = table.empty;
   return;
end
T = in.T;
T(isnan(T.LvR),:) = [];
T = setTableOutcomeVariable(T,'LvR','');

end