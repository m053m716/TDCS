function fig = genRainCloudPlots(T,varargin)
%GENRAINCLOUDPLOTS  Generate whole trial RainCloud figures for tDCS project
%
%  genRainCloudPlots(T);
%  --> T : Table that has UserData property struct set by
%              `setTableOutcomeVariable`; required fields are:
%           * .DependentVariable : (char) indicates the Variable name to
%                                         plot as the "data" output. 
%           * .TransformFcn      : If empty, no transform on data;
%                                   otherwise, should be a function handle
%                                   that accepts a vector input and returns
%                                   a vector output of the same dimension.
%
%  genRainCloudPlots(T,pars);
%  --> Provide `pars` struct directly with second argument
%
%  genRainCloudPlots(T,'NAME',value,...);
%  --> Specify parameters using <'NAME',value> pairs syntax 
%        (see defs.RainCloudPlots for parameters)
%  
%  fig = genRainCloudPlots(__);
%  --> If output figure is requested, batch save is not executed and
%      instead an array of figure handles to the generated figures is
%      returned.

if ~isstruct(T.Properties.UserData)
   error(['tDCS:' mfilename ':BadUserData'],...
      ['\n\t->\t<strong>[GENRAINCLOUDPLOTS]:</strong> '...
      'Invalid Table UserData: see `setTableOutcomeVariable`']);
elseif ~isfield(T.Properties.UserData,'DependentVariable')
   error(['tDCS:' mfilename ':BadUserData'],...
      ['\n\t->\t<strong>[GENRAINCLOUDPLOTS]:</strong> '...
      'Invalid Table UserData: see `setTableOutcomeVariable`']);
else
   outcomeVar = T.Properties.UserData.DependentVariable;
end
transformation = T.Properties.UserData.TransformFcn;

% Parse input parameters
pars = parseParameters('RainCloudPlots',varargin{:});

if exist(pars.OUTPUT_DIR,'dir')==0
   mkdir(pars.OUTPUT_DIR);
end

if isempty(pars.DATA)
   if isempty(transformation)
      data = T.(outcomeVar);
   else
      data = transformation(T.(outcomeVar));
   end
else
   data = pars.DATA;
end

if isempty(pars.ANIMAL)
   Animal = T.AnimalID;
else
   Animal = pars.ANIMAL;
end

if isempty(pars.INTENSITY)
   Intensity = T.ConditionID;
else
   Intensity = pars.INTENSITY;
end

if isempty(pars.POLARITY)
   Polarity = T.CurrentID;
else
   Polarity = pars.POLARITY;
end

if isempty(pars.EPOCH)
   Epoch = T.EpochID;
else
   Epoch = pars.EPOCH;
end

if strcmpi(pars.XLAB,'auto')
   if isempty(pars.TAG)
      pars.XLAB = outcomeVar;
   else
      pars.XLAB = sprintf('%s (%s)',outcomeVar,strrep(pars.TAG,'_',' '));
   end
end

% % Get aggregate ksdensity stats for setting limits
% switch lower(pars.METHOD)
%    case 'ks'
%       [ks, x] = ksdensity(data(~isnan(data) & ~isinf(data)),...
%          'NumPoints',pars.NBINS,'bandwidth',pars.BANDWIDTH);
%    case 'rash'
%       [x,ks] = rst_RASH(data(~isnan(data) & ~isinf(data)));
%    otherwise
%       error(['tDCS:' mfilename ':BadCase'],...
%          ['\n\t->\t<strong>[GENRAIDCLOUDPLOTS]:</strong> ' ...
%          'Not configured to support %s density estimator\n'],...
%          pars.METHOD);
% end
% if strcmpi(pars.XLIM,'auto')
%    pars.XLIM = [min(x) - 1,max(x) + 1];
% end
% if strcmpi(pars.YLIM,'auto')
%    pars.YLIM = [min(ks) - 1,max(ks) + 1];
% end

% Format data for `batch_raincloud`
uAnimal = unique(Animal);
uAnimal = sort(uAnimal,'ascend');
uIntensity = unique(Intensity);
uIntensity = sort(uIntensity,'ascend');
uPolarity = unique(Polarity);
uPolarity = sort(uPolarity,'ascend');
uEpoch = unique(Epoch);
uEpoch = sort(uEpoch,'ascend');
nA = numel(uAnimal);
nI = numel(uIntensity);
nP = numel(uPolarity);
nE = numel(uEpoch);

colAnimal = pars.ANIMAL_COLORS;
colIntensity = pars.CONDITION_COLORS;

% MAKE WHOLE-TRIAL RATE FIGURE BY ANIMAL
iFig = 1;
fig(iFig,1) = figure('Name',pars.BY_ANIMAL_FIG_NAME,...
       'Units','Normalized',...
       'Position',pars.FIG_POS_A,...
       'Color','w');
ax = ui__.panelizeAxes(fig(iFig,1),nA);
for i = 1:nA
   iThis = uAnimal(i);
   batch_raincloud(ax(i),...
      {data(Animal == iThis)},...
      'plot_top_to_bottom',1,...
      'raindrop_size',pars.RAINDROP_SIZE,...
      'colours',colAnimal(iThis,:),...
      'raindrop_alpha',pars.RAINDROP_ALPHA);
   if (i == 1) || (i == 3) || (i == 5)
      xlabel(ax(i),pars.XLAB);
   end
   if (i == 1) || (i == 2)
      ylabel(ax(i),pars.YLAB);
   end
   title(ax(i),sprintf('R-TDCS-%g',uAnimal(i)));
   ax(i) = label__.ax2D(ax(i),pars);
