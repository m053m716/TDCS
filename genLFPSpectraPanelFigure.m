function [fig,f,y,h0] = genLFPSpectraPanelFigure(S,varargin)
%GENLFPSPECTRAPANELFIGURE  Generate panelized LFP spectra for comparison
%
%  fig = genLFPSpectraPanelFigure(S);
%  fig = genLFPSpectraPanelFigure(S,pars);
%  fig = genLFPSpectraPanelFigure(__,'NAME',value,...);
%  [fig,f,y,h0] = ...
%
%  -- inputs --
%  S     :     Table where rows are Block/Epoch combinations
%
%  varargin:   Uses pars struct from `defs.FileNames`, which can be
%              modified with <'NAME',value> pairs.
%
%  -- output --
%  fig   :     Figure handle. If not requested, then does batch saving.
%              * Figure has 3x2 subpanels;
%                 + Columns: Anodal | Cathodal
%                 + Rows: Pre | Stim | Post
%  f     :     Location of frequency bins (optional)
%
%  y     :     Data array of actual values observed
%
%  h0    :     Data array for corresponding sham comparisons

% Parse input
pars = parseParameters('LFP_Spectra_Figure',varargin{:});
pars = extrapolateParams(pars);
outcomeVar = S.Properties.UserData.DependentVariable;

% Generate figure object
fname = [pars.FNAME pars.TAG];
fig = figure(...
   'Name',fname,...
   'Units','Normalized',...
   'Position',defs.Experiment('FIG_POS'),...
   'Color','w');

% Initialize data
S(any(isnan(S.(outcomeVar)),2),:) = []; % Remove any NaN spectra
f  = S.Properties.UserData.FREQS; % Frequencies on x-axis
y  = cell(pars.NEPOCH,pars.NCOND); % Cell array for test data
h0 = cell(pars.NEPOCH,pars.NCOND); % Cell array for "null-hypothesis" (sham) data
data = S.(outcomeVar);

% Plot each sub-panel according to array
ax = ui__.panelizeAxes(fig,pars.NEPOCH,pars.NCOND);
ax = flipud(ax); % Put the "top" axes at the "top" of the array

sigName = sprintf(pars.SIG_STR,pars.ALPHA);
maxIntensity = max(S.ConditionID); % Corresponds to 0.4 mA
for iRow = 1:pars.NEPOCH
   for iCol = 1:pars.NCOND
      % Get indexing of effect and control groups
      iEffect = (S.ConditionID==maxIntensity) &  ...
         (S.CurrentID==pars.POL_ID(iCol)) & (S.EpochID==iRow);
      iControl = (S.ConditionID == 1) & (S.EpochID==iRow); 
      
      % Aggregate data for significance bar and to return it if needed
      y{iRow,iCol} = data(iEffect,:);
      h0{iRow,iCol} = data(iControl,:);
      
      % "Compress" visual by using difference from SHAM for MAX intensity
      z = y{iRow,iCol} - mean(h0{iRow,iCol},1);
      
      % Compute standard error of mean confidence bands
      if strcmpi(pars.ERROR_TYPE,'SEM')
         sd_coeff = pars.ERROR_COEFF/sqrt(size(z,1)); % SEM
      else
         sd_coeff = pars.ERROR_COEFF; % Normal SD
      end

      [cb,mu] = math__.mat2cb(z,1,sd_coeff);
      
      % 1) Plot indicator of dispersion of deltas. 
      % 2) Note any frequencies with significant differences between
      %     the SHAM and 0.4 mA datasets.
      tag = sprintf('%s: %s',pars.EPOCH_NAMES{iRow},pars.NAME{iCol});
      dispName = ['\Delta(log(P))) \pm ' ...
         num2str(pars.ERROR_COEFF) ' ' pars.ERROR_TYPE];
      gfx__.plotWithShadedError(ax(iRow,iCol),f,mu,cb,...
         'FaceColor',pars.COLORS{iRow,iCol},...
         'Color',pars.COLORS{iRow,iCol},...
         'LineWidth',pars.MAIN_LINEWIDTH,...
         'Annotation',pars.ANNOTATION,...
         'Tag',tag,...
         'DisplayName',dispName);
      gfx__.addSignificanceLine(ax(iRow,iCol),f,...
         y{iRow,iCol},h0{iRow,iCol},...
         pars.ALPHA,...
         'AddDataPlot',false,...
         'Color',pars.SIG_COLOR,...
         'LineWidth',pars.SIG_LINEWIDTH,...
         'NormalizedBracketY',pars.SIG_YTOP,...
         'NormalizedTickY',pars.SIG_YBOT,...
         'RepeatedThresholdRatio',pars.SIG_REPEATED,...
         'LineJoin',pars.SIG_LINEJOIN,...
         'Tag',sigName);
      s = label__.rgb2TeX(pars.COLORS{iRow,iCol});
      ttext = [s tag];
      title(ax(iRow,iCol),ttext);
      if iRow == pars.NEPOCH
         xl = [s pars.XLABEL];
         xlabel(ax(iRow,iCol),xl);
      end
      if iCol == 1
         yl = [s pars.YLABEL];
         ylabel(ax(iRow,iCol),yl);
      end
      if all([iRow,iCol] == pars.LEGEND_AXES_ADDRESS)
         legend(ax(iRow,iCol),...
            'Location',pars.LEGEND_LOCATION,...
            'Box',pars.LEGEND_BOX,...
            'FontName',pars.LEGEND_FONTNAME,...
            'FontSize',pars.LEGEND_FONTSIZE,...
            'TextColor',pars.LEGEND_FONTCOLOR,...
            'Color',pars.LEGEND_BGCOLOR);
      end
   end
end

% Ensure that array sub-panels have same X, Y limits
label__.setEvenLimits(ax,...
   'XLIM',pars.XLIM,...
   'XSCALE',pars.XSCALE,...
   'XTICK',pars.XTICK,...
   'XTICKLAB',pars.XTICKLAB,...
   'YLIM',pars.YLIM ...
   );

fig.UserData.pars = pars;

% Output depends on number of output arguments requested
if nargout > 0
   % Simply returns the figure with modified UserData
   fig = batchHandleFigure(fig,pars.DIR,fname);
else
   % Deletes the figure after saving
   batchHandleFigure(fig,pars.DIR,fname);
end

   function pars = extrapolateParams(pars)
      %EXTRAPOLATEPARAMS  Helper function for "dependent" parameters
      % % Parsed from other parameters % %
      pars.NEPOCH = numel(pars.EPOCH_COL_FACTOR);
      pars.NCOND = numel(pars.C_IDX);
      pars.POL_ID = pars.POL_ID(pars.C_IDX);
      pars.NAME = pars.NAME(pars.C_IDX);
      pars.COLORS = repmat(pars.COLORS(pars.C_IDX,:),pars.NEPOCH,1);
      pars.EPOCH_COL_FACTOR = repmat(pars.EPOCH_COL_FACTOR,pars.NCOND,1);
      pars.EPOCH_COL_FACTOR = pars.EPOCH_COL_FACTOR(:);
      pars.COLORS = mat2cell(pars.COLORS .* pars.EPOCH_COL_FACTOR,...
         ones(1,size(pars.COLORS,1)),3);
      pars.COLORS = reshape(pars.COLORS,pars.NEPOCH,pars.NCOND);
   end

end