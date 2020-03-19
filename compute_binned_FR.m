function FR_table = compute_binned_FR(T_spiketrain,T_rms)
%COMPUTE_BINNED_FR  Computes FR in 1-second bins over duration of train
%
%  FR_table = compute_binned_FR(T_spiketrain);
%  --> T_spiketrain : Table with spike trains in 'Train' variable as sparse
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

% Iterate if it is a table
if iscell(T_spiketrain)
   FR_table = cell(size(T_spiketrain));
   maintic = tic;
   for i = 1:numel(T_spiketrain)
      fprintf(1,'<strong>Epoch:</strong> %g\n',i);
      FR_table{i} = compute_binned_FR(T_spiketrain{i},T_rms);
   end
   toc(maintic);
   return;
end

subtic = tic;
meta = T_rms(:,1:4);
tmp = innerjoin(T_spiketrain,meta);
N = size(tmp,1);
Rate = cell(N,1);
for i = 1:N
   Rate{i} = histcounts(find(tmp.Train{i}),1:tmp.FS(i):size(tmp.Train{i},1));
end
FR_table = [tmp(:,[1:2,6:8]), table(Rate)];
fprintf(1,'\t->\t');
toc(subtic);

end