function fig = panel_by_recording(T,E,blockID,varargin)
%PANEL_BY_RECORDING  Make subpanels by blockID for xcorr time-series
%
%  fig = make.xcorr.panel_by_recording(T,E);
%  fig = make.xcorr.panel_by_recording(T,E,blockID);
%
%  -- Inputs --
%   -> T : Table of binned spike rate data (`data.binned_spikes`; see
%           `main.m`  or `loadDataStruct()`)
%   -> E : Table of epoch start stop times (third output of
%           `loadOrganizationData()`)
%   -> blockID : (Optional) If not specified, uses all elements of
%                 T.BlockID; otherwise, just the blockID from this input
%                 scalar or vector
%
%  -- Output --
%   -> fig : Handle to figure object with panelized xcorr time-series.
%     --> If not requested, then the figure handle is automatically saved
%           and the figure is closed.

if nargin < 3
   blockID = unique(T.BlockID);
elseif isnumeric(blockID)
   blockID = categorical(blockID);
end
blockID = blockID(ismember(blockID,T.BlockID));
if isempty(blockID)
   warning('Invalid BlockID provided; using BlockID from T instead.');
   blockID = unique(T.BlockID);
end
pars = parseParameters('XCorr_Panels',varargin{:});

T = T(ismember(T.BlockID,blockID),:);
E = E(ismember(E.BlockID,blockID),:);

% Make graphics
fname = sprintf('Panelized cross-correlation time-series%s',...
   strrep(pars.TAG,'_',' -- '));

% Put on secondary monitor if possible
pos = gfx__.addToSecondMonitor('Normalized');

fig = figure(...
   'Name',fname,...
   'Color','w',...
   'Units','Normalized',...
   'Position',pos); 

nTotal = numel(blockID);
nRow = floor(sqrt(nTotal));
nCol = ceil(nTotal/nRow);

ax = ui__.panelizeAxes(fig,nRow,nCol);
ax = flipud(ax);
name = catID2Name(blockID); % Get all names
outDir = fullfile(pars.DIR,'Cross-Correlations','PCA');
if exist(outDir,'dir')==0
   mkdir(outDir); 
end

for i = 1:nTotal
   axes(ax(i)); %#ok<LAXES> % Set current axes
   [C,t,mask] = compute_xcorr_FR(T,blockID(i));
   x_idx = (t >= pars.XLIM(1)) & (t <= pars.XLIM(2));
   C.r = cellfun(@(c)c(1,x_idx),C.r,'UniformOutput',false);
   t = t(x_idx);
   mask = mask(x_idx);
   
   % Batch save for this BlockID
   [fig,idx,~,COL] = make.xcorr.pc_loadings_plot(C,blockID(i));
   batchHandleFigure(fig,fullfile(outDir,name{i}),...
      [name{i} '_Example-PC-Loadings']);
   make.xcorr.pc_explained_stem(C);
   make.xcorr.pc_components_plot(C,E);
   
   % Plot this panel's cross correlation series
   R = cell2mat(C.r);
   
   v = unique(idx);
   v = reshape(v,1,numel(v));
   ax(i).NextPlot = 'add';
   for ii = v
      gfx__.plotWithShadedError(ax(i),...
         t,R(idx == ii,:),...
         'Color',COL{ii},...
         'LineWidth',pars.LINEWIDTH,...
         'DisplayName',sprintf('Clu-%02g',ii));
   end
   ax(i).XLim = pars.XLIM;
   ax(i).YLim = pars.YLIM;
   ax(i).YTick = pars.YTICK;
   ax(i).FontName = pars.FONTNAME;
   ax(i).XColor = pars.XCOLOR;
   ax(i).YColor = pars.YCOLOR;
   
   if rem(i,nRow)==0
      xlabel(ax(i),'Time (min)','FontName','Arial','Color','k');
   end
   if i <= nRow
      ylabel(ax(i),'Cross-Covariance','FontName','Arial','Color','k');
   end
   tID = find(ismember(T.BlockID,blockID(i)),1,'first');
   plotName = sprintf('%s-%s (%s)',...
      char(T.ConditionID(tID)),...
      char(T.CurrentID(tID)),...
      name{i});
   title(ax(i),plotName,...
      'FontName','Arial','Color','k','FontWeight','bold');
   eID = ismember(E.BlockID,blockID(i));
   m = mask.*pars.MASK_Y;
   m(m == 0) = nan;
   line(ax(i),t,m,...
      'Color',pars.MASK_COLOR,...
      'LineWidth',3,...
      'LineStyle','-',...
      'DisplayName','RMS-Mask');
   addEpochMarkers(ax(i),E.tStart(eID),E.tStop(eID),...
      pars.PRE_X,pars.STIM_X,pars.POST_X,...
      pars.LABEL_Y,pars.YLIM);
end

% Save if desired
if nargout < 1
   if ~isvalid(fig)
      fig = gcf;
   end
   batchHandleFigure(fig,outDir,['Panelized-XCorr-Time-Series' pars.TAG]);
else
   return;
end

end