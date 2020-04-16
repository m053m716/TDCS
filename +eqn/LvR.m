function LvR_out = LvR(t,R)
%LVR Returns the modified Coefficient of Variation for a set of spikes
%
%  LvR_out = eqn.LvR(t);
%  -> Default value of `R` is 0.0015 (1.5 ms)
%  --> Note, this was set empirically based on correlation between output
%      LvR vs multi-unit spike rates we observed
%
%  LvR_out = eqn.LvR(t,R);
%
%  -- Input --
%  t        :  Numeric vector of spike timestamps (seconds)
%
%  -- Output --
%  LvR_out  :  Coefficient indicating the "randomness" or "uniformity" of
%                 the spiking time-series, while accounting for intrinsic
%                 biases that are firing-rate-dependent.
%
%  Adapted from: 'Relating Neuronal Firing Patterns to Functional
%  Differentiation of Cerebral Cortex.' Shinomoto et al. (2009)

% Parameters
%Default
R = 0.005;          %Refractoriness (s)

% Fix dimension of t
t = reshape(t,1,numel(t));
 
I = diff(t);    %Interspike interval
n = length(I);  %Number of interspike intervals
norm = 3/(n-1); %Normalization constant

% Calculate
%Accumulate all summands from index = 1:(n-1)
summand = 0;
for ii = 1:(n-1)
    summand = summand + ...
        (1 - 4*I(ii)*I(ii+1)/((I(ii)+I(ii+1))^2)) * ...
        (1 + 4*R/(I(ii) + I(ii+1)));    
end

% Output
%Output the LvR value for a given segment of a spike train.
% LvR_out = norm * summand;
if n > 10
    LvR_out = norm * summand;
else
    LvR_out = nan;
end

if LvR_out == 0
    LvR_out = nan;
end

end