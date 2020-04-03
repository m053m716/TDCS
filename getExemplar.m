function [raw,filt,sneo,ts,p,t,ch,fig] = getExemplar(E,F,iBlock,iCh,nSamples)
%GETEXEMPLAR  Return exemplar data
%
%  [raw,filt,sneo,ts,p,t] = getExemplar(E,F);
%  --> Uses defaults for other 2 arguments
%   -> raw : `raw` signal in "exemplar" times of interest around transition
%   -> filt : same as `raw` but with bandpass filter & re-reference applied
%   -> sneo : threshold signal used for spike detection, from `filt`
%   -> ts   : Spike times from threshold crossings included in range
%   -> p    : Values at spike peaks (minima)
%   -> t    : times (sec) corresponding to each sample
%
%  [raw,filt,sneo,ts,p,t] = getExemplar(E,F,iBlock);
%  --> Default `iBlock` is 10 (TDCS-28)
%
%  [raw,filt,sneo,ts,p,t] = getExemplar(E,F,iBlock,iCh,nSamples);
%  --> Default `iCh` is 1 [NOTE: This indexes files, not channels]
%  --> Default `nSamples` is 1000 (-1000 : +1000)
%
%  [raw,filt,sneo,ts,p,t,ch,fig] = getExemplar(__);
%  --> ch  : Return char array corresponding to channel number of file
%  --> fig : Return handle to figure

if nargin < 5
   nSamples = 1000;
end

if nargin < 4
   iCh = 1;
end

if nargin < 3
   iBlock = 10; % Default (TDCS-28)
end

tStart = E.tStart(iBlock) * 60;  % Convert to seconds
b = F(iBlock).base;
spikeDir = fullfile(F(iBlock).block,[b '_wav-sneo_CAR_Spikes']);


rawF = dir(fullfile(F(iBlock).wav.raw,[b '*Ch*.mat']));
filtF = dir(fullfile(F(iBlock).wav.filt,[b '*Ch*.mat']));
spikeF = dir(fullfile(spikeDir,[b '*Ch*.mat']));

[~,f,~] = fileparts(rawF(iCh).name);
nameInfo = strsplit(f,'_');
ch = nameInfo{end};
blockName = nameInfo{1};

in = struct;
in.raw = load(fullfile(rawF(iCh).folder,rawF(iCh).name),'data','fs');
in.filt = load(fullfile(filtF(iCh).folder,filtF(iCh).name),'data','fs');
in.spike = load(fullfile(spikeF(iCh).folder,spikeF(iCh).name),'pars','artifact');
in.spike.ts = [];
in.spike.pmin = [];
in.sneo = struct('data',[],'fs',in.filt.fs);
[~,in.spike.ts,in.spike.pmin,~,~,in.sneo] = eqn.SNEO_Threshold(...
   in.filt.data,in.spike.pars,in.spike.artifact);

Ntotal = numel(in.raw.data);
t = (0:(Ntotal-1))/in.raw.fs; % Time in seconds

iStart  = round(tStart * in.raw.fs);
vec = max(1,iStart-nSamples) : min(NTotal,iStart+nSamples);

t = t(vec);
raw = in.raw.data(vec);
filt = in.filt.data(vec);
sneo = in.sneo.data(vec);

spike_index = (in.spike.ts >= min(t)) & (in.spike.ts <= max(t));
ts = in.spike.ts(spike_index);
p = in.spike.pmin(spike_index);
if nargout > 6
   fig = figure(...
      'Name',sprintf('%s: Ch-%s Exemplar Data',blockName,ch),...
      'Units','Normalized',...
      'Color','w',...
      'Position',[0.2 0.2 0.4 0.6]...
      );
   subplot(2,1,1);
   line(t,raw,...
      'Color','k',...
      'LineWidth',1.5,...
      'DisplayName','Raw Activity');
   ylabel('Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   xlabel('Time (sec)','FontName','Arial','Color','k','FontSize',12);
   title('Raw Signal','FontName','Arial','Color','k','FontSize',14);
   
   subplot(2,1,2);
   line(t,filt,...
      'Color','b',...
      'LineWidth',1.5,...
      'DisplayName','Unit Activity');
   hold on;
   line(t,sneo,...
      'Color','r',...
      'LineWidth',1,...
      'LineStyle',':',...
      'DisplayName','SNEO');
   line(ts,p,'Color','k',...
      'LineStyle','none',...
      'Marker','o',...
      'MarkerFaceColor','none',...
      'MarkerEdgeColor','k',...
      'Displayname','Spikes'...
      );
   ylabel('Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   xlabel('Time (sec)','FontName','Arial','Color','k','FontSize',12);
   title('Filtered Signal and Detection',...
      'FontName','Arial','Color','k','FontSize',14);
end

end