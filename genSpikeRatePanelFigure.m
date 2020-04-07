function [fig,y,h0,y_test,h0_test,t] = genSpikeRatePanelFigure(T,varargin)
%GENSPIKERATEPANELFIGURE Generate panelized spike rate change figure
%
%  fig = genSpikeRatePanelFigure(T);
%  fig = genSpikeRatePanelFigure(T,pars);
%  fig = genSpikeRatePanelFigure(__,'NAME',value,...);
%
%  -- inputs --
%  T     :     Table where rows are Blocks with full spike series data
%
%  varargin:   Uses pars struct from `defs.FileNames`, which can be
%              modified with <'NAME',value> pairs.
%
%  -- output --
%  fig   :     Figure handle. If not requested, then does batch saving.
%              * Figure has 3x2 subpanels;
%                 + Columns: Anodal | Cathodal
%                 + Rows: Pre | Stim | Post
%
%  y     :     Cell array of data used for significance testeing
%
%  h0    :     Cell array of null-hypotheses for significance testing
%
%  y_test  :   Transformed `y` values for normalized testing
%
%  h0_test :   Transformed `h0` values for normalized testing
%
%  t : Times corresponding to columns of y or h0 (or tests)

% Parse input
pars = parseParameters('Panelized_Rate_Figure',varargin{:});
pars = extrapolateParams(pars);

% Generate figure object
fname = [pars.FNAME pars.TAG];
fig = figure(...
   'Name',fname,...
   'Units','Normalized',...
   'Position',pars.FIG_POS,...
   'Color','w');

% Initialize data
nEpoch = numel(pars.EPOCH_NAMES);
vec = getEpochSampleIndices(T,1:nEpoch);
vv = vec(1,:);
iStart = min(cellfun(@min,vec(:,1)));
iStop = max(cellfun(@max,vec(:,3)));
vec = iStart:iStop;

t  = (pars.BIN_WIDTH/2):pars.BIN_WIDTH:(pars.MAX_T_VAL_MINS * 60); % Frequencies on x-axis
t = t(vec) ./ 60; % Convert back into minutes
y  = cell(pars.N_INTENSITY,pars.N_POLARITY); % Cell array for test data
h0 = cell(pars.N_INTENSITY,pars.N_POLARITY); % Cell array for "null-hypothesis" (sham) data
% data = cellfun(@(C1)sqrt(C1(vec)),T.Rate,'UniformOutput',false);
mask = cellfun(@(C1)C1(vec),T.mask,'UniformOutput',false);

% data = cellfun(@(C1,C2)maskWithNaN(C1,C2),data,mask,'UniformOutput',false);
% data = cell2mat(data);

y_test = cell(size(y));
h0_test = cell(size(h0));

Z = cellfun(@(C1)C1(vec),T.delta_sqrt_Rate,'UniformOutput',false); 
Z = cellfun(@(C1,C2)maskWithNaN(C1,C2),Z,mask,'UniformOutput',false);
Z = cell2mat(Z);

% Plot each sub-panel according to array
ax = ui__.panelizeAxes(fig,pars.N_INTENSITY,pars.N_POLARITY);
ax = flipud(ax); % Put the "top" axes at the "top" of the array
sigName = sprintf(pars.SIG_STR,char(pars.SIG_TEST),pars.ALPHA);

for iRow = 1:pars.N_INTENSITY
   for iCol = 1:pars.N_POLARITY
      % Make sure axes "Hold" is on
      ax(iRow,iCol).NextPlot = 'add';
      
      % Get indexing of effect and control groups
      iEffect = (T.CurrentID==pars.POL_ID(iCol)) & (T.ConditionID==iRow);
      if pars.AGGREGATE_SHAM
         iControl = (T.ConditionID == 1); 
      else
         iControl = (T.ConditionID == 1) & (T.CurrentID==pars.POL_ID(iCol));
      end

      % Aggregate data for significance bar and to return it if needed
      y{iRow,iCol} = Z(iEffect,:);
      if isempty(pars.H0)
         h0{iRow,iCol} = Z(iControl,:);
         h0{iRow,iCol}(all(isnan(h0{iRow,iCol}),2),:) = [];
         h0{iRow,iCol} = fillmissing(h0{iRow,iCol},'nearest',2,'EndValues',0);
      else % Otherwise use data as provided
         h0{iRow,iCol} = pars.H0;
      end
      % Remove rows that are "all" NaN
      y{iRow,iCol}(all(isnan(y{iRow,iCol}),2),:) = [];
      y{iRow,iCol} = fillmissing(y{iRow,iCol},'nearest',2,'EndValues',0);
      
      % Compute standard error of mean confidence bands
      if strcmpi(pars.ERROR_TYPE,'SEM')
         sd_coeff = pars.ERROR_COEFF/sqrt(size(y{iRow,iCol},1)); % SEM
      else
         sd_coeff = pars.ERROR_COEFF; % Normal SD
      end

      % Logit transform for percentage
      ytrans = logit_pct(y{iRow,iCol});
      h0trans = logit_pct(h0{iRow,iCol});
