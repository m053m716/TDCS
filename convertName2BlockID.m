function BlockID = convertName2BlockID(Name)
%CONVERTNAME2BLOCKID  Utility to convert cell char 'TDCS' name to Block ID
%
%  BlockID = convertName2BlockID(Name);
%  --> Works for `Name` as either a cell array of char, or directly on char

conversionFunc = @(C)str2double(C((regexp(C,'-','once')+1):end));
nestedFun = @(C)conversionFunc(char(C)); % Ensure it's a `char` array
switch class(Name)
   case 'cell'
      BlockID = cellfun(nestedFun,Name);
   case 'char'
      BlockID = nestedFun(Name);
   case 'string'
      BlockID = nestedFun(Name);
   otherwise
      error(['tDCS:' mfilename ':BadCase'],...
         ['\n\t->\t<strong>[TDCS.CONVERTNAME2BLOCKID]:</strong> ' ...
          'Invalid class: (''<strong>%s</strong>'')\n' ...
          '\t\t`Name` should be one of the following:\n' ...
          '\t\t->\t<strong>''cell''</strong>\n' ...
          '\t\t->\t<strong>''char''</strong>\n' ...
          '\t\t->\t<strong>''string''</strong>\n'],class(Name));
end
end