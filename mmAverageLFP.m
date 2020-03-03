function [f,t,P,fig,P_plot] = mmAverageLFP(varargin)
%MMAVERAGELFP  AVERAGE LFP SPECTRA ACROSS MANY RECORDINGS/CHANNELS
%
%   [f,t,P] = MMAVERAGELFP;
%   [f,t,P] = MMAVERAGELFP(F);
%   [f,t,P,fig] = MMAVERAGELFP(__,'NAME',value,...);
%   [___,f_plot,t_plot,P_plot] = ___
%
%   --------
%    INPUTS
%   --------
%       F       :       (Optional) List of full filenames (with path also)
%                       for all LFP spectrogram files to average together.
%
%   varargin    :       (Optional) 'NAME',value input argument pairs.
%
%   --------
%    OUTPUT
%   --------
%      f        :       1 x N vector of frequency bin centers for points in
%                       P.
%
%      t        :       1 x T vector of times at which estimates were
%                       obtained.
%
%      P        :       N x T matrix of average spectral power from all
%                       files input.
%
%     fig       :       Handle to figure object
%
%     _plot versions : The values actually used in the figure
%
%   See also: MMMEMFREQ, MMDN_FILT, MMDS

% DEFAULTS
pars = defs.LFP_Average();

% PARSE VARARGIN
if nargin>0
   idx = cellfun(@(x)isa(x,'matlab.graphics.axis.Axes'),varargin);
   if sum(idx)==1
      pars.NEWFIG = false;
      ax = varargin{idx};
      varargin(idx) = [];
   end
   if numel(varargin) == 1
      if isfield(varargin{1},'P')
         pars.P = varargin{1}.P;
         if isfield(varargin{1},'f')
            pars.f = varargin{1}.f;
         end
         if isfield(varargin{1},'t')
            pars.t = varargin{1}.t;
         end
      else
         F = varargin{1};
      end
   elseif rem(numel(varargin),2)==0
      for iV = 1:2:numel(varargin)
         pars.(varargin{iV}) = varargin{iV+1};
      end
   else
      if isfield(varargin{1},'P')
         pars.P = varargin{1}.P;
         if isfield(varargin{1},'f')
            pars.f = varargin{1}.f;
         end
         if isfield(varargin{1},'t')
            pars.t = varargin{1}.t;
         end
      else
         F = varargin{1};
      end
      for iV = 2:2:numel(varargin)
         pars.(varargin{iV}) = varargin{iV+1};
      end
   end
end
% SET UP INTERPOLATION VECTOR
if ~isfield(pars,'P')
   if exist('F','var')==0
      [fname,pname] = uigetfile('*MEM*.mat','Select LFP MEM files',...
         pars.DEF_DIR,...
         'MultiSelect','on');
      if iscell(fname)
         F = cell(numel(fname),1);
         for iF = 1:numel(fname)
            F{iF} = fullfile(pname,fname{iF});
         end
      else
         F = {fullfile(pname,fname)};
      end
   end
   
   [f,t,P] = doLFPNormalization(pathnames);
else % Otherwise, we go the 'lfp' struct directly
   P = pars.P;
   if ~isfield(pars,'f')
      f = linspace(pars.KMIN,pars.KMAX,size(P,1));
   else
      f = pars.f;
   end
   if ~isfield(pars,'t')
      t = linspace(pars.TMIN*60,pars.TMAX*60,size(P,2));
   else
      t = pars.t;
   end
end


% PLOT, IF SPECIFIED
if pars.PLOT
   if pars.NEWFIG
      fig = figure(...
         'Name','Normalized MEM LFP Average Spectral Estimate',...
         'Units','Normalized', ...
         'Color','w',...
         'Position',[0.2 0.2 0.6 0.6]);
      ax = gca;
   else
      fig = gcf;
      if exist('ax','var')==0
         ax = gca;
      end
   end
   
   %     load('zmap.mat','zmap');
   %     colormap(zmap);
   colormap('jet');
   
   P_plot = transformLFP(P,...
      'GAUSS_ROWS',pars.GAUSS_ROWS,...
      'GAUS_COLS',pars.GAUSS_COLS);
   
   o = imagesc(ax,t./60,f,P_plot);
   ylim(ax,[min(o.YData) max(o.YData)]);
   addEpochLabelsToAxes(ax);
   
   ax.YScale = 'log';
   ax.YTick = pars.YTICK;
   ax.YDir = 'normal';
   ax.FontName = 'Arial';
   ax.FontSize = 12;
   ax.Color = 'k';
   ax.LineWidth = 1.25;
   xlim(ax,[pars.TMIN pars.TMAX]);
   c = colorbar(ax,'Location','northoutside');
   c.Label.String = 'Power (normalized)';
   c.Label.FontName = 'Arial';
   c.Label.FontSize = 10;
   c.Label.Color = 'k';
   %     caxis(pars.CAXIS);
   
   if pars.NEWFIG
      title(ax,'Maximum Entropy Method LFP Spectrum Average',...
         'FontName','Arial','Color','k','FontSize',16);
   end
   ylabel(ax,'Frequency (Hz)','FontName','Arial','Color','k','FontSize',14);
   xlabel(ax,'Time (min)','FontName','Arial','Color','k','FontSize',14);
end

end