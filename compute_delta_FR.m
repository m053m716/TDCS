function dFR_table = compute_delta_FR(FR_table,T_mask,avg)
%COMPUTE_DELTA_FR  Computes change from median baseline FR in 1-second bins
%
%  dFR_table = compute_delta_FR(FR_table,mask);
%  --> FR_table : Table returned by `compute_binned_FR` or cell array of
%                 tables. Each table contains:
%                    * Name,
%                    * AnimalID,
%                    * ConditionID,
%                    * CurrentID, 
%                    * Channel, and 
%                    * Rate
%
%  --> T_mask :    Mask table from `fullMask2ChannelEpochmask(T,FR_table)`
%                    Obtained from RMS threshold. HIGH value indicates
%                    that it is considered an artifact period ( > 500
%                    microvolts RMS for that 1-second epoch)
%
%  dFR_table = compute_delta_FR(FR_table,mask,avg);
%  --> avg : Vector that is the same number of rows as FR_table cell
%              elements (each of which represent a different epoch)
%              * This vector is the median square-root of each time-series
%                 of 1-second binned firing rates computed by
%                 `compute_binned_FR` for the BASAL epoch only.
%              * If only one input argument is given, this is computed from
%                 the first cell element of `FR_table` input
%
%  --> dFR_table : Output table in same format as FR_table, but with column
%                    `delta_sqrt_Rate` instead of `Rate`

if nargin < 3
   if ~iscell(FR_table)
      error(['tDCS:' mfilename ':BadSyntax'],...
         ['\n\t->\t<strong>[TDCS]:</strong> ' ...
         'If only 1 input argument, `FR_table` must be cell array.\n']);
   end
   vec = 1:600;
   avg = cell2mat(cellfun(@(x,m)median(sqrt(x(vec(m(vec)))),2),...
      FR_table{1}.Rate,T_mask{1}.mask,'UniformOutput',false));
elseif ~iscell(avg)
   avg = num2cell(avg);
end

% Iterate if it is a table
if iscell(FR_table)
   dFR_table = cell(size(FR_table));
   maintic = tic;
   for i = 1:numel(FR_table)
      fprintf(1,'<strong>Epoch:</strong> %g\n',i);
      dFR_table{i} = compute_delta_FR(FR_table{i},T_mask{i},avg);
   end
   toc(maintic);
   return;
end

subtic = tic;
dFR_table = FR_table;
% sqRate = FR_table.Rate;
sqRate = cellfun(@(r)sqrt(r),FR_table.Rate,'UniformOutput',false);
dR = cellfun(@(r,r_avg)eqn.delta_F(r,r_avg),sqRate,avg,'UniformOutput',false); 
idx = strcmp(FR_table.Properties.VariableNames,'Rate');
dFR_table.Properties.VariableNames{idx} = 'delta_sqrt_Rate';
dFR_table.delta_sqrt_Rate = dR;
dFR_table = innerjoin(dFR_table,T_mask);
fprintf(1,'\t->\t');
toc(subtic);

end