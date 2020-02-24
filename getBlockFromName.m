function [shortName,blockName] = getBlockFromName(name,tank)
%GETBLOCKFROMNAME  Return block name from shortened version of name
%
%  [shortName,blockName] = GETBLOCKFROMNAME(name);
%  >> [shortName,blockName] = getBlockFromName('TDCS-85_2017_04_18_01');
%  >> [shortName,blockName] = getBlockFromName('TDCS-85');
%  >> [shortName,blockname] = getBlockFromName(85);
%
%  >> All would return
%     * shortName : 'TDCS-85';
%     * blockName : 'TDCS-85_2017_04_18_01';

if nargin < 2
   tank = defs.Experiment('PROCESSED_TANK');
end

if iscell(name)
   blockName = cell(size(name));
   for i = 1:numel(name)
      blockName{i} = getBlockFromName(name{i},tank);
   end
   return;
end

if isnumeric(name)
   name = sprintf('TDCS-%02g',name);
end

if ischar(name)
   [~,tmpname,~] = fileparts(name);
   strInfo = strsplit(tmpname,'_');
   if numel(strInfo) < 5 % Know convention has to be 5 delimited elements
      F = dir(fullfile(tank,tmpname,[tmpname '*']));
      shortName = name;
      blockName = F(1).name;
   else % Otherwise it was "long" blockName given
      shortName = strInfo{1};
      blockName = tmpname; 
   end
else
   error('Bad input class: %s',class(name));
end

end