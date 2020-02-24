function genWholeTrialFigs(C)
%GENWHOLETRIALFIGS    Generate whole trial figures for FR in tDCS analysis.
%
%   GENWHOLETRIALFIGS(C)

% MAKE WHOLE-TRIAL RATE FIGURE BY ANIMAL
figure('Name','Whole-trial FR by Animal',...
       'Units','Normalized',...
       'Position',[0.3 0.3 0.4 0.4]);

boxplot(log(C.Rate),C.Animal);
xlabel('Animal');
ylabel('log(rate)');
title('log(rate) by Animal');

% BY TREATMENT
figure('Name','Whole-trial FR by Treatment',...
       'Units','Normalized',...
       'Position',[0.3 0.4 0.4 0.4]);

boxplot(log(C.Rate),C.Condition);
xlabel('Treatment');
ylabel('log(rate)');   
title('log(rate) by Treatment');

% BY BOTH
figure('Name','Whole-trial FR by Treatment by Animal',...
       'Units','Normalized',...
       'Position',[0.4 0.4 0.4 0.4]);
boxplot(log(C.Rate),[C.Animal,C.Condition]);
ylabel('log(rate)');

title('log(rate) by Animal & Treatment');

end