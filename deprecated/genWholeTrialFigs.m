function genWholeTrialFigs(S,outcomeVar,transformation,varargin)
%GENWHOLETRIALFIGS    Generate whole trial figures for FR in tDCS analysis.
%
%  genWholeTrialFigs(S)
%  --> Uses default outcome as 'Rate' with transformation function handle
%        @(x)log(x)
%
%  genWholeTrialFigs(S,outcomeVar,transformation);
%  --> Allows specification of the `outcomeVar` Variable (char) from table
%        variables in S, as well as a function handle (`transformation`)
%        which will be applied to transform data in `outcomeVar`
%
%  e.g. 
%  >> genWholeTrialFigs(S,'Regularity',[]);
%  --> Specify transformation as empty to avoid doing a transformation
%
%  genWholeTrialFigs(___,'NAME',value,...);
%  --> Specify parameters using 'NAME', value syntax 
%        (see defs.WholeTrialFigs.m for parameters)

if nargin < 2
   outcomeVar = 'Rate';
end

if nargin < 3
   transformation = @(x)log(x);
end

outDir = fullfile(defs.FileNames('OUTPUT_FIG_DIR'),'RAINCLOUDPLOTS_Spikes');
if exist(outDir,'dir')==0
   mkdir(outDir);
end

% Parse input parameters
pars = parseParameters('WholeTrialFigs',varargin{:});

if isempty(pars.DATA)
   if isempty(transformation)
      data = S.(outcomeVar);
   else
      data = transformation(S.(outcomeVar));
   end
else
   data = pars.DATA;
end

if isempty(pars.ANIMAL)
   Animal = S.Animal;
else
   Animal = pars.ANIMAL;
end

if isempty(pars.CONDITION)
   Condition = S.Condition;
else
   Condition = pars.CONDITION;
end

if isempty(pars.EPOCH)
   Epoch = S.Epoch;
else
   Epoch = pars.EPOCH;
end

% Format data for `batch_raincloud`
uAnimal = unique(Animal);
uCondition = unique(Condition);
uEpoch = unique(Epoch);
nA = numel(uAnimal);
nC = numel(uCondition);
nE = numel(uEpoch);

colAnimal = pars.ANIMAL_COLORS;
colCondition = pars.CONDITION_COLORS;

% MAKE WHOLE-TRIAL RATE FIGURE BY ANIMAL
fig = figure('Name',pars.BY_ANIMAL_FIG_NAME,...
       'Units','Normalized',...
       'Position',[0.3 0.3 0.4 0.4],...
       'Color','w');
ax = uiPanelizeAxes(fig,nA);
for i = 1:nA
   batch_raincloud(ax(i),...
      {data(Animal == uAnimal(i))},...
      'plot_top_to_bottom',1,'raindrop_size',15,...
      'colours',colAnimal(uAnimal(i),:));
   if i == 2
      xlabel(ax(i),pars.XLAB,'FontName','Arial',...
      'Color','k','FontSize',14);
      ylabel(ax(i),pars.YLAB,'FontName','Arial',...
         'Color','k','FontSize',14);
   end
   title(ax(i),sprintf('R-TDCS-%g',uAnimal(i)),'FontName','Arial',...
      'Color','k','FontSize',16,'FontWeight','bold');
   ax(i).YTick = pars.YTICK;
   ax(i).YTickLabels = pars.YTICKLAB;
   ax(i).YLim = pars.YLIM;
   ax(i).XTick = pars.XTICK;
   ax(i).XLim = pars.XLIM;
end
for i = (nA+1):numel(ax)
   delete(ax(i));
end

batchHandleFigure(fig,outDir,pars.BY_ANIMAL_FILE_NAME);

% BY TREATMENT
treatmentName = defs.Experiment('NAME_KEY');
fig = figure('Name','Whole-trial FR by Treatment',...
       'Units','Normalized',...
       'Position',[0.3 0.4 0.4 0.4],...
       'Color','w');
    