%       ytrans = arcsine_pct(y{iRow,iCol});
%       h0trans = arcsine_pct(h0{iRow,iCol});
      
      y_test{iRow,iCol} = math__.whitenSeries(ytrans,...
         pars.WHITEN_W,pars.WHITEN_OVERLAP).*...
         nanstd(ytrans,0,2) + nanmean(ytrans,2);
      h0_test{iRow,iCol} = math__.whitenSeries(h0trans,...
         pars.WHITEN_W,pars.WHITEN_OVERLAP).*...
         nanstd(h0trans,0,2) + nanmean(h0trans,2);
      [cb,mu] = math__.mat2cb(y{iRow,iCol},1,sd_coeff);
      
      % 1) Plot indicator of dispersion of deltas. 
      % 2) Note any frequencies with significant differences between
      %     the SHAM and 0.4 mA datasets.
      tag = pars.CONDITION_NAMES{iRow,iCol};
      dispName = ['\Delta(log(P))) \pm ' ...
         num2str(pars.ERROR_COEFF) ' ' pars.ERROR_TYPE];
      for iEpoch = 1:nEpoch
         if iEpoch == 1
            ann = pars.ANNOTATION;
         else
            ann = 'off';
         end
         epocMask = ismember(vec,vv{iEpoch});
         gfx__.plotWithShadedError(ax(iRow,iCol),...
            t(epocMask),mu(epocMask),cb(:,epocMask),...
            'FaceColor',pars.COLORS{iRow,iCol},...
            'Color',pars.COLORS{iRow,iCol},...
            'LineWidth',pars.MAIN_LINEWIDTH,...
            'Annotation',ann,...
            'Tag',tag,...
            'DisplayName',dispName);
      end
      title(ax(iRow,iCol),tag);
      xlim(ax(iRow,iCol),pars.XLIM);
      ylim(ax(iRow,iCol),pars.YLIM);
      if iRow == pars.N_INTENSITY
         xlabel(ax(iRow,iCol),pars.XLABEL);
      end
      if iCol == 1
         ylabel(ax(iRow,iCol),pars.YLABEL);
      end
      if all([iRow,iCol] == pars.LEGEND_AXES_ADDRESS)
         legend(ax(iRow,iCol),...
            'Location',pars.LEGEND_LOCATION,...
            'Box',pars.LEGEND_BOX,...
            'FontName',pars.LEGEND_FONTNAME,...
            'FontSize',pars.LEGEND_FONTSIZE,...
            'TextColor',pars.LEGEND_FONTCOLOR,...
            'Orientation',pars.LEGEND_ORIENTATION,...
            'Color',pars.LEGEND_BGCOLOR,...
            'Position',pars.LEGEND_POSITION,...
            'Parent',fig);
      end
      c = repmat(pars.COLORS{iRow,iCol},numel(pars.EPOCH_NAMES),1);
      addEpochLabelsToAxes(ax(iRow,iCol),...
         'LABEL_HEIGHT',pars.LABEL_HEIGHT,...
         'LABEL_FIXED_Y',pars.LABEL_FIXED_Y,...
         'ADD_EPOCH_DELIMITER_LINES',pars.ADD_EPOCH_DELIMITER_LINES,...
         'EPOCH_COL',c);
      % Now that axes limits are set, add significance line
      if pars.SIG_SHOW_PROBABILITY
         for iEpoch = 1:nEpoch
            epocMask = ismember(vec,vv{iEpoch});
            tt = t(epocMask);
            yy = ytrans(:,epocMask);
            if ~isscalar(h0trans)
               hh0 = h0trans(:,epocMask);
            else
               hh0 = h0trans;
            end
            if iEpoch == 1
               ann = 'on';
            else
               ann = 'off';
            end
            
            [~,~,~,~] = gfx__.addSignificanceLine(ax(iRow,iCol),...
               tt,yy,hh0,...
               pars.ALPHA,...
               'AddDataPlot',false,...
               'Color',pars.SIG_COLOR,...
               'LineWidth',pars.SIG_LINEWIDTH,...
               'FixedBracketY',pars.SIG_Y_BRACKET,...
               'FixedTickY',pars.SIG_Y_TICK,...
               'RepeatedThresholdRatio',0,...
               'FixedRepeatedThreshold',1,... % Does not use "repeated"
               'LineJoin',pars.SIG_LINEJOIN,...
               'Annotation',ann,...
               'TestFcn',pars.SIG_TEST,...
               'Tag',sigName);
         end
      else
         for iEpoch = 1:nEpoch
            if iEpoch == 1
               ann = 'on';
            else
               ann = 'off';
            end
            epocMask = ismember(vec,vv{iEpoch});
            tt = t(epocMask);
            yy = ytrans(:,epocMask);
            if ~isscalar(h0trans)
               hh0 = h0trans(:,epocMask);
            else
               hh0 = h0trans;
            end
            gfx__.addSignificanceLine(ax(iRow,iCol),...
               tt,yy,hh0,...
               pars.ALPHA,...
               'AddDataPlot',false,...
               'Color',pars.SIG_COLOR,...
               'LineWidth',pars.SIG_LINEWIDTH,...
               'FixedBracketY',pars.SIG_Y_BRACKET,...
               'FixedTickY',pars.SIG_Y_TICK,...
               'RepeatedThresholdRatio',0,...
               'FixedRepeatedThreshold',1,... % Does not use "repeated"
               'LineJoin',pars.SIG_LINEJOIN,...
               'TestFcn',pars.SIG_TEST,...
               'Annotation',ann,...
               'Tag',sigName);
         end
      end
      set(ax(iRow,iCol),...
         'XTick',pars.XTICK,...
         'XMinorTick','on',...
         'YTick',pars.YTICK,...
         'YTickLabels',pars.YTICKLABELS,...
         'XLim',pars.XLIM,...
         'YLim',pars.YLIM,...
         'FontSize',pars.AX_FONT_SIZE);
      set(ax(iRow,iCol).XAxis,...
         'MinorTickValues',pars.XMINORTICK,...
         'TickDirection','out');
   end
