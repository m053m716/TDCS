function T = export_LFP_bandpower__stats_detailed(F,varargin)
%EXPORT_LFP_BANDPOWER__STATS_DETAILED Export LFP RMS for repeated-measures
%
%  T = EXPORT_LFP_BANDPOWER__STATS_DETAILED(F);
%  --> Uses `defs.LFP()` to obtain `pars`
%
%  T = EXPORT_LFP_BANDPOWER__STATS_DETAILED(F,pars); 
%  --> Assign `pars` directly
%
%  T = EXPORT_LFP_BANDPOWER__STATS_DETAILED(F,'NAME',value,...);
%  --> Uses `defs.LFP()` to obtain `pars`
%     --> Updates fields of `pars` using 'NAME',value,... syntax
%
%  -- outputs --
%  T : Table of stats data that is exported to SQL database

% Iterate on all elements of "organization" struct array
if numel(F) > 1
   % Exclude any "bad" elements of F
   F = F([F.included] & ~isnan([F.animalID]) & ~isnan([F.conditionID]));
   
   if nargout > 0
      T = [];
   end
   for i = 1:numel(F)
      if nargout > 0
         T = [T; export_LFP_bandpower__stats_detailed(F(i),varargin{:})];  %#ok<AGROW>
      else
         export_LFP_bandpower__stats_detailed(F(i),varargin{:});
      end
   end
   return;
end

% If this is an excluded element, then skip it
if ~F.included
   fprintf(1,'\t\t->\t%s skipped\n',F.base);
   T = [];
   return;
end

% Parse input parameters for LFP
pars = parseParameters('LFP',varargin{:});

% Variables from organization struct
ds_dir = F.wav.ds;
block = F.block;
name = F.base;

% Load LFP data (if present)
f = dir(fullfile(ds_dir,[name pars.LFP_DATA_TAG '*.mat']));
if isempty(f)
   fprintf(1,'\t->\t<strong>Missing %s file</strong>\n',pars.LFP_DATA_TAG);
   fprintf(1,'\t\t->\t%s skipped\n\n',F.base);
   return;
else
   fprintf(1,'\t->\t<strong>LFP power</strong> (%s)...loading...',name);
   lfp = load(fullfile(f(1).folder,f(1).name),'data','fs');
   fs = lfp.fs;
   fprintf(1,'\b\b\b\b\b\b\b\b\b\bcomputing...');
end


% Do not apply the mask yet; first compute PSD then apply mask. Note: we
% must subtract by 1 from window length (compared to the power spectrum
% estimate) in order to get the correct number of window points)
[~,f,t,ps] = spectrogram(lfp.data,pars.WLEN-1,0,pars.FREQS,fs,'power');
% Next, load mask and make sure we remove parts that are unwanted
rmsdata = load(fullfile(block,sprintf(pars.RMS_MASK_FILE,name)),'mask');

ps_ = ps(:,~rmsdata.mask); % Remove mask samples here (do not save version with removed samples)
t_ = t(1,~rmsdata.mask)./60; % Convert to minutes for comparison purposes

nEpoch = numel(pars.EPOCH_NAMES);
nBand = numel(pars.BANDS);
N = numel(t_);


