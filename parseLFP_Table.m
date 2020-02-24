function LFP_Table = parseLFP_Table(F,Assignment)
%PARSELFP_TABLE  Returns table with LFP data file metadata
%
%  LFP_Table = parseLFP_Table();
%  >> Loads F and Assignment from saved files (see all-caps locations)
%
%  LFP_TABLE = parseLFP_Table(F,Assignment);
%  >> Takes F and Assignment directly as arguments

% Defaults
DIR = defs.FileNames('DIR');
FNAME = defs.FileNames('DATA_STRUCTURE');
ANAME = defs.FileNames('EPOCH_DATA');
F_FILE = fullfile(DIR,FNAME);
A_FILE = fullfile(DIR,ANAME);

% Load data
if nargin < 1
   in = load(F_FILE,'F');
   F = in.F;
elseif ischar(F)
   in = load(F,'F');
   F = in.F;   
end

if nargin < 2
    in = load(A_FILE,'Assignment');
    Assignment = in.Assignment;
elseif ischar(Assignment)
   in = load(Assignment,'Assignment');
   Assignment = in.Assignment;
end

% Create table
LFP_Table = organizeLFPData(F,Assignment); % few seconds

end