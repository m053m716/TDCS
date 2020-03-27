function out = replicateColumnVar(in,n,preserveOrder)
%REPLICATECOLUMNVAR  Replicates column vector `in,` `n` times
%
%  out = replicateColumnVar(in,n);
%  out = replicateColumnVar(in,n,preserveOrder);
%  
%  -- Inputs --
%  in    :     Input column vector (numeric, cell, etc.)
%  n     :     Number of replications 
%  
%  ## Example 1 ##
%  ```
%     in = [1;2;3];
%     n = 2;
%     out = replicateColumnVar(in,n)
%  ```
%  Results in out == [1;1;2;2;3;3];
%
%  preserveOrder : (Optional) flag; by default set to true. If set to
%                    false, then the column is simply replicated `n` times
%
%  ## Example 2 ##
%  ```
%     in = [1;2;3];
%     n = 2;
%     out = replicateColumnVar(in,n,false)    
%  ```
%  Results in out == [1;2;3;1;2;3];
%
%  -- Output --
%  out   :     Output column vector. See examples above for details.

if nargin < 3
   preserveOrder = true;
end

if ischar(in)
   charFlag = true;
   in = cellstr(in);
else
   charFlag = false;
end

if preserveOrder
   in = repmat(in.',n,1);
   out = in(:);
else
   out = repmat(in,n,1);
end

if charFlag
   out = cell2mat(out);
end

end