% If we want to sanity check, then give option to export LFP spectrum
if ~isempty(pars.LFP_SPECTRA_FIG_FILE)
   [pname,fname,~] = fileparts(pars.LFP_SPECTRA_FIG_FILE);
   if contains(fname,'%s')
      fname = sprintf(fname,name);
   end
   
   if isempty(pname)
      pname = pars.OUTPUT_FIG_DIR;
   end
   
   if exist(pname,'dir')==0
      mkdir(pname);
   end
   
   PS_plot = nan(numel(f),nEpoch);
   err_plot = nan(numel(f),nEpoch);
   t_Epoch = nan(1,nEpoch);
   for k = 1:nEpoch
      epochName = pars.EPOCH_NAMES{k};
      t_idx = (t_>=pars.EPOCH_ONSETS(k)) & ...
              (t_<=pars.EPOCH_OFFSETS(k));
      t_Epoch(k) = mean(t_(t_idx));
      psmag = mag2db(ps_(:,t_idx));
      PS_plot(:,k) = mean(psmag,2);
      err_plot(:,k) = std(psmag,[],2);
   end
   
   outfigname = fullfile(pname,fname);
   fig = figure('Name',sprintf('%s LFP Power Spectrum',name),...
      'Units','Normalized',...
      'Color','w',...
      'Position',[0.2 0.2 0.3 0.5]);
   ax = axes(fig,...
      'FontName','Arial',...
      'XColor','k',...
      'XTick',t_Epoch,...
      'XTickLabel',pars.EPOCH_NAMES,...
      'XLim',[0 90],...
      'NextPlot','add',...
      'YDir','reverse',...
      'YScale','log',...
      'YTick',[2,4,8,12,30,50,70,100],...
      'YTickLabel',{'2','4','8','12','30','','70','100'},...
      'YLim',[0 105],...
      'YGrid','on',...
      'ZGrid','on',...
      'ZTick',[0 30 60],...
      'ZLim',[-20 65],...
      'LineWidth',1.0,...
      'YColor','k',...
      'View',[-50 49],...
      'FontSize',13);
   xlabel('Epoch','FontName','Arial','FontSize',14,'Color','k');
   ylabel('Frequency (Hz)','FontName','Arial','FontSize',14,'Color','k');
   zlabel('Power (dB)','FontName','Arial','FontSize',14,'Color','k');
   title(strrep(fname,'_','::'),'FontName','Arial','FontSize',16,'Color','k');
   [X,Y] = meshgrid(t_Epoch,f);
   l = plot3(ax,X,Y,PS_plot,'LineWidth',1.5,'Color',[0.85 0.85 0.85]);
   c = defs.EpochColors();
   
   for i = 1:numel(l)
      l(i).Tag = pars.EPOCH_NAMES{i};
      y_e = [f; flipud(f)];
      x_e = ones(1,numel(f)).*t_Epoch(i);
      x_e = [x_e, fliplr(x_e)]; %#ok<AGROW>
      z_e = [PS_plot(:,i)-err_plot(:,i); flipud(PS_plot(:,i)) + flipud(err_plot(:,i))];
      fill3(ax,x_e,y_e,z_e,c(i,:),...
         'EdgeColor','none',...
         'FaceAlpha',0.5,...
         'Tag',sprintf('%s: +/- 1 Standard Deviation',pars.EPOCH_NAMES{i}));
      
      for k = 1:numel(pars.BANDS)
         fc = pars.FC.(pars.BANDS{k});
         f_idx = (f>=fc(1)) & (f<=fc(2));
         y_s = f(f_idx);
         x_s = ones(1,numel(y_s)).*t_Epoch(i);
         z_s = PS_plot(f_idx,i);
         c_band = defs.BandColors(pars.BANDS{k});
         scatter3(ax,x_s,y_s,z_s,12,c_band,'filled','sq');
      end
   end
   ax = addBandsToAx(ax);
   expAI(fig,outfigname);
   savefig(fig,[outfigname '.fig']);
   saveas(fig,[outfigname '.png']);
   delete(fig);
end
fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\baveraging...');

% Take log-transform AFTER (optionally) plotting
ps_ = log(ps_);

% Pre-allocate variables
AnimalID = ones(N*nBand,1).*F.animalID;
ConditionID = ones(N*nBand,1).*ceil(F.conditionID/2);
CurrentID = ones(N*nBand,1).*F.currentID;

EpochID = nan(N*nBand,1);
BandID = nan(N*nBand,1);
ts = nan(N*nBand,1);
P = nan(N*nBand,1);
Z = nan(N*nBand,1);
idx_vec = (((1:nBand)-1)*N) + (1:N)';

for i = 1:nBand
   fc = pars.FC.(pars.BANDS{i});
   f_idx = (f>=fc(1)) & (f<=fc(2));
   ps_f = ps_(f_idx,:); % Note: ps_ is log-transformed, has mask applied
   p = mean(ps_f,1);    % Keep this for assignment
   muP = mean(p);
   sdP = std(p);
   j = idx_vec(:,i);
   for k = 1:nEpoch
      epochName = pars.EPOCH_NAMES{k};
      t_idx = (t_>=pars.EPOCH_ONSETS(k)) & ...
              (t_<=pars.EPOCH_OFFSETS(k));
      BandID(j(t_idx)) = i;
      EpochID(j(t_idx)) = k;
      ts(j(t_idx)) = t_(t_idx);
      P(j(t_idx)) = p(t_idx);
      Z(j(t_idx)) = (p(t_idx) - muP) ./ sdP;
   end
end
T = table(AnimalID,ConditionID,CurrentID,BandID,EpochID,ts,P,Z);
T(isnan(T.P),:) = []; % Remove

fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b<strong>complete</strong>\n');



end