end
fig.UserData.pars = pars;

% Output depends on number of output arguments requested
if nargout > 0
   % Simply returns the figure with modified UserData
   fig = batchHandleFigure(fig,pars.DIR,fname);
else
   % Deletes the figure after saving
   batchHandleFigure(fig,pars.DIR,fname);
   clear fig;
end

% Helper methods
   function pars = extrapolateParams(pars)
      %EXTRAPOLATEPARAMS  Helper function for "dependent" parameters
      %
      %  pars = extrapolateParams(pars);
      %  --> Updates parameters that might depend on parsing of other
      %        parameters

      [pars.N_INTENSITY,pars.N_POLARITY] = size(pars.COLORS);
      if isequal(pars.SIG_TEST,@signranktest) && isempty(pars.H0)
         % Just in case H0 wasn't switched by accident
         pars.H0 = 0;
      end
      if ~pars.SIG_SHOW_PROBABILITY % Then change axes limits
         pars.YLIM = [-66 66];
         pars.LABEL_FIXED_Y = -66;
      end
   end

   function z = logit_pct(p)
      %LOGIT_PCT  Transforms percent from range -100 to 100 into test stat
      %
      %  z = logit_pct(p);
      
      p_scl = abs((p+100)/2)./100; % New range: [0,1]
      z = log(p_scl ./ (1 - p_scl));
      % Remove `inf` values and interp to replace them
      z(isinf(z)) = nan;
      z = fillmissing(z,'nearest',2,'EndValues',0);
   end

   function z = arcsine_pct(p)
      %ARCSINE_PCT  Transforms percent from range -100 to 100 test stat
      %
      %  z = arcsine_pct(p)
      
      p_scl = p./100; % New range: [-1,1]
      z = asin(p_scl);
   end

   function data = maskWithNaN(data,mask)
      %MASKWITHNAN  Change "bad" samples to NaN for keeping dimensions
      %
      %  data = maskWithNaN(data,mask);
      data(1,mask) = nan;
   end

end