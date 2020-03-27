function T = setTableOutcomeVariable(T,outcomeVariableName,transformFcn)
%SETTABLEOUTCOMEVARIABLE  Sets UserData field for "DependentVariable"
%
%  T = setTableOutcomeVariable(T,outcomeVariableName);
%  T = setTableOutcomeVariable(T,outcomeVariableName,transformFcn);
%
%  -- inputs --
%  T : Data table with rows that have independent categorical or other sort
%        of nominal variables, as well as "dependent" output variable that
%        is numeric, continuous, and scalar.
%
%  outcomeVariableName : (char) name of outcome variable
%           + If not in T.Properties.VariableNames, then throws an error
%           + To be stored in T.Properties.UserData.DependentVariable
%
%  transformFcn : (optional) Function handle used to transform output
%                       variable for visualization functions etc.
%           + To be stored in T.Properties.UserData.TransformFcn
%
%  -- output --
%  T : Same as input table with modified UserData property field for
%        "DependentVariable." If UserData is non-empty, then if UserData is
%        not a struct this will throw an error. Otherwise, if it's empty,
%        initializes UserData as a struct with only the .DependentVariable
%        field.

varIndex = strcmp(T.Properties.VariableNames,outcomeVariableName);
if sum(varIndex)~=1
   error(['tDCS:' mfilename ':BadVariableName'],...
      ['\n\t->\t<strong>[SETTABLEOUTCOMEVARIABLE]:</strong> ' ...
      'Invalid variable name: %s (not a member of table variables)\n'],...
      outcomeVariableName);
end

if isempty(T.Properties.UserData)
   T.Properties.UserData = struct;
elseif ~isstruct(T.Properties.UserData)
   error(['tDCS:' mfilename ':BadUserData'],...
      ['\n\t->\t<strong>[SETTABLEOUTCOMEVARIABLE]:</strong> ' ...
      'Invalid UserData: Table already has UserData but not a struct.\n']);
end

T.Properties.UserData.DependentVariable = outcomeVariableName;
if nargin > 2
   T.Properties.UserData.TransformFcn = transformFcn;
else
   T.Properties.UserData.TransformFcn = '';
end

end