function SimpleLFPData = generateBasicLFPFigures(LFPData)
%GENERATEBASICLFPFIGURES  Makes the basic LFP figures for tDCS analysis
%
%   SimpleLFPData = GENERATEBASICLFPFIGURES(LFPData)
%
%   --------
%    INPUTS
%   --------
%    LFPData    :   The LFP data that has been extracted from all tDCS
%                   blocks.
%
%   --------
%    OUTPUT
%   --------
%   SimpleLFPData : Cells of tables with median band power for each
%                   recording period for each band on every channel.

% DEFAULTS
TT = [5, 15; ...
      15, 35; ...
      35, 50; ...
      50, 65; ...
      65, 80; ...
      80, inf];
  
BAND = unique(LFPData{1,1}.Band);
GROUPS = {'Pre-Stim', ...
          'Stimulation', ...
          'Post-Stim1', ...
          'Post-Stim2', ...
          'Post-Stim3', ...
          'Post-Stim4'};
      
% CHECK INPUT
if abs(numel(LFPData) - size(TT,1)) > eps
    error('Mismatch in number of cells of LFPData and rows of TT.');
end

% LOOP AND EXTRACT MEDIAN BAND POWER

SimpleLFPData = cell(1,numel(LFPData));
for iT = 1:size(TT,1)
    Rat = [];
    Block = [];
    Band = [];
    Channel = [];
    Power = [];
    fprintf(1,['\nCollecting LFP average band power'...
              ' from %d minutes to %d minutes'], ...
              TT(iT,1),TT(iT,2));
    for iB = 1:numel(BAND)
        fprintf(1,'. ');
        X = LFPData{1,iT}(ismember(LFPData{1,iT}.Band,BAND{iB}),:);
        for iX = 1:size(X,1)
            for iCh = 1:16
                Rat = [Rat; {X.File{iX}{iCh}(1:7)}];
                Block = [Block; X.File{iX}(iCh)];
                Band = [Band; {BAND{iB}}];
                Channel = [Channel; iCh];
                Power = [Power; mean(X.S{iX}{iCh})];
            end
        end
    end    
    fprintf(1,'complete.\n');
    SimpleLFPData{1,iT} = table(Rat,Block,Band,Channel,Power);
end

% APPEND ANIMAL AND CONDITION
load('2017-06-14_Excluded Metric Subset.mat','Assignment');
N = size(SimpleLFPData{1,1},1);
Condition = nan(N,1);
Animal = nan(N,1);
Remove_Vec = true(N,1);

for iN = 1:N
    Name = SimpleLFPData{1,1}.Rat{iN};
    Num = str2double(Name(6:7));
    Index = abs(Assignment.SessionID-Num)<eps;

    if (isempty(find(Index,1)))
        Remove_Vec(iN) = false;
    else
        Condition(iN) = Assignment.Condition(Index);
        Animal(iN) = Assignment.Animal(Index);    
    end
end

Animal = Animal(Remove_Vec);
Condition = Condition(Remove_Vec);
for iEpoch = 1:numel(SimpleLFPData)
    SimpleLFPData{1,iEpoch} = SimpleLFPData{1,iEpoch}(Remove_Vec,:);
    SimpleLFPData{1,iEpoch} = [SimpleLFPData{1,iEpoch}, table(Animal,Condition)];
    SimpleLFPData{1,iEpoch}.Properties.VariableNames{6} = 'Animal';
    SimpleLFPData{1,iEpoch}.Properties.VariableNames{7} = 'Condition';
end

% GET FIGURES FOR ALL POWER BANDS
for iB = 1:numel(BAND)
    fname = sprintf('%s mean power by period',BAND{iB});
    figure('Name',fname, ...
           'Units','Normalized',...
           'Position',[0.1 0.1 0.8 0.8]);

    RMS = [];

    for iEpoch = 1:numel(SimpleLFPData)
        RMS = [RMS,log(SimpleLFPData{1,iEpoch}(...
         ismember(SimpleLFPData{1,iEpoch}.Band,BAND{iB}),:).Power)]; %#ok<AGROW>
    end

    boxplot(RMS, GROUPS);
    ylabel('log(RMS)');
    title(fname);
    savefig(gcf,[fname '.fig']);
    saveas(gcf,[fname '.jpeg']);
    delete(gcf);
end

% GET FIGURES FOR POWER BANDS BY TREATMENT
for iB = 1:numel(BAND)
    fname = sprintf('%s mean power by treatment and period',BAND{iB});
    figure('Name',fname, ...
           'Units','Normalized',...
           'Position',[0.1 0.1 0.8 0.8]);       
       
    for iCondition = 1:6
        subplot(3,2,iCondition);
        Condition_Index = abs(Condition(...
            ismember(SimpleLFPData{1,iEpoch}.Band,BAND{iB}))-iCondition)<eps;
        boxplot(RMS(Condition_Index,:), GROUPS);
        ylabel('log(RMS)');
        title(['Condition ' num2str(iCondition)]);
    end
    suptitle(fname);
    savefig(gcf,[fname '.fig']);
    saveas(gcf,[fname '.jpeg']);
    delete(gcf);
end

% GET FIGURES FOR POWER BAND CHANGES BY TREATMENT
RMS_Change = (SimpleLFPData{1,2}.Power) - (SimpleLFPData{1,1}.Power);
    figure('Name','LFP mean power changes by treatment (subplots)', ...
           'Units','Normalized',...
           'Position',[0.1 0.1 0.8 0.8]);      
for iB = 1:numel(BAND)
    subplot(2,3,iB);
    fname = sprintf('%s mean power change by treatment',BAND{iB});
    Band_Index = ismember(SimpleLFPData{1,iEpoch}.Band,BAND{iB});
    boxplot(RMS_Change(Band_Index),Condition(Band_Index));
    ylabel('\DeltaRMS');
    xlabel('Treatment');
    title(fname);
    
end

suptitle('LFP mean power changes by treatment');
savefig(gcf,'LFP mean power changes by treatment - subplot.fig');
saveas(gcf,'LFP mean power changes by treatment - subplot.jpeg');


figure('Name','LFP mean power changes by treatment (1 Figure)', ...
       'Units','Normalized',...
       'Position',[0.1 0.1 0.8 0.8]);      

Band = SimpleLFPData{1,iEpoch}.Band;
boxplot(RMS_Change,[Condition,Band], ...
         'PlotStyle','compact');
     
ylabel('\DeltaRMS');
xlabel('Treatment');

title('LFP mean power changes by treatment');
savefig(gcf,'LFP mean power changes by treatment - single.fig');
saveas(gcf,'LFP mean power changes by treatment - single.jpeg');

end