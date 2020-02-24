function includedFlag = checkIncluded(F,n)
%CHECKINCLUDED  Checks "data organization struct array" F for Block # n
%
%  includedFlag = CHECKINCLUDED(F,n);
%
%  F : Struct array in '2017 TDCS Data Structure Organization.mat'
%  n : Scalar or array of integer values corresponding to block # (e.g.
%        TDCS-02 == 2);

if numel(n) > 1
   includedFlag = false(size(n));
   for i = 1:numel(n)
      includedFlag(i) = checkIncluded(F,n(i));
   end
   return;
end

blockName = sprintf('TDCS-%02g',n);
blockList = {F.name};
idx = ismember(blockList,blockName);
if sum(idx)~=1
   includedFlag = false;
   return;
end

includedFlag = F(idx).included;

end