end
ax = label__.setEvenLimits(ax);
for i = (nA+1):numel(ax)
   delete(ax(i));
end

fname = sprintf('%s__%s-%s',...
   outcomeVar,pars.BY_ANIMAL_FILE_NAME,pars.TAG);
if nargout < 1
   batchHandleFigure(fig(iFig,1),pars.OUTPUT_DIR,fname);
else
   fig(iFig,1) = batchHandleFigure(fig(iFig,1),pars.OUTPUT_DIR,fname);
   iFig = iFig + 1;
end

% BY INTENSITY/POLARITY
treatmentName = pars.NAME_KEY;
fig(iFig,1) = figure('Name',pars.BY_TREATMENT_FIG_NAME,...
       'Units','Normalized',...
       'Position',pars.FIG_POS_B,...
       'Color','w');   
ax = ui__.panelizeAxes(fig(iFig,1),nI,nP);
for i = 1:nI
   for k = 1:nP
      iThis = uIntensity(i);
      kThis = uPolarity(k);
      batch_raincloud(ax(i,k),...
         {data((Intensity == iThis) & ...
               (Polarity == kThis))},...
         'plot_top_to_bottom',1,...
         'raindrop_size',pars.RAINDROP_SIZE,...
         'raindrop_alpha',pars.RAINDROP_ALPHA,...
         'colours',colIntensity{i,k});
      if iThis == 1
         xlabel(ax(i,k),pars.XLAB);
      end
      if k == 1
         ylabel(ax(i,k),pars.YLAB);
      end
      title(ax(i,k),treatmentName{i,k});
      ax(i,k) = label__.ax2D(ax(i,k),pars);
   end
end
ax = label__.setEvenLimits(ax); %#ok<NASGU>

fname = sprintf('%s__%s-%s',...
   outcomeVar,pars.BY_TREATMENT_FILE_NAME,pars.TAG);
if nargout < 1
   batchHandleFigure(fig(iFig,1),pars.OUTPUT_DIR,fname);
else
   fig(iFig,1) = batchHandleFigure(fig(iFig,1),pars.OUTPUT_DIR,fname);
   iFig = iFig + 1;
end
   
% BY BOTH
fig(iFig,1) = figure('Name',pars.BY_TREATMENT_BY_EPOCH_FIG_NAME,...
       'Units','Normalized',...
       'Position',pars.FIG_POS_C,...
       'Color','w');
ax = ui__.panelizeAxes(fig(iFig,1),nI,nP);
epochNames = pars.EPOCH_NAMES;
connMat = diag(ones(nE-1,1),1);
tag = cell(nE);
for i = 1:nI
   iThis = uIntensity(i);
   for k = 1:nP
      kThis = uPolarity(k);
      d = cell(nE);
      if ismember(T.Properties.VariableNames,'NSamples')
         tag{2,2} = sprintf('N = %g',sum(T.NSamples(...
                                      (Intensity == iThis) & ...
                                      (Polarity == kThis))));
      else
         tag{2,2} = sprintf('N = %g',sum((Intensity == iThis) & ...
                                      (Polarity == kThis)));  
      end
      for iEpoch = 1:nE
         eThis = uEpoch(iEpoch);
         iMask = ((Intensity == iThis) & ...
                  (Polarity == kThis) & ...
                  (Epoch == eThis));
         d{eThis,eThis} = data(iMask);
      end
      c = repmat(colIntensity{iThis,k},nE,1);
%       c(2,:) = [0.05 0.05 0.05];
%       c(3:end,:) = c(3:end,:) .* 0.75;
      batch_raincloud(ax(iThis,k),d,...
         'plot_top_to_bottom',1,...
         'raindrop_size',15,...
         'plot_raindrop',false,...
         'colours',c,...
         'plot_connections',connMat,...
         'text_x_offset',pars.TEXT_X_OFFSET,...
         'text_align','right',...
         'text_tagalign','left',...
         'text_tagx_offset',pars.TEXT_TAGX_OFFSET,...
         'ks_offsets',pars.KS_OFFSETS,...
         'text_tag',tag);
      if iThis == 1
         xlabel(ax(i,k),pars.XLAB);
      end
      if k == 1
         ylabel(ax(i,k),pars.YLAB);
      end
      title(ax(iThis,k),treatmentName{iThis,k});
      ax(iThis,k) = label__.ax2D(ax(iThis,k),...
         'YLIM',pars.YLIM_CROSSED,...
         'XLIM',pars.XLIM_CROSSED,...
         'XTICK',pars.XTICK_CROSSED,...
         'YTICK',pars.YTICK_CROSSED,...
         'YTICKLAB',fliplr(epochNames)); % First goes at top (raincloud-specific)
   end
end

fname = sprintf('%s__%s-%s',...
   outcomeVar,pars.BY_TREATMENT_BY_EPOCH_FILE_NAME,pars.TAG);
if nargout < 1
   batchHandleFigure(fig(iFig,1),pars.OUTPUT_DIR,fname);
else
   fig(iFig,1) = batchHandleFigure(fig(iFig,1),pars.OUTPUT_DIR,fname);
end
end