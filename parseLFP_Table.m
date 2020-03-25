function LFP_Table = parseLFP_Table(F,Assignment)
%PARSELFP_TABLE  Returns table with LFP data file metadata
%
%  LFP_Table = parseLFP_Table();
%  >> Loads F and Assignment from saved files (see all-caps locations)
%
%  LFP_TABLE = parseLFP_Table(F,Assignment);
%  >> Takes F and Assignment directly as arguments

% Defaults
dataTank = defs.FileNames('DIR');
aFileName = defs.FileNames('EPOCH_DATA');
assignmentFile = fullfile(dataTank,aFileName);

% Load data
if nargin < 1
   F = loadOrganizationData;
elseif ischar(F)
   in = load(F,'F');
   F = in.F;
end

if nargin < 2
   in = load(assignmentFile,'Assignment');
   Assignment = in.Assignment;
elseif ischar(Assignment)
   in = load(Assignment,'Assignment');
   Assignment = in.Assignment;
end

% Create table
LFP_Table = organizeLFPData(F,Assignment); % few seconds

end