function name = catID2Name(blockID)
%CATID2NAME  Convert from categorical version of ID to char name
%
%  name = catID2Name(blockID)

% Iterate on array input
if numel(blockID) > 1
   name = cell(size(blockID));
   for i = 1:numel(blockID)
      name{i} = catID2Name(blockID(i));
   end
   return;
end

if ~iscategorical(blockID)
   name = sprintf('TDCS-%02g',blockID);
   return;
else
   s = char(blockID);
   if numel(s)<2
      s = ['0' s];
   end
   name = sprintf('TDCS-%s',s);
   return;
end

end