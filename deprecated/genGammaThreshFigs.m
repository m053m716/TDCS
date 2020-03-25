function genGammaThreshFigs(Rates,Condition,varargin)
%GENGAMMATHRESHFIGS    Generate figures for tDCS analysis with ISI change threshold cutoff.
%
%  genGammaThreshFigs(Rates,Condition);
%  --> Uses defs.GammaThreshFigs() for `pars`
%
%  genGammaThreshFigs(Rates,Condition,pars)
%  --> Gives `pars` directly
%
%  genGammaThreshFigs(Rates,Condition,'NAME',value,...);
%  --> Uses defs.GammaThreshFigs() for `pars` and sets specific 
%        elements using 'NAME', value pairs

% DEFAULT CONSTANTS
switch nargin
   case {0,1}
      error('Too few input arguments.');
   case 2
      pars = defs.GammaThreshFigs();
   case 3
      pars = varargin{1};
   otherwise
      pars = defs.GammaThreshFigs();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% PLOT POSITIVE AND NEGATIVE "RESPONDERS" 
figure('Name',pars.NAME, ...
       'Color','w',...
       'Units','Normalized', ...
       'Position', [0.2 0.2 0.6 0.6]);

for ii = 1:numel(pars.TITLE)
    subplot(2,numel(pars.TITLE),ii); 
    set(gca,'FontName',pars.FONT_NAME);
    set(gca,'NextPlot','replacechildren');
    boxplot(log(Rates(:,ii)),Condition);
    
    pars.TITLE(pars.TITLE{ii},...
       'FontName',pars.FONT_NAME,...
       'FontSize',16,...
       'Color',pars.FONT_COLOR);
    ylim(pars.YLIM1);
    xlabel('Treatment Group',...
       'FontName',pars.FONT_NAME,...
       'FontSize',14,...
       'Color',pars.FONT_COLOR);
    ylabel('log(spikes/sec)',...
       'FontName',pars.FONT_NAME,...
       'FontSize',14,...
       'Color',pars.FONT_COLOR);
    
    if ii==1
        continue;
    end
    
    subplot(2,numel(pars.TITLE),ii+numel(pars.TITLE));  
    set(gca,'FontName',pars.FONT_NAME);
    set(gca,'NextPlot','replacechildren');
    boxplot(Rates(:,ii)-Rates(:,1),Condition);
    pars.TITLE(pars.TITLE{ii},...
       'FontName',pars.FONT_NAME,...
       'FontSize',16,...
       'Color',pars.FONT_COLOR);
    ylim(pars.YLIM2);
    xlabel('Treatment Group',...
       'FontName',pars.FONT_NAME,...
       'FontSize',14,...
       'Color',pars.FONT_COLOR);
    ylabel('\Deltaspikes/sec',...
       'FontName',pars.FONT_NAME,...
       'FontSize',14,...
       'Color',pars.FONT_COLOR);
    
end
savefig(gcf,sprintf('%s by Period.fig',pars.NAME));
saveas(gcf,sprintf('%s by Period.jpeg',pars.NAME));

end