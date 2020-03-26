function T = compute_delta_FR(T,avg,varargin)
%COMPUTE_DELTA_FR  Computes change from median baseline FR in 1-second bins
%
%  T = compute_delta_FR(T,avg);
%  --> T : Table output from `compute_binned_FR`
%  --> avg : (optional) Average to subtract from each bin (from PRE epoch)
%
%  --> Output is same as input except `Rate` variable is replaced by
%  `delta_sqrt_Rate` variable.

if ~ismember(T.Properties.VariableNames,'Rate')
   error(['tDCS:' mfilename ':WrongTable'],...
      ['\n\t->\t<strong>[COMPUTE_BINNED_FR]:</strong> ' ...
      'Missing `Rate` Variable (check this table is at correct step)\n']);
end

pars = parseParameters('Spikes',varargin{:});

if nargin < 3
   vec = getEpochSampleIndices(T,1,pars);
   avg = cellfun(@(x,m,v)median(sqrt(x(v(~m(v)))),2),...
      T.Rate,T.mask,vec,'UniformOutput',false);
elseif ~iscell(avg)
   avg = num2cell(avg);
end

subtic = tic;
% sqRate = T.Rate;
sqRate = cellfun(@(r)sqrt(r),T.Rate,'UniformOutput',false);
T.Rate= cellfun(@(r,r_avg)eqn.delta_F(r,r_avg),sqRate,avg,'UniformOutput',false); 
idx = strcmp(T.Properties.VariableNames,'Rate');
T.Properties.VariableNames{idx} = 'delta_sqrt_Rate';
T.Properties.Description = ...
   ['% Change from Median "Pre-Stim" Binned Multi-unit Spikes' newline ...
    '`delta_sqrt_Rate` computed using `eqn.delta_F` function'];
T.Properties.VariableDescriptions{idx} = ...
   'delta_sqrt_Rate: % change from median rate during "Pre" epoch';
T.Properties.UserData = pars;
T.Properties.UserData.SQUARE_ROOT_TRANSFORM = true;
fprintf(1,'\t->\t');
toc(subtic);

end