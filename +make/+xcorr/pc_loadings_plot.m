function [fig,idx,S,COL] = pc_loadings_plot(C,blockID)
%PC_LOADINGS_PLOT  Create pc loadings plot for correlation time-series
%
%  fig = make.xcorr.pc_loadings_plot(C);
%  --> Iterates on all unique C.BlockID
%
%  fig = make.xcorr.pc_loadings_plot(C,blockID);
%  --> Specify blockID to match from C.BlockID
%
%  [fig,idx,S,COL] = ...
%  --> Also return `idx` and `S`, the cluster indices of each pair of
%      correlation time-series and the top-3 principal components,
%      respectively. `COL` is the color ordering parameter that corresponds
%      to unique elements of `idx` for shading clusters.
%
%  -- Inputs --
%   -> C : Output from `compute_xcorr_FR`
%
%  -- Output --
%   -> fig: Figure handle (if not specified, treats as batch, saves fig)

% Defaults
VIEW = [-40 20];
COL = {'r','b','m','y','c','g'};
N_PC_MAX = 6;
N_CLUS_MAX = 3;
N_FACE_SPHERE = 20;

if nargin < 2
   blockID = unique(C.BlockID);
elseif isnumeric(blockID)
   blockID = categorical(blockID);
end
blockID = blockID(ismember(blockID,C.BlockID));
if isempty(blockID)
   warning('Invalid BlockID provided; using BlockID from C instead.');
   blockID = unique(C.BlockID);
end

if numel(COL) < N_CLUS_MAX
   error('Must have at least as many colors as N_CLUS_MAX (%g)',N_CLUS_MAX);
end

if numel(blockID) > 1
   if nargout > 0
      fig = gobjects(size(blockID));
      idx = cell(size(blockID));
      S = cell(size(blockID));
      for i = 1:numel(blockID)
         [fig(i),idx{i},S{i}] = make.xcorr.pc_loadings_plot(C,blockID(i));
      end
   else
      for i = 1:numel(blockID)
         make.xcorr.pc_loadings_plot(C,blockID(i));
      end
   end
   return;
end

C = C(ismember(C.BlockID,blockID),:);
name = catID2Name(blockID);
R = cell2mat(C.r);
[~,score] = pca(R);
S = score(:,1:N_PC_MAX);

[idx,centroid,sumd] = kmeans(S,N_CLUS_MAX);
for i = 1:numel(unique(idx))
   sumd(i) = sumd(i) ./ sum(idx == i);
end

fname = sprintf('Example: %s Top-3 PC loadings',name);
fig = figure(...
   'Name',fname,...
   'Color','w',...
   'Position',[424   357   684   521]);
ax = axes(fig,...
   'NextPlot','add',...
   'View',VIEW,...
   'XGrid','on',...
   'XColor','k',...
   'YGrid','on',...
   'YColor','k',...
   'ZGrid','on',...
   'ZColor','k',...
   'FontName','Arial',...
   'LineWidth',1);


[sX,sY,sZ] = sphere(N_FACE_SPHERE);
for i = 1:size(centroid,1)
   scatter3(ax,score(idx==i,1),score(idx==i,2),score(idx==i,3),...
      'SizeData',20,...
      'MarkerFaceColor',COL{i},...
      'MarkerEdgeColor','none',...
      'MarkerFaceAlpha',0.5);
   scatter3(ax,centroid(i,1),centroid(i,2),centroid(i,3),...
      'SizeData',40,...
      'MarkerFaceColor','k',...
      'MarkerEdgeColor',COL{i},...
      'LineWidth',1.5);
   
   xx = sX .* sumd(i);
   yy = sY .* sumd(i);
   zz = sZ .* sumd(i);
   surf(ax,xx + centroid(i,1),yy + centroid(i,2), zz + centroid(i,3),...
      'FaceColor',COL{i},...
      'EdgeColor',COL{i},...
      'FaceAlpha',0.3,...
      'EdgeAlpha',0.15);
   
end

xlabel(ax,'PC-1','FontName','Arial','Color','k');
ylabel(ax,'PC-2','FontName','Arial','Color','k');
zlabel(ax,'PC-3','FontName','Arial','Color','k');
title(ax,fname,'FontName','Arial','Color','k');

if nargout < 1
   outDir = defs.FileNames('OUTPUT_FIG_DIR');
   outDir = fullfile(outDir,'Cross-Correlations','PCA',name);
   if exist(outDir,'dir')==0
      mkdir(outDir);
   end
   batchHandleFigure(fig,outDir,[name '_Example-PC-Loadings']);
else
   return;
end

end