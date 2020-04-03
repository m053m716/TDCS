function [raw,filt,sneo,spike,ch,fig] = getExemplar(E,F,iBlock,iCh,nSamples)
%GETEXEMPLAR  Return exemplar data
%
%  [raw,filt,sneo,spike] = getExemplar(E,F);
%  --> Uses defaults for other 2 arguments
%   -> raw : `raw` signal data struct for exemplar epoch ('data','t','fs')
%   -> filt : same as `raw` but with bandpass filter & re-reference applied
%   -> sneo : Struct with SNEO signal used for spike detection, from `filt`
%   -> spike: Struct with spike data
%   -> p    : Values at spike peaks (minima)
%   -> t    : times (sec) corresponding to each sample
%
%  [raw,filt,sneo,spike] = getExemplar(E,F,iBlock);
%  --> Default `iBlock` is 10 (TDCS-28)
%
%  [raw,filt,sneo,spike] = getExemplar(E,F,iBlock,iCh,nSamples);
%  --> Default `iCh` is 1 [NOTE: This indexes files, not channels]
%  --> Default `nSamples` is 1000 (-1000 : +1000)
%
%  [raw,filt,sneo,spike,ch,fig] = getExemplar(__);
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
in.spike = load(fullfile(spikeF(iCh).folder,spikeF(iCh).name),'pars');
in.spike.ts = [];
in.spike.pmin = [];
in.sneo = struct('data',[],'fs',in.filt.fs);

Ntotal = numel(in.raw.data);
t = (0:(Ntotal-1))/in.raw.fs; % Time in seconds

iStart  = round(tStart * in.raw.fs);
vec = max(1,iStart-nSamples) : min(Ntotal,iStart+nSamples);

% Reduce the total number of samples needed for spike detection
nBuffSamples = round(1.2*nSamples);
buff_vec = max(1,iStart-nBuffSamples) : min(Ntotal,iStart+nBuffSamples);
[~,in.spike.ts_index,in.spike.pmin,~,~,in.sneo.data,in.sneo.thresh] = ...
   eqn.SNEO_Threshold(in.filt.data(buff_vec),in.spike.pars,[]);
in.spike.ts_index = in.spike.ts_index + buff_vec(1) - 1;

% Fix apparent time offset from shortened vector
in.spike.ts = in.spike.ts_index ./ in.filt.fs;

t = t(vec);
raw = struct('data',in.raw.data(vec),'t',t,'fs',in.raw.fs);
filt = struct('data',in.filt.data(vec),'t',t,'fs',in.filt.fs);

% Select matched subset from SNEO stream
sneo_idx = ismember(buff_vec,vec);
sneo = struct('data',in.sneo.data(sneo_idx),...
   't',t,'fs',in.filt.fs,'threshold',in.sneo.thresh.sneo);

% Get reduced subset of spike based on spikes within the focused window
spike_index = (in.spike.ts_index >= vec(1)) & (in.spike.ts_index <= vec(end));
ts_index = in.spike.ts_index(spike_index);
ts = in.spike.ts(spike_index);
p = in.spike.pmin(spike_index);
spike = struct(...
   'peakIndices',ts_index,'peakTimes',ts,'peakValues',p,...
   'allPeakIndices',in.spike.ts_index,'allPeakTimes',in.spike.ts,...
   'allPeakValues',in.spike.pmin,...
   'threshold',in.sneo.thresh.data,'pars',in.spike.pars);

if (nargout > 5) || (nargout < 1)
   figName = sprintf('%s - Ch-%s Exemplar Data',blockName,ch);
   fig = figure(...
      'Name',figName,...
      'Units','Normalized',...
      'Color','w',...
      'Position',[0.2 0.2 0.4 0.6]...
      );
   
   % % % TOP AXES - RAW ACTIVITY % % %
   ax1 = subplot(2,1,1);
   line(ax1,raw.t,raw.data,...
      'Color','k',...
      'LineWidth',1.5,...
      'DisplayName','Raw Activity');
   ax1.YTick = [-200 0 200];
   ax1.YColor = [0 0 0];
   ax1.XColor = [0 0 0];
   ax1.FontName = 'Arial';
   ylim(ax1,[-400 200]);
   xlim(ax1,[t(1) t(end)]);
   ylabel(ax1,'Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   xlabel(ax1,'Time (sec)','FontName','Arial','Color','k','FontSize',12);
   
   title(ax1,'Raw Signal','FontName','Arial','Color','k','FontSize',14);
   legend(ax1,'Location','best');
   
   % % % BOTTOM AXES - UNIT ACTIVITY % % %
   ax2 = subplot(2,1,2);
   line(ax2,filt.t,filt.data,...
      'Color','b',...
      'LineWidth',1.25,...
      'LineStyle','-',...
      'DisplayName','Unit Activity');
   
   hold on;
   line(ax2,spike.peakTimes,-spike.peakValues,...
      'Color','k',...
      'LineStyle','none',...
      'Marker','o',...
      'MarkerFaceColor','none',...
      'MarkerEdgeColor','k',...
      'Displayname','Spikes'...
      );
   th = -ones(1,numel(filt.t)).*spike.threshold;
   line(ax2,filt.t,th,...
      'Color',[0 0 0.8],... % Darker blue
      'LineWidth',1.5,...
      'LineStyle','--',...
      'DisplayName','Unit Threshold');
   ax2.YTick = [-100 0 100];
   ax2.YColor = [0 0 1];
   ylim(ax2,[-400 200]);
   ylabel(ax2,'Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   
   
   yyaxis(ax2,'right')
   line(ax2,sneo.t,sneo.data,...
      'Color','r',...
      'LineWidth',1.25,...
      'LineStyle',':',...
      'DisplayName','SNEO');
   hold on;
   th = ones(1,numel(sneo.t)).*sneo.threshold;
   line(ax2,sneo.t,th,...
      'Color',[0.8 0 0],...
      'LineWidth',1.5,...
      'LineStyle','--',...
      'DisplayName','SNEO Threshold');
   sneo_max = max(sneo.data);
   ylim(ax2,[-sneo_max, sneo_max]);
   ax2.YScale = 'log';
   ax2.YColor = [1 0 0 ];
   ylabel(ax2,'SNEO (a.u.)','FontName','Arial','Color','k','FontSize',12);
   
   xlabel(ax2,'Time (sec)','FontName','Arial','Color','k','FontSize',12);
   title(ax2,'Filtered Signal and Detection',...
      'FontName','Arial','Color','k','FontSize',14);
   legend(ax2,'Location','northoutside','Orientation','Horizontal');
   ax2.XColor = [0 0 0];
   ax2.FontName = 'Arial';
   yyaxis(ax2,'left');
   ylim(ax2,[-125 125]);
   xlim(ax2,[t(1) t(end)]);
   suptitle(figName);
   
   if (nargout < 1)
      outdir = fullfile(defs.FileNames('OUTPUT_FIG_DIR'),'Fig 3 - Exemplars');
      batchHandleFigure(fig,defs.FileNames('OUTPUT_FIG_DIR'),figName);
   end
end

end