function T = loadLFP_Table(F,varargin)
%LOADLFP_TABLE  Loads LFP data table with metadata and LFP time-series
%
%  T = loadLFP_Table():
%  --> Loads LFP_Table using `parseLFP_Table.m`
%
%  T = loadLFP_Table(LFP_Table);
%  --> Loads LFP_Table using specified LFP_Table.
%  --> T is the same as LFP_Table, but has an additional variable (column)
%      which contains the LFP data.

pars = parseParameters('FileNames',varargin{:});

if nargin < 1
   in = load(fullfile(pars.DIR,pars.DATA_STRUCTURE),'F');
   F = in.F;
end

maintic = tic;
Name = {F.name}.';
AnimalID = [F.animalID].';
ConditionID = ceil([F.conditionID].'/2);
CurrentID = [F.currentID].';

N = numel(F);
data = cell(N,1);
fs = nan(N,1);

h = waitbar(0,'Extracting downsampled data table...');
for i = 1:N
   [data{i},fs(i)] = loadDS_Data(Name{i},pars.DIR);
   waitbar(i/N,h);
end
T = table(Name,AnimalID,ConditionID,CurrentID,data,fs);
delete(h);
toc(maintic);

end