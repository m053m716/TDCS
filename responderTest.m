function responderType = responderTest(medianSqrtRateChange,pLower,pUpper)
%RESPONDERTEST  Returns 1 for upper- or -1 for lower-percentile elements
%
%  responderType = responderTest(medianSqrtRateChange);
%
%  -- inputs --
%  medianSqrtRateChange : `T.Median` from `SPIKE_DELTAS_TABLE`
%                          --> Numeric column vector
%
%  pUpper : Upper percentile (scalar [0 - 100])
%  pLower : Lower percentile (scalar [0 - 100])
%  
%  ## Importing `T` ##
%  ```
%     tank = defs.FileNames('DIR');
%     old_csv = defs.FileNames('OLD_CSV_SPIKES');
%     T = import_TDCS_Spikes_old_csv(fullfile(tank,old_csv));
%  ```
%
%  -- output --
%  responderType        :  Vector where most elements are zero;
%                          -1 : In the bottom 5th-percentile 
%                                (most-negative changes)
%                          1  : In top 95th-percentile 
%                                (most-positive changes)

if nargin < 3
   pUpper = 95;
end

if nargin < 2
   pLower = 5;
end

responderType = zeros(size(medianSqrtRateChange));
uB = prctile(medianSqrtRateChange,pUpper);
lB = prctile(medianSqrtRateChange,pLower);

responderType(medianSqrtRateChange >= uB) =  1;
responderType(medianSqrtRateChange <= lB) = -1;

end