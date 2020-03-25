function generateSigRateChangeSpikeFigures(X,varargin)
%GENERATESIGRATECHANGESPIKEFIGURES    Makes figures for units with significant rate changes for tDCS analysis.
%
%  GENERATESIGRATECHANGESPIKEFIGURES(UnitData);
%  --> Parses `pars` from `defs.SigRateChangeFigs()`
%
%  GENERATESIGRATECHANGESPIKEFIGURES(UnitData,pars);
%  --> Pass `pars` directly as input argument
%
%  GENERATESIGRATECHANGESPIKEFIGURES(UnitData,'NAME',value,...);
%  --> Uses `defs.SigRateChangeFigs()` to get `pars`
%     --> Modify fields of `pars` using 'NAME',value,... syntax

% DEFAULT CONSTANTS
switch nargin
   case 0
      error('Too few input arguments');
   case 1
      pars = defs.SigRateChangeFigs();
   case 2
      pars = varargin{1};
   otherwise
      pars = defs.SigRateChangeFigs();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% GET OUTPUT VARIABLE TO GRAPH
Y = X.AvgRateSTIM - X.AvgRateBASAL;

% BOXPLOT: UNITS WITH SIG CHANGE BY CONDITION
figure('Name',pars.BY_TREATMENT_NAME, ...
       'Color','w',...
       'Units','Normalized', ...
       'Position', [0.2 0.2 0.6 0.6]);

boxplot(Y,X.Condition)
set(gca,'FontName',pars.FONT_NAME);
title(sprintf('\Delta %s',pars.BY_TREATMENT_NAME),...
        'FontName',pars.FONT_NAME,...
        'FontSize',16,...
        'Color',pars.FONT_COLOR);
ylabel('\DeltaAverage Firing Rate', ...
        'FontName',pars.FONT_NAME,...
        'FontSize',16,...
        'Color',pars.FONT_COLOR);
xlabel('Treatment Group', ...
        'FontName',pars.FONT_NAME,...
        'FontSize',16,...
        'Color',pars.FONT_COLOR);
savefig(gcf,sprintf('%s.fig',pars.BY_TREATMENT_NAME));
saveas(gcf,sprintf('%s.jpeg',pars.BY_TREATMENT_NAME));

% BOXPLOT: UNITS WITH SIG CHANGE BY CONDITION BY ANIMAL
figure('Name',pars.BY_TREATMENT_BY_ANIMAL_NAME, ...
       'Color','w',...
       'Units','Normalized', ...
       'Position', [0.2 0.2 0.6 0.6]);

% nC = numel(unique(X.Condition));
A = unique(X.Animal);
nA = numel(A);
for iA = 1:nA
    subplot(4,2,iA)
    ind = abs(X.Animal - A(iA)) < eps;
    boxplot(Y(ind),X.Condition(ind))
    set(gca,'FontName','Arial');
    title(['Animal ' num2str(A(iA))], ...
        'FontName',pars.FONT_NAME,...
        'FontSize',16,...
        'Color',pars.FONT_COLOR);
    ylabel('\DeltaAverage Firing Rate', ...
        'FontName',pars.FONT_NAME,...
        'FontSize',16,...
        'Color',pars.FONT_COLOR);
    xlabel('Treatment Group', ...
        'FontName',pars.FONT_NAME,...
        'FontSize',16,...
        'Color',pars.FONT_COLOR);
    ylim([-25 25]);
    
end
suptitle(sprintf('\Delta %s',pars.BY_TREATMENT_BY_ANIMAL_NAME));
savefig(gcf,sprintf('%s.fig',pars.BY_TREATMENT_BY_ANIMAL_NAME));
saveas(gcf,sprintf('%s.fig',pars.BY_TREATMENT_BY_ANIMAL_NAME));


end