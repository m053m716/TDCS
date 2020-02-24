function NSData = getNSstatistics(AppendedSpikeTrainData,varargin)
%% GETNSSTATISTICS  Get nonstationarity statistics for tDCS analysis.
%
%   NSData = GETNSSTATISTICS(AppendedSpikeTrainData,'NAME',value,...)
%
% By: Max Murphy    v1.0    07/20/2017

%% DEFAULTS
PERIOD = 2;         % SpikeTrainData Period to use:
                    %   1 : BASAL
                    %   2 : STIM
                    %   3 : POST-1
                    %   4 : POST-2
                    %   5 : POST-3
                    %   6 : POST-4
                    
NS_THRESH = 30;     % Non-stationarity surprise detection level

%% PARSE VARARGIN
for iV = 1:2:numel(varargin)
    eval([upper(varargin{iV}) '=varargin{iV+1};']);
end

%% GET STATISTICS: ONSET TIME AND DURATION
X = AppendedSpikeTrainData{1,PERIOD}.NS;
T = AppendedSpikeTrainData{1,PERIOD}.t_NS;
N = size(X,1);


NS_START = nan(N,1);
NS_DUR = nan(N,1);

for iX = 1:N
    x = X(iX,:);
    t = T(iX,:);
    
    for iT = 2:(numel(t)-1)
        if (x(iT) > NS_THRESH && ...
            x(iT-1) > NS_THRESH && ...
            x(iT+1) > NS_THRESH)
                NS_START(iX) = t(iT);
                break;
        end
    end
    NS_DUR(iX) = sum(x > NS_THRESH);
end

%% MAKE OUTPUT TABLE
Name = AppendedSpikeTrainData{1,PERIOD}.Name;
Channel = AppendedSpikeTrainData{1,PERIOD}.Channel;
Cluster = AppendedSpikeTrainData{1,PERIOD}.Cluster;
Animal = AppendedSpikeTrainData{1,PERIOD}.Animal;
Condition = AppendedSpikeTrainData{1,PERIOD}.Condition;

NSData = table(Name,Channel,Cluster,Animal,Condition,NS_START,NS_DUR);

end