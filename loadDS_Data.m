function [data,fs] = loadDS_Data(name,tank)
%LOADDS_DATA  Load <strong>AVERAGE</strong> down-sampled data for animal
%
%  [data,fs] = LOADDS_DATA(name);
%  >> data = loadDS_Data('TDCS-85');
%  >> data = loadDS_Data(85);
%
%  data : Returns 1 x nTimesteps avg data, sampled at `fs` 
%  fs   : Sample rate (samples per second)

if nargin < 2
   tank = defs.Experiment('PROCESSED_TANK');
end

if iscell(name)
   F = [];
   for i = 1:numel(name)
      F = vertcat(F,find_DS_files_from_name(name{i},tank)); %#ok<AGROW>
   end
else
   F = find_DS_files_from_name(name,tank);
end

if isempty(F)
   data = []; fs = nan;
   fprintf(1,'<strong>Missing:</strong> DS data\n');
   return;
end
m = matfile(fullfile(F(1).folder,F(1).name));
n = size(m,'data',2); %#ok<GTARG>
data = m.data(1,1:n) ./ numel(F);
fs = m.fs;
tic;
for iF = 2:numel(F)
   m = matfile(fullfile(F(iF).folder,F(iF).name));
   data = data + (m.data(1,1:n) ./numel(F));
end
toc;

   function F = find_DS_files_from_name(name,tank)
      [shortName,blockName] = getBlockFromName(name);
      fprintf(1,'\nLoading downsampled raw data for: <strong>%s</strong>\n',shortName);
      ds_f = fullfile(tank,shortName,blockName,[blockName defs.Experiment('DS_FOLDER')]);
      F = dir(fullfile(ds_f,[blockName defs.Experiment('DS_TAG')]));
   end

end