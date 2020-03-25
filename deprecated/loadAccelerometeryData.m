function acc = loadAccelerometeryData(name,tank)
%LOADACCELEROMETERYDATA  Load saved accelerometery data for a given animal
%
%  acc = LOADACCELEROMETERYDATA(name);
%  >> acc = loadAccelerometeryData('TDCS-85');
%  >> acc = loadAccelerometeryData(85);
%  

if nargin < 2
   tank = defs.Experiment('PROCESSED_TANK');
end


if iscell(name)
   acc = initAccStruct(numel(name));
   for i = 1:numel(name)
      acc(i) = loadAccelerometeryData(name{i},tank);
   end
   return;
end

[shortName,blockName] = getBlockFromName(name);
fprintf(1,'\nLoading accelerometery for: <strong>%s</strong>\n',shortName);
accFile = fullfile(tank,shortName,blockName,[blockName defs.Experiment('ACC_TAG')]);
if exist(accFile,'file')==0
   acc = initAccStruct(0);
   return;
end
acc = load(accFile);

end