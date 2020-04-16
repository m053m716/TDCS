function T = compute_binned_FR(T,varargin)
%COMPUTE_BINNED_FR  Computes # spikes in fixed bins over duration of train
%
%  T = compute_binned_FR(T);
%  T = compute_binned_FR(T,'NAME',value,...);
%  
%  -- inputs --
%  T        : Table with spike trains in 'Train' variable as sparse
%                     vectors sampled at rate in 'FS' variable.
%     --> Loaded using 
%        >> T = loadSpikeTrains_Table('D:\MATLAB\Data\tDCS');
%
%  varargin : 'NAME',value input argument pairs for defs.Spikes default
%                    parameters struct.
%  
%  -- outputs --
%  T        : Table with variables:
%                    * BlockID,
%                    * AnimalID,
%                    * ConditionID,
%                    * CurrentID, 
%                    * Channel, and 
%                    * Rate

if ~ismember(T.Properties.VariableNames,'Train')
   error(['tDCS:' mfilename ':WrongTable'],...
      ['\n\t->\t<strong>[COMPUTE_BINNED_FR]:</strong> ' ...
      'Missing `Train` Variable (check this table is at correct step)\n']);
end

pars = parseParameters('Spikes',varargin{:});

% Iterate if it is a table
subtic = tic;
nRows = size(T,1);
h = waitbar(0,'Binning for spike rates...');
N = nan(nRows,1);
for i = 1:nRows
   samples_per_bin = round(T.FS(i) * pars.DS_BIN_DURATION); 
   n = histcounts(find(T.Train{i}),1:samples_per_bin:size(T.Train{i},1));
   FR = n ./ pars.DS_BIN_DURATION;      % Scale to spikes per second
   T.Train{i} = FR(1:numel(T.mask{i})); % Make sure it's the correct length
   N(i) = samples_per_bin;
   waitbar(i/nRows);
end
delete(h);

clusterVarIndex = strcmp(T.Properties.VariableNames,'Cluster');
T(:,clusterVarIndex) = []; % Remove "Cluster" variable

% Fix name of "Train" variable
trainVarIndex = strcmp(T.Properties.VariableNames,'Train');
T.Properties.VariableNames{trainVarIndex} = 'Rate';
T = [T, table(N)];

iMove = find(strcmp(T.Properties.VariableNames,'N'),1,'first');
iBefore = find(strcmp(T.Properties.VariableNames,'Rate'),1,'first');
nCol = size(T,2); % movevar not present in R2017a
T = T(:,[setdiff(1:(iBefore-1),iMove), iMove, setdiff(iBefore:nCol,iMove)]);

T.Properties.Description = ...
   ['Binned Multi-unit activity ' newline ...
    '`Rate` is a "decimated" signal with # of multi-unit spikes in bin'];
idx = strcmp(T.Properties.VariableNames,'Channel');
T.Properties.VariableDescriptions{idx} = 'Channel: Recording microwire channel';
idx = strcmp(T.Properties.VariableNames,'N');
T.Properties.VariableDescriptions{idx} = 'N: Number of samples per bin';
idx = strcmp(T.Properties.VariableNames, 'Rate');
T.Properties.VariableDescriptions{idx} = 'Rate: Spikes per second';
idx = strcmp(T.Properties.VariableNames,'FS');
T.Properties.VariableDescriptions{idx} = 'FS: Sample rate of original record';

T.Properties.UserData = pars; % Save parameters with smaller table
T.Properties.UserData.TABLE_TYPE = 'binned_FR';
fprintf(1,'\t->\t');
toc(subtic);

end