function genFlatThreshRateFigs(Rates,Condition,varargin)
%GENFLATTHRESHRATEFIGS    Generate figures for tDCS analysis with FLAT rate change threshold cutoff.
%
%   GENFLATTHRESHRATEFIGS(Rates,Condition,'NAME',value,...)

% DEFAULT CONSTANTS
switch nargin
   case 0
      pars = defs.FlatThreshRateFigs();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.FlatThreshRateFigs();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% PLOT POSITIVE AND NEGATIVE "RESPONDERS" 
figure('Name',pars.FIG_NAME, ...
       'Color','w',...
       'Units','Normalized', ...
       'Position', pars.FIG_POS);
   
% Get corresponding indices
RateChange = Rates(:,2) - Rates(:,1);
ind_pos = (RateChange > pars.THRESH);
ind_neg = (RateChange < -pars.THRESH);

for ii = 1:numel(pars.TITLE)
    subplot(2,numel(pars.TITLE),ii);   
    boxplot(log(Rates(ind_pos,ii)),Condition(ind_pos));
    pars.TITLE(pars.TITLE{ii},'FontName','Open Sans Semibold',...
                    'FontSize',16);
    pars.YLIM(pars.YLIM);
    set(gca,'FontName','OpenSans-Regular');
    xlabel('Treatment Group','FontName','Open Sans Semibold',...
                             'FontSize',16);
    ylabel('log(spikes/sec)','FontName','Open Sans Semibold',...
                             'FontSize',16);
                         
    subplot(2,numel(pars.TITLE),numel(pars.TITLE)+ii);
    boxplot(log(Rates(ind_neg,ii)),Condition(ind_neg));
    pars.TITLE(pars.TITLE{ii},'FontName','Open Sans Semibold',...
                    'FontSize',16);
    pars.YLIM(pars.YLIM);
    set(gca,'FontName','OpenSans-Regular');
    xlabel('Treatment Group','FontName','Open Sans Semibold',...
                             'FontSize',16);
    ylabel('log(spikes/sec)','FontName','Open Sans Semibold',...
                             'FontSize',16);
    
end
savefig(gcf,'Rate Change Responders by Period.fig');
saveas(gcf,'Rate Change Responders by Period.jpeg');

% PLOT POSITIVE AND NEGATIVE "MOST RESPONSIVE"
figure('Name','Rate Change Extreme 5% Responders',...
       'Color','w',...
       'Units','Normalized',...
       'Position',[0.2 0.2 0.6 0.6]);

% Get corresponding indices
RateChange = Rates(:,2) - Rates(:,1);
ind_pos = (RateChange > pars.EX_POS_THRESH);
ind_neg = (RateChange < pars.EX_NEG_THRESH);

for ii = 1:numel(pars.TITLE)
    subplot(2,numel(pars.TITLE),ii);   
    scatter(Condition(ind_pos),log(Rates(ind_pos,ii)),5,'filled',...
                'MarkerEdgeColor','none','MarkerFaceColor','k');
    pars.TITLE(pars.TITLE{ii},'FontName','Open Sans Semibold',...
                    'FontSize',16);
    pars.YLIM(pars.YLIM);
    xlim([0 7]);
    set(gca,'XTick',1:6);
    set(gca,'FontName','OpenSans-Regular');
    xlabel('Treatment Group','FontName','Open Sans Semibold',...
                             'FontSize',16);
    ylabel('log(spikes/sec)','FontName','Open Sans Semibold',...
                             'FontSize',16);
                         
    subplot(2,numel(pars.TITLE),numel(pars.TITLE)+ii);
    scatter(Condition(ind_neg),log(Rates(ind_neg,ii)),5,'filled',...
                'MarkerEdgeColor','none','MarkerFaceColor','k');
    pars.TITLE(pars.TITLE{ii},'FontName','Open Sans Semibold',...
                    'FontSize',16);
    pars.YLIM(pars.YLIM);
    xlim([0 7]);
    set(gca,'XTick',1:6);
    set(gca,'FontName','OpenSans-Regular');
    xlabel('Treatment Group','FontName','Open Sans Semibold',...
                             'FontSize',16);
    ylabel('log(spikes/sec)','FontName','Open Sans Semibold',...
                             'FontSize',16);
    
end
savefig(gcf,'Rate Change Extreme Responders by Period.fig');
saveas(gcf,'Rate Change Extreme Responders by Period.jpeg');

end