function [p2pamp,ts_index,pmin,dt,E,Zs,thresh] = SNEO_Threshold(data,pars,art_idx)
%SNEO_THRESHOLD   Smoothed nonlinear energy operator thresholding detect
%
%  [p2pamp,ts_index,pmin,dt,E,Zs,thresh] = SNEO_THRESHOLD(data,pars,art_idx)
%
%   --------
%    INPUTS
%   --------
%     data      :       1 x N double of bandpass filtered data, preferrably
%                       with artifact excluded already, on which to perform
%                       monopolar spike detection.
%
%     pars      :       Parameters structure from SPIKEDETECTCLUSTER with
%                       the following fields:
%
%       -> SNEO_N    \\ number of samples for smoothing window
%       -> MULTCOEFF \\ factor to multiply NEO noise threshold by
%
%    art_idx   :        Indexing vector for artifact rejection periods,
%                       which are temporarily removed so that thresholds
%                       are not underestimated.
%
%   --------
%    OUTPUT
%   --------
%    p2pamp     :       Peak-to-peak amplitude of spikes.
%
%     ts        :       Timestamps (sample indices) of spike peaks.
%
%    pmin       :       Value at peak minimum. (pw) in SPIKEDETECTIONARRAY
%
%      dt       :       Time difference between spikes. (pp) in
%                       SPIKEDETECTIONARRAY
%
%      E        :       Smoothed nonlinear energy operator value at peaks.
%
%     Zs        :       Smoothed nonlineaer energy operator stream
%
%     thresh    :       Struct with following fields
%                       --> 'sneo' : SNEO threshold used
%                       --> 'data' : Threshold used on input data for
%                                      minimum peak height. Corresponds to
%                                      NEGATIVE version of signal (only
%                                      looking for negative-going peaks).

if nargin < 3
   art_idx = [];
end

if nargin < 2
   pars = struct(...
      'SNEO_N',5,...       % Number of smoothing samples
      'MULTCOEFF',4.5,...  % Threshold multiplier
      'NS_AROUND',7,...    % # samples around peak to "look"
      'PLP',20);           % Pulse lifetime period
end

% GET NONLINEAR ENERGY OPERATOR SIGNAL AND SMOOTH IT
Y = data - mean(data);
Yb = Y(1:(end-2));
Yf = Y(3:end);
Z = [0, Y(2:(end-1)).^2 - Yb .* Yf, 0]; % Discrete nonlinear energy operator
Zs = eqn.fastsmooth(Z,pars.SNEO_N);

% CREATE THRESHOLD FILTER
tmpdata = data;
tmpdata(art_idx) = [];
tmpZ = Zs;
tmpZ(art_idx) = [];

thresh = struct;
thresh.sneo = pars.MULTCOEFF * median(abs(tmpZ));
thresh.data = pars.MULTCOEFF * median(abs(tmpdata));

% PERFORM THRESHOLDING
pk = Zs > thresh.sneo;

if sum(pk) <= 1
   p2pamp = [];
   ts_index = [];
   pmin = [];
   dt = [];
   return
end

% REDUCE CONSECUTIVE CROSSINGS TO SINGLE POINTS
z = zeros(size(data));
pkloc = repmat(find(pk),pars.NS_AROUND*2+1,1) + (-pars.NS_AROUND:pars.NS_AROUND).';
pkloc(pkloc < 1) = 1;
pkloc(pkloc > numel(data)) = numel(data);
pkloc = unique(pkloc(:));

z(pkloc) = data(pkloc);
[pmin,ts_index] = findpeaks(-z,... % Align to negative peak
               'MinPeakHeight',thresh.data);
E = Zs(ts_index);            


% GET PEAK-TO-PEAK VALUES
tloc = repmat(ts_index,2*pars.PLP+1,1) + (-pars.PLP:pars.PLP).';
tloc(tloc < 1) = 1;
tloc(tloc > numel(data)) = numel(data);
pmax = max(data(tloc));

p2pamp = pmax + pmin;

% EXCLUDE VALUES OF PMAX <= 0
pm_ex = pmax<=0;
ts_index(pm_ex) = [];
p2pamp(pm_ex) = [];
pmax(pm_ex) = [];
pmin(pm_ex) = [];
E(pm_ex) = [];

% GET TIME DIFFERENCES
if numel(ts_index)>1
   dt = [diff(ts_index), round(median(diff(ts_index)))];
else
   dt = [];
end


end