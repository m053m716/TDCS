function ax = batch_export_delta_Rate_Figs(T,varargin)
%BATCH_EXPORT_DELTA_RATE_FIGS  Export figures regarding delta-firing rate
%
%  batch_export_delta_Rate_Figs(dFR_table,'NAME',value,...);
%  --> T : Output by `compute_delta_FR`
%
%  --> <'NAME',value> pair syntax for setting optional parameters
%     * Default parameters are loaded from `defs.WholeTrialFigs`

pars = parseParameters('Export_Delta_Figs',varargin{:});
if istable(T)
   curVec = [-1 1];
   for iIntensity = 1:3
      for iPolarity = 1:2
         figName = sprintf('%s-%s',...
                        pars.INTENSITY_LABEL{iIntensity},...
                        pars.CURRENT_LABEL{iPolarity});
         fig = figure('Name',figName,...
               'Units','Normalized',...
               'Color','w',...
               'Position',pars.FIG_POS);
         ax = axes(fig,'FontName','Arial',...
            'XColor','k','YColor','k',...
            'NextPlot','add');
         xlabel(ax,'Time (min)','FontName','Arial','FontSize',14,'Color','k');
         ylabel(ax,'\Delta \surd (FR)', 'FontName','Arial','FontSize',14,'Color','k'); 
         title(ax,figName,'FontName','Arial','FontSize',16,'Color','k');
         EPOCH_COLS = [];
         idx = T.CurrentID==curVec(iPolarity) & T.ConditionID==iIntensity;
         R = T.delta_sqrt_Rate(idx);
         M = T.mask(idx);
         for iEpoch = 1:numel(pars.EPOCH_TS)
            c = pars.CONDITION_CUR_COL{iIntensity,iPolarity}.*pars.EPOCH_COL_FACTOR(iEpoch);
            [vec,ts] = getEpochSampleIndices(T(idx,:),iEpoch);
            r = cellfun(@(C,v)C(v),R,vec,'UniformOutput',false);
            mask = cellfun(@(C,v)C(v),M,vec,'UniformOutput',false);
            data = struct('r',r,'mask',mask);
            
            ax = batch_export_delta_Rate_Figs(data,...
               'EPOCH_TS',ts,...
               'CONDITION_ID',iIntensity,...
               'EPOCH_ID',iEpoch,...
               'CUR_ID',iPolarity,...
               'COLOR',c,...
               'AX',ax);  
            EPOCH_COLS = [EPOCH_COLS; c]; %#ok<AGROW>
         end
%          legend(ax,'Location','best',...
%             'FontSize',12,'FontName','Arial','TextColor','black');
         addEpochLabelsToAxes(ax,...
            'LABEL_HEIGHT',15,...
            'LABEL_OFFSET',20,...
            'LABEL_FIXED_Y',-120,...
            'EPOCH_COL',EPOCH_COLS,...
            'TEXT_COL',[0 0 0]);
         xlim(ax,pars.XLIM);
         ylim(ax,pars.YLIM);
         ax.YTick = [-100 -50 0 50 100];
         fname = sprintf('%s-%s',...
                        pars.INTENSITY_FNAME{iIntensity},...
                        pars.CURRENT_FNAME{iPolarity});
         if exist(pars.OUT_FOLDER,'dir')==0
            mkdir(pars.OUT_FOLDER);
         end
         expAI(fig,fullfile(pars.OUT_FOLDER,[fname pars.TAG '.eps']));
         savefig(fig,fullfile(pars.OUT_FOLDER,[fname pars.TAG '.fig']));
         saveas(fig,fullfile(pars.OUT_FOLDER,[fname pars.TAG '.png']));
         delete(fig);
      end
   end
   return;
else
   if ~isa(pars.AX,'matlab.graphics.axis.Axes')
      error(['tDCS:' mfilename ':BadParams'],...
         ['\n\t->\t<strong>[BATCH_EXPORT_DELTA_RATE_FIGS]:</strong>\n ' ...
         'Bad syntax. Likely cause is not giving dFR_table as cell input.\n']);
   end
   ax = pars.AX;
end

YData = vertcat(T.r);
XData = cell2mat(pars.EPOCH_TS);
XData = XData(:);
YData = YData(:);
MaskData = vertcat(T.mask);
MaskData = MaskData(:);
YData(MaskData) = [];
XData(MaskData) = [];

dispName = sprintf('%s-%s (%s)',...
   pars.INTENSITY_LABEL{pars.CONDITION_ID},...
   pars.CURRENT_LABEL{pars.CUR_ID},...
   pars.EPOCH_NAMES{pars.EPOCH_ID});

% YData = YData.';
% XData = XData.';
% XData = XData + randn(1,numel(XData)).*pars.XJITTER;
% XData = XData ./ 60; % Account for initial offset
% line(ax,XData,YData,...
%    'LineStyle','none',...
%    'Marker','o',...
%    'MarkerEdgeColor','none',...
%    'MarkerFaceColor',pars.COLOR,...
%    'MarkerSize',pars.MARKER_SIZE,...
%    'DisplayName',dispName);

YData = YData.';
XData = XData.';
XData = XData + randn(1,numel(XData)).*pars.XJITTER;
XData = XData ./ 60; % Convert to minutes
scatter(ax,XData,YData,...
   'Marker','o',...
   'MarkerEdgeColor','none',...
   'MarkerFaceColor',pars.COLOR,...
   'SizeData',pars.MARKER_SIZE,...
   'MarkerFaceAlpha',pars.MARKER_FACE_ALPHA,...
   'DisplayName',dispName);

% XData = XData ./ 60; % Account for initial offset
% boxplot(ax,YData,XData,...
%    'BoxStyle','filled',...
%    'Colors',pars.COLOR);
   

end