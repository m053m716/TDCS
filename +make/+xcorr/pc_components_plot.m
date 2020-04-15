function [fig,coeff] = pc_components_plot(C,E,blockID)
%PC_COMPONENTS_PLOT  Plot principal-component time-series
%
%  fig = make.xcorr.pc_components_plot(C);
%  
%  fig = make.xcorr.pc_components_plot(C,E);
%  --> Iterates on all unique C.BlockID
%
%  fig = make.xcorr.pc_components_plot(C,E,blockID);
%  --> Specify blockID to match from C.BlockID
%
%
%  -- Inputs --
%   -> C : Output from `compute_xcorr_FR`
%   -> E : Third output from `loadOrganizationData()` (epoch start/stops)
%
%  -- Output --
%   -> fig: Figure handle (if not specified, treats as batch, saves fig)

% Defaults
N_PC_TO_PLOT = 6;
C_ORD = [...
   0           0.4470      0.7410;
   0.8500      0.3250      0.0980;
   0.9290      0.6940      0.1250;
   0.4940      0.1840      0.5560;
   0.4660      0.6740      0.1880;
   0.3010      0.7450      0.9330 ...
   ];

if nargin < 2
   [~,~,E] = loadOrganizationData();
end

if nargin < 3
   blockID = unique(C.BlockID);
elseif isnumeric(blockID)
   blockID = categorical(blockID);
end
blockID = blockID(ismember(blockID,C.BlockID));
if isempty(blockID)
   warning('Invalid BlockID provided; using BlockID from C instead.');
   blockID = unique(C.BlockID);
end

if numel(blockID) > 1
   if nargout > 0
      fig = gobjects(size(blockID));
      coeff = cell(size(blockID));
      for i = 1:numel(blockID)
         [fig(i),coeff{i}] = make.xcorr.pc_components_plot(C,E,blockID(i));
      end
   else
      for i = 1:numel(blockID)
         make.xcorr.pc_components_plot(C,E,blockID(i));
      end
   end
   return;
end


% Compute principal components
C = C(ismember(C.BlockID,blockID),:);
E = E(ismember(E.BlockID,blockID),:);
name = catID2Name(blockID);
fname = sprintf('Example: %s Cross-Correlation PCA - time-series',name);
R = cell2mat(C.r);
coeff = pca(R);

% Get time vector
bw = defs.Experiment('DS_BIN_DURATION');
t = (0:bw:((size(coeff,1)-1)*bw))./60; % Minutes

% Make graphics
fig = figure(...
   'Name',fname,...
   'Color','w',...
   'Position',[992   149   853   478]); 
ax = axes(fig,...
   'NextPlot','add',...
   'XColor','k',...
   'YColor','k',...
   'YLim',[-1 1],...
   'XLim',[min(t) max(t)],...
   'LineWidth',1,...
   'FontName','Arial');
for i = 1:N_PC_TO_PLOT
   line(ax,t,coeff(:,i),'LineWidth',1.25,'Color',C_ORD(i,:),...
      'DisplayName',sprintf('PC-%02g',i));
end

% Label axes
xlabel(ax,'Time (minutes)','FontName','Arial','Color','k');
ylabel(ax,'Principal Component score (a.u.)','FontName','Arial','Color','k');
title(ax,fname,'FontName','Arial','Color','k');
addEpochMarkers(ax,E.tStart(1),E.tStop(1),5,25,45,0.5,[-1 1]);

% Save if desired
if nargout < 1
   outDir = defs.FileNames('OUTPUT_FIG_DIR');
   outDir = fullfile(outDir,'Cross-Correlations','PCA',name);
   if exist(outDir,'dir')==0
      mkdir(outDir);
   end
   batchHandleFigure(fig,outDir,[name '_Example-PC-Time-Series']);
else
   return;
end

end
