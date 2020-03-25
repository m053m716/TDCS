function T = compute_binned_FR(T)
%COMPUTE_BINNED_FR  Computes FR in 1-second bins over duration of train
%
%  T = compute_binned_FR(T);
%  --> T : Table with spike trains in 'Train' variable as sparse
%                     vectors sampled at rate in 'FS' variable.
%     --> Loaded using 
%        >> T = loadSpikeTrains_Table('D:\MATLAB\Data\tDCS');
%
%  --> FR_table : Table with variables:
%                    * Name,
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

% Iterate if it is a table
subtic = tic;
N = size(T,1);
for i = 1:N
   T.Train{i} = histcounts(find(T.Train{i}),1:T.FS(i):size(T.Train{i},1));
   T.Train{i} = T.Train{i}(1:numel(T.mask{i}));
end
idx = strcmp(T.Properties.VariableNames,'Train');
T.Properties.VariableNames{idx} = 'Rate';
fprintf(1,'\t->\t');
toc(subtic);

end