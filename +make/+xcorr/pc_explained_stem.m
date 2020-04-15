function [fig,explained,C_ORD] = pc_explained_stem(C,blockID)
%PC_EXPLAINED_STEM  Create pc % explained plot for correlation time-series
%
%  fig = make.xcorr.pc_explained_stem(C);
%  --> Iterates on all unique C.BlockID
%
%  fig = make.xcorr.pc_explained_stem(C,blockID);
%  --> Specify blockID to match from C.BlockID
%
%  [fig,explained,C_ORD] = ...
%  --> Also return `explained` and `C_ORD`, the percent explained of each
%      component (from largest weight to smallest) as well as C_ORD, where
%      each row is a 3-element color vector for the corresponding PC.
%
%  -- Inputs --
%   -> C : Output from `compute_xcorr_FR`
%
%  -- Output --
%   -> fig: Figure handle (if not specified, treats as batch, saves fig)

N_MAX_PC = 10;
C_ORD = [...
   0    0.4470    0.7410;
   0.8500    0.3250    0.0980;
   0.9290    0.6940    0.1250;
   0.4940    0.1840    0.5560;
   0.4660    0.6740    0.1880;
   0.3010    0.7450    0.9330 ...
   ];

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

if numel(blockID) > 1
   if nargout > 0
      fig = gobjects(size(blockID));
      for i = 1:numel(blockID)
         [fig(i),C_ORD] = make.xcorr.pc_explained_stem(C,blockID(i));
      end
   else
      for i = 1:numel(blockID)
         make.xcorr.pc_explained_stem(C,blockID(i));
      end
   end
   return;
end

% Compute principal components
C = C(ismember(C.BlockID,blockID),:);
name = catID2Name(blockID);
fname = sprintf('Example: %s Cross-Correlation PCA - variance captured',...
   name);
R = cell2mat(C.r);
[~,~,~,~,explained] = pca(R);

fig = figure('Name',fname,...
   'Color','w',...
   'Position',[424 577 560 301]); 
ax = axes(fig,...
   'NextPlot','add',...
   'XColor','k',...
   'YColor','k',...
   'YLim',[0 100],...
   'LineWidth',1,...
   'FontName','Arial');

xc_c = cumsum(explained(1:N_MAX_PC));

stem(ax,1:N_MAX_PC,xc_c,...
   'Color','k','LineWidth',1.5,'MarkerFaceColor','none');
for i = 1:6
   stem(ax,i,xc_c(i),...
      'Color',C_ORD(i,:),...
      'MarkerFaceColor',C_ORD(i,:),...
      'LineWidth',1.75);
end

xlabel(ax,'Principal Component Number (XCorr Time-series)','FontName','Arial','Color','k');
ylabel(ax,'% data explained','FontName','Arial','Color','k');
title(ax,fname,'FontName','Arial','Color','k');

if nargout < 1
   outDir = defs.FileNames('OUTPUT_FIG_DIR');
   outDir = fullfile(outDir,'Cross-Correlations','PCA',name);
   if exist(outDir,'dir')==0
      mkdir(outDir);
   end
   batchHandleFigure(fig,outDir,[name '_Example-PC-Percent-Explained']);
else
   return;
end

end