ax = uiPanelizeAxes(fig,nC);
for i = 1:nC
   batch_raincloud(ax(i),...
      {data(Condition == uCondition(i))},...
      'plot_top_to_bottom',1,'raindrop_size',15,...
      'colours',colCondition(uCondition(i),:));
   if i == 2
      xlabel(ax(i),pars.XLAB,'FontName','Arial',...
      'Color','k','FontSize',14);
      ylabel(ax(i),pars.YLAB,'FontName','Arial',...
         'Color','k','FontSize',14);
   end
   title(ax(i),treatmentName{uCondition(i)},'FontName','Arial',...
      'Color','k','FontSize',16,'FontWeight','bold');
   ax(i).YTick = pars.YTICK;
   ax(i).YTickLabels = pars.YTICKLAB;
   ax(i).YLim = pars.YLIM;
   ax(i).XTick = pars.XTICK;
   ax(i).XLim = pars.XLIM; 
end

batchHandleFigure(fig,outDir,pars.BY_TREATMENT_FILE_NAME);

% BY BOTH
fig = figure('Name',pars.BY_TREATMENT_BY_EPOCH_FIG_NAME,...
       'Units','Normalized',...
       'Position',[0.05 0.08 0.75 0.70],...
       'Color','w');
ax = uiPanelizeAxes(fig,nC);
uEpoch = sort(uEpoch,'ascend');
epochNames = pars.EPOCH_NAMES;
connMat = diag(ones(nE-1,1),1);
xLimTemp = [inf,-inf];
yLimTemp = [inf,-inf];
tag = cell(nE);
for i = 1:nC
   d = cell(nE);
   tag{2,2} = sprintf('N = %g',sum((Condition == uCondition(i))));   
   for iEpoch = 1:nE
      iMask = (Condition == uCondition(i)) & ...
               (Epoch == uEpoch(iEpoch));
      d{iEpoch,iEpoch} = data(iMask);
   end
   c = repmat(colCondition(uCondition(i),:),nE,1);
   c(2,:) = [0.05 0.05 0.05];
   c(3:end,:) = c(3:end,:) .* 0.75;
   batch_raincloud(ax(i),d,...
      'plot_top_to_bottom',1,'raindrop_size',15,...
      'plot_raindrop',false,...
      'colours',c,'plot_connections',connMat,...
      'text_x_offset',pars.TEXT_X_OFFSET,'text_align','right',...
      'text_tagalign','left','text_tagx_offset',pars.TEXT_TAGX_OFFSET,...
      'ks_offsets',pars.KS_OFFSETS,'text_tag',tag);
   if i == 2
      xlabel(ax(i),pars.XLAB,'FontName','Arial',...
      'Color','k','FontSize',14);
      ylabel(ax(i),pars.YLAB,'FontName','Arial',...
         'Color','k','FontSize',14);
   end
   title(ax(i),treatmentName{uCondition(i)},'FontName','Arial',...
      'Color','k','FontSize',16,'FontWeight','bold');
   ax(i).XTick = pars.XTICK_CROSSED;
   ax(i).YTickLabel = epochNames;
%    yyLimTemp = ax(i).YLim;
%    xxLimTemp = ax(i).XLim;
%    yLimTemp = [min(yLimTemp(1),yyLimTemp(1)), max(yLimTemp(2),yyLimTemp(2))];
%    xLimTemp = [min(xLimTemp(1),xxLimTemp(1)), max(xLimTemp(2),xxLimTemp(2))];
%    ax(i).YLim = yLimTemp;
   ax(i).YLim = pars.YLIM_CROSSED;
   ax(i).XLim = pars.XLIM_CROSSED;
end

% yLimTemp(1) = min(yLimTemp(1),-0.5);
% 
% for i = 1:nC
%    ax(i).XLim = xLimTemp;
%    ax(i).YLim = yLimTemp;
% end

batchHandleFigure(fig,outDir,pars.BY_TREATMENT_BY_EPOCH_FILE_NAME);

end