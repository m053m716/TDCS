function fig = genSpikeRatePanelFigure(T,varargin)
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
vec = getEpochSampleIndices(T,[1,3]);
iStart = min(cellfun(@min,vec(:,1)));
iStop = max(cellfun(@max,vec(:,2)));
vec = iStart:iStop;

t  = (pars.BIN_WIDTH/2):pars.BIN_WIDTH:(pars.MAX_T_VAL_MINS * 60); % Frequencies on x-axis
t = t(vec) ./ 60; % Convert back into minutes
y  = cell(pars.N_INTENSITY,pars.N_POLARITY); % Cell array for test data
h0 = cell(pars.N_INTENSITY,pars.N_POLARITY); % Cell array for "null-hypothesis" (sham) data
data = cellfun(@(C1)sqrt(C1(vec)),T.Rate,'UniformOutput',false);
mask = cellfun(@(C1)C1(vec),T.mask,'UniformOutput',false);

data = cellfun(@(C1,C2)maskWithNaN(C1,C2),data,mask,'UniformOutput',false);
data = cell2mat(data);

Z = cellfun(@(C1)C1(vec),T.delta_sqrt_Rate,'UniformOutput',false); 
Z = cellfun(@(C1,C2)maskWithNaN(C1,C2),Z,mask,'UniformOutput',false);
Z = cell2mat(Z);

% Plot each sub-panel according to array
ax = ui__.panelizeAxes(fig,pars.N_INTENSITY,pars.N_POLARITY);
ax = flipud(ax); % Put the "top" axes at the "top" of the array

sigName = sprintf(pars.SIG_STR,pars.ALPHA);
if isequal(pars.SIG_TEST,@signranktest)
   pars.H0 = 0;
end

for iRow = 1:pars.N_INTENSITY
   for iCol = 1:pars.N_POLARITY
      % Get indexing of effect and control groups
      iEffect = (T.CurrentID==pars.POL_ID(iCol)) & (T.ConditionID==iRow);
      iControl = T.ConditionID == 1; 

      % Aggregate data for significance bar and to return it if needed
      y{iRow,iCol} = Z(iEffect,:);
      if isempty(pars.H0)
         h0{iRow,iCol} = Z(iControl,:);
      elseif isscalar(pars.H0)
         h0{iRow,iCol} = ones(size(y{iRow,iCol})) .* pars.H0;
         h0{iRow,iCol}(isnan(y{iRow,iCol})) = nan;
      else
         h0{iRow,iCol} = pars.H0;
      end
      
      % "Compress" visual by using difference from SHAM for MAX intensity
%       z = y{iRow,iCol} - nanmean(nanmedian(h0{iRow,iCol},2),1);
%       z = Z(iEffect,:);
      
      % Compute standard error of mean confidence bands
      if strcmpi(pars.ERROR_TYPE,'SEM')
         sd_coeff = pars.ERROR_COEFF/sqrt(size(z,1)); % SEM
      else
         sd_coeff = pars.ERROR_COEFF; % Normal SD
      end

      [cb,mu] = math__.mat2cb(y{iRow,iCol},1,sd_coeff);
      
      % 1) Plot indicator of dispersion of deltas. 
      % 2) Note any frequencies with significant differences between
      %     the SHAM and 0.4 mA datasets.
      tag = pars.CONDITION_NAMES{iRow,iCol};
      dispName = ['\Delta(log(P))) \pm ' ...
         num2str(pars.ERROR_COEFF) ' ' pars.ERROR_TYPE];
      gfx__.plotWithShadedError(ax(iRow,iCol),...
         t,mu,cb,...
         'FaceColor',pars.COLORS{iRow,iCol},...
         'Color',pars.COLORS{iRow,iCol},...
         'LineWidth',pars.MAIN_LINEWIDTH,...
         'Annotation',pars.ANNOTATION,...
         'Tag',tag,...
         'DisplayName',dispName);
      gfx__.addSignificanceLine(ax(iRow,iCol),...
         t,y{iRow,iCol},h0{iRow,iCol},...
         pars.ALPHA,...
         'AddDataPlot',false,...
         'Color',pars.SIG_COLOR,...
         'LineWidth',pars.SIG_LINEWIDTH,...
         'FixedBracketY',pars.SIG_Y_BRACKET,...
         'FixedTickY',pars.SIG_Y_TICK,...
         'FixedRepeatedThreshold',pars.SIG_REPEATED,...
         'LineJoin',pars.SIG_LINEJOIN,...
         'TestFcn',pars.SIG_TEST,...
         'Tag',sigName);
%       s = label__.rgb2TeX(pars.COLORS{iRow,iCol});
%       ttext = [s tag];
      ttext = tag;
      title(ax(iRow,iCol),ttext);
      xlim(ax(iRow,iCol),pars.XLIM);
      ylim(ax(iRow,iCol),pars.YLIM);
      if iRow == pars.N_INTENSITY
%          xl = [s pars.XLABEL];
         xl = pars.XLABEL;
         xlabel(ax(iRow,iCol),xl);
      end
      if iCol == 1
%          yl = [s pars.YLABEL];
         yl = pars.YLABEL;
         ylabel(ax(iRow,iCol),yl);
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
      c = c .* pars.EPOCH_COL_FACTOR;
      addEpochLabelsToAxes(ax(iRow,iCol),...
         'LABEL_HEIGHT',pars.LABEL_HEIGHT,...
         'LABEL_FIXED_Y',pars.LABEL_FIXED_Y,...
         'EPOCH_COL',c);
   end
end

% Ensure that array sub-panels have same X, Y limits
% label__.setEvenLimits(ax,...
%    'XLIM',pars.XLIM,...
%    'YLIM',pars.YLIM ...
%    );

fig.UserData.pars = pars;

% Output depends on number of output arguments requested
if nargout > 0
   % Simply returns the figure with modified UserData
   fig = batchHandleFigure(fig,pars.DIR,fname);
else
   % Deletes the figure after saving
   batchHandleFigure(fig,pars.DIR,fname);
end

% Helper methods
   function pars = extrapolateParams(pars)
      %EXTRAPOLATEPARAMS  Helper function for "dependent" parameters
      % % Parsed from other parameters % %
      [pars.N_INTENSITY,pars.N_POLARITY] = size(pars.COLORS);
   end

   function data = maskWithNaN(data,mask)
      %MASKWITHNAN  Change "bad" samples to NaN for keeping dimensions
      %
      %  data = maskWithNaN(data,mask);
      data(mask) = nan(1,sum(mask));
   end

end