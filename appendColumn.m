function T = appendColumn(T,newColName,targetColName,targetFcn,isUniform,insertCol)
%APPENDCOLUMN Adds new column using data from existing columns
%
%  T = appendColumn(T,newColName,targetColName,targetFcn);
%  T = appendColumn(T,newColName,targetColName,targetFcn,isUniform);
%  T = appendColumn(T,newColName,targetColName,targetFcn,isUniform,insertCol);
%  
%  -- inputs --
%  T              :  Data table to extend
%  newColName     :  Name of new column to add to table (char array)
%  targetColName  :  Name of target column (char array)
%                 :  Name of target columns (cell array of char arrays)
%  targetFcn      :  Function handle to create contents of `newColName`
%                    --> Should return a vector that is [size(T,1) x 1]
%  isUniform      :  (Optional) true/false: 
%  insertCol      :  (Optional) Name of column to move inserted column to
%                                the left of.
%
%  -- output --
%  T              :  Data table with added `newColName`

% Check total # args
if nargin < 6
   if nargin < 5
      insertCol = '';
   elseif ischar(isUniform)
      insertCol = isUniform;
      isUniform = true;
   end
end

% Check if all 5 args present
if nargin < 5
   isUniform = true;
elseif nargin < 4
   error(['tDCS:' mfilename ':TooFewInputs'],...
      ['\n\t->\t<strong>[APPENDCOLUMN]:</strong> ' ...
       'At least 4 inputs are required\n']);
end

% Get a cell array of the column vectors to evaluate
C = packageColumnVectors(T,targetColName);

if iscell(C{1})
   data = cellfun(@(varargin)targetFcn(varargin{:}),C{:},...
      'UniformOutput',isUniform);
else
   data = targetFcn(C{:},'UniformOutput',isUniform);
end
T.(newColName) = data;

% Rearrange new column (inserting prior to `insertCol`)
if ~isempty(insertCol)
   T = movevars(T,newColName,'Before',insertCol);
end

   function C = packageColumnVectors(T,targetColName)
      %PACKAGECOLUMNVECTORS  Returns all target columns as cell array
      %
      %  C = packageColumnVectors(T,targetColName);
      
      if ischar(targetColName) || isstring(targetColName)
         C = {T.(targetColName)};
         return;
      end
      
      C = cell(size(targetColName));
      for iC = 1:numel(targetColName)
         C{iC} = T.(targetColName{iC});
      end
   end

end