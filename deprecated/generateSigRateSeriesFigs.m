function generateSigRateSeriesFigs(SpikeSeries,UnitData,varargin)
%GENERATESIGRATESERIESFIGS Make figures for tDCS analysis with actual IFR plots.
%
%  GENERATESIGRATESERIESFIGURES(SpikeSeries,UnitData);
%  --> Parses `pars` from `defs.SigRateChangeFigs()`
%
%  GENERATESIGRATESERIESFIGURES(SpikeSeries,UnitData,pars);
%  --> Pass `pars` directly as input argument
%
%  GENERATESIGRATESERIESFIGURES(SpikeSeries,UnitData,'NAME',value,...);
%  --> Uses `defs.SigRateChangeFigs()` to get `pars`
%     --> Modify fields of `pars` using 'NAME',value,... syntax

% DEFAULT CONSTANTS
switch nargin
   case 0
      error('Too few input arguments.');
   case 1
      error('Too few input arguments.');
   case 2
      pars = defs.SigRateSeriesFigs();
   case 3
      pars = varargin{1};
   otherwise
      pars = defs.SigRateSeriesFigs();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% LOOP THROUGH EACH "ROW" OF UNITDATA & PLOT CORRESPONDING SERIES DATA
N = size(UnitData,1);
for iN = 1:N
    fname = [UnitData.Name{iN} ' Ch' num2str(UnitData.Channel(iN)) ...
                               ' ' num2str(UnitData.Cluster(iN))];
    figure('Name',fname, ...
           'Units','Normalized', ...
           'Position', [0.2 0.2 0.6 0.6]);
    ind = ismember(SpikeSeries{1,1}.Name,UnitData.Name{iN}) ...
              & ismember(SpikeSeries{1,1}.Cluster,UnitData.Cluster(iN)) ...
              & ismember(SpikeSeries{1,1}.Channel,UnitData.Channel(iN));
          
    tx = SpikeSeries{1,1}.T{ind}/60 + 5;
    xx = SpikeSeries{1,1}.Y{ind};
    ty = SpikeSeries{1,2}.T{ind}/60 + 5;
    yy = SpikeSeries{1,2}.Y{ind};
    subplot(2,1,1);
    plot(tx, xx, 'LineWidth', 2);
    hold on;
    plot(ty + max(tx), yy, 'LineWidth', 2);
    line([min(ty+max(tx)), min(ty+max(tx))], ...
         [min(pars.YLIM_REG), max(pars.YLIM_REG)], ...
         'Color','k','LineStyle','--', 'LineWidth',2);
    pars.XLIM(pars.XLIM);
    ylim(pars.YLIM_REG);
    lgd = legend({'BASAL'; 'STIM'});
    lgd.TextColor = pars.FONT_COLOR;
    lgd.FontName = pars.FONT_NAME;
    title(fname,'FontName',pars.FONT_NAME,'FontSize',16,...
       'Color',pars.FONT_COLOR);
    ylabel('Spikes/Second','FontName',pars.FONT_NAME,'FontSize',14,...
       'Color',pars.FONT_COLOR);
    
    subplot(2,1,2);
    plot(tx, log(xx), 'LineWidth', 2);
    hold on;
    plot(ty + max(tx), log(yy), 'LineWidth', 2);
    line([min(ty+max(tx)), min(ty+max(tx))], ...
         [min(pars.YLIM_LOG), max(pars.YLIM_LOG)], ...
         'Color','k','LineStyle','--', 'LineWidth',2);
    pars.XLIM(pars.XLIM);
    ylim(pars.YLIM_LOG,'FontName');
    lgd = legend({'BASAL'; 'STIM'});
    lgd.TextColor = pars.FONT_COLOR;
    lgd.FontName = pars.FONT_NAME;
    ylabel('log(Spikes/Second','FontName',pars.FONT_NAME,'FontSize',14,...
       'Color',pars.FONT_COLOR);
    xlabel('Time (min)','FontName',pars.FONT_NAME,'FontSize',14,...
       'Color',pars.FONT_COLOR);
    
    savefig(gcf,[pars.SAVE_DIR filesep strrep(fname,' ','_') '.fig']);
    saveas(gcf,[pars.SAVE_DIR filesep strrep(fname,' ','_') '.jpeg']);
    delete(gcf);
end

end