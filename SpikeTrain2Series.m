function SpikeSeries = SpikeTrain2Series(AppendedSpikeTrainData)
%% SPIKETRAIN2SERIES    Convert spike trains to spike time series
%
%   SpikeSeries = SPIKETRAIN2SERIES(SpikeTrainData)
%
%   --------
%    INPUTS
%   --------
%   SpikeTrainData  :   Spike train data loaded in for tDCS analysis.
%                       Contains tables with the column 'Train' where cells
%                       of sparse vectors contain the sample index
%                       occurrences of spikes. 
%
%   --------
%    OUPTUT
%   --------
%   SpikeSeries     :   Table output that contains time series for all
%                       spike trains where the rate estimates are obtained
%                       using a sliding window.
%
% By: Max Murphy    v1.0    07/13/2017  Original version (R2017a)

%% DEFAULTS
WLEN = 0.5;       % Window length

%% INITIALIZE
NUnits = size(AppendedSpikeTrainData{1,1},1);
Name = AppendedSpikeTrainData{1,1}.Name;
Channel = AppendedSpikeTrainData{1,1}.Channel;
Cluster = AppendedSpikeTrainData{1,1}.Cluster;
Animal = AppendedSpikeTrainData{1,1}.Animal;
Condition = AppendedSpikeTrainData{1,1}.Condition;

SpikeSeries = cell(size(AppendedSpikeTrainData));
Y = cell(NUnits,1);
T = cell(NUnits,1);
OPTW = cell(NUnits,1);
GS = cell(NUnits,1);
C = cell(NUnits,1);
CONFB95 = cell(NUnits,1);
YB = cell(NUnits,1);

%% GET RATE SERIES ESTIMATES
fprintf(1,'\n\tEstimating instantaneous rates for period: ');
tic;
for iEpoch = 1:numel(SpikeSeries)
   fprintf(1,'%d...',iEpoch);
   for ii = 1:NUnits
       N = numel(AppendedSpikeTrainData{1,iEpoch}.Train{ii});
       FS = AppendedSpikeTrainData{1,iEpoch}.FS(ii);
       W = round(FS * WLEN);
       T_SAMP = 1:W:N;
       spk = find(AppendedSpikeTrainData{1,iEpoch}.Train{ii});
       [Y{ii},T{ii},OPTW{ii},GS{ii},C{ii},CONFB95{ii},YB{ii}]= ...
          ssvkernel(spk,T_SAMP);
       Y{ii} = Y{ii} * FS * numel(spk);
       CONFB95{ii} = CONFB95{ii} * FS * numel(spk);
       YB{ii} = YB{ii} * FS * numel(spk);
       T{ii} = T{ii} / FS;
   end
   SpikeSeries{1,iEpoch} = table(Name,Channel,Cluster,Animal,Condition,...
      Y,T,OPTW,GS,C,CONFB95,YB);
end
fprintf(1,'complete.\n');
toc;

end