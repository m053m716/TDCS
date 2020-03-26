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
N = size(T,1);
h = waitbar(0,'Binning for spike rates...');
for i = 1:N
   samples_per_bin = round(T.FS(i) * pars.DS_BIN_DURATION); 
   n = histcounts(find(T.Train{i}),1:samples_per_bin:size(T.Train{i},1));
   FR = n ./ pars.DS_BIN_DURATION;      % Scale to spikes per second
   T.Train{i} = FR(1:numel(T.mask{i})); % Make sure it's the correct length
   T.Cluster(i) = samples_per_bin;
   waitbar(i/N);
end
delete(h);
trainVarIndex = strcmp(T.Properties.VariableNames,'Train');
clusterVarIndex = strcmp(T.Properties.VariableNames,'Cluster');
T.Properties.VariableNames{trainVarIndex} = 'Rate';
T.Properties.VariableNames{clusterVarIndex} = 'N';
T.Properties.Description = ...
   ['Binned Multi-unit activity ' newline ...
    '`Rate` is a "decimated" signal with # of multi-unit spikes in bin'];
T.Properties.VariableDescriptions{2} = 'Channel: Recording microwire channel';
T.Properties.VariableDescriptions{3} = 'N: Number of samples per bin';
T.Properties.VariableDescriptions{4} = 'Rate: Spikes per second';
T.Properties.VariableDescriptions{5} = 'FS: Sample rate of original record';
T.Properties.UserData = pars; % Save parameters with smaller table
fprintf(1,'\t->\t');
toc(subtic);

end