function T = compute_delta_FR(T,varargin)
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

vec = getEpochSampleIndices(T,1:3,pars);
sqrt_Rate_Pre = cellfun(@(x,m,v)sqrt(x(v(~m(v)))),...
   T.Rate,T.mask,vec(:,1),'UniformOutput',false);
sqrt_Rate_Stim = cellfun(@(x,m,v)sqrt(x(v(~m(v)))),...
   T.Rate,T.mask,vec(:,2),'UniformOutput',false);
sqrt_Rate_Post = cellfun(@(x,m,v)sqrt(x(v(~m(v)))),...
   T.Rate,T.mask,vec(:,3),'UniformOutput',false);

subtic = tic;
% sqRate = T.Rate;
sqRate = cellfun(@(r)sqrt(r),T.Rate,'UniformOutput',false);
delta_sqrt_Rate = cellfun(@(r,r_avg)eqn.delta_F(r,r_avg),sqRate,...
   cellfun(@(C1)mean(C1,2),sqrt_Rate_Pre,'UniformOutput',false),...
   'UniformOutput',false); 
% idx = strcmp(T.Properties.VariableNames,'Rate');
% T.Properties.VariableNames{idx} = 'delta_sqrt_Rate';
% T.Properties.VariableDescriptions{idx} = ...
%    'delta_sqrt_Rate: % change from median rate during "Pre" epoch';

delta_sqrt_Pre = cellfun(@(r,r_avg)eqn.delta_F(r,r_avg),sqrt_Rate_Pre,...
   cellfun(@median,sqrt_Rate_Pre,'UniformOutput',false),...
   'UniformOutput',false); 

delta_sqrt_Stim = cellfun(@(r,r_avg)eqn.delta_F(r,r_avg),sqrt_Rate_Stim,...
   cellfun(@median,sqrt_Rate_Pre,'UniformOutput',false),...
   'UniformOutput',false); 

delta_sqrt_Post = cellfun(@(r,r_avg)eqn.delta_F(r,r_avg),sqrt_Rate_Post,...
   cellfun(@median,sqrt_Rate_Pre,'UniformOutput',false),...
   'UniformOutput',false); 

if ~ismember('delta_sqrt_Rate',T.Properties.VariableNames)
   T = [T, table(delta_sqrt_Rate)];
else
   T.delta_sqrt_rate = delta_sqrt_Rate;
end
T.Properties.VariableDescriptions{end} = ...
   'delta_sqrt_Rate: % change from median rate during "Pre" epoch';

if ~ismember('delta_sqrt_Pre',T.Properties.VariableNames)
   T = [T, table(delta_sqrt_Pre,delta_sqrt_Stim,delta_sqrt_Post)];
else
   T.delta_sqrt_Pre = delta_sqrt_Pre;
   T.delta_sqrt_Stim = delta_sqrt_Stim;
   T.delta_sqrt_Post = delta_sqrt_Post;
end

T.Properties.Description = ...
   ['% Change from Median "Pre-Stim" Binned Multi-unit Spikes' newline ...
    '`delta_sqrt_Rate` computed using `eqn.delta_F` function'];
T.Properties.UserData = pars;
T.Properties.UserData.SQUARE_ROOT_TRANSFORM = true;
fprintf(1,'\t->\t');
toc(subtic);

end