function [s,n] = SlidingPower(x,varargin)
%SLIDINGPOWER Get power in a sliding window using RMS of signal
%
%   [s,n] = SLIDINGPOWER(x,'NAME',value,...)
%
%   --------
%    INPUTS
%   --------
%      x        :       Signal from which to extract RMS in sliding window.
%
%   varargin    :       (Optional) 'NAME', value input argument pairs
%
%                       -> 'WLEN' : (Default: 1000) Number of samples in
%                                   sliding window
%                       -> 'OV'   : (Default: 0.5) Fraction [0 to 1] of
%                                   overlap for each consecutive window.
%
%   --------
%    OUTPUT
%   --------
%      s        :       Signal RMS in sliding window
%
%      n        :       Index of original signal around which window was
%                       averaged (i.e. the "middle" of the window).
%
% See also: SIMPLE_LFP_ANALYSIS, BANDPOWER

% DEFAULTS
pars = parseParameters('SlidingPower',varargin{:});

if rem(pars.WLEN,2)==0
   error(['TDCS:' mfilename ':BadParam'],...
      'pars.WLEN must be odd (current value: %g)\n',pars.WLEN);
end

N = numel(x);

% GET SLIDING POWER VALUES
w = -floor(pars.WLEN/2):floor(pars.WLEN/2);
nSkip = min(max((pars.WLEN-1)*(1 - pars.OV),1),pars.WLEN);
n = ceil(pars.WLEN/2):nSkip:(N-floor(pars.WLEN/2));
s = nan(size(n));
for i = 1:numel(n)
    s(i) = rms(x(w+n(i)));
end

end