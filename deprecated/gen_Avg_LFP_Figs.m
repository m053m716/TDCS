function gen_Avg_LFP_Figs(LFP_Table,doSave)
%% GEN_AVG_LFP_FIGS  Generate average LFP tables from MEM spectrograms
%
% By: Max Murphy    v1.0    08/15/2017  Original version (R2017a)

%
if nargin < 2
   doSave = false;
end

%% Averages by condition
figure('Name','Average Spectrogram by Condition',...
       'Units','Normalized',...
       'Color','w',...
       'Position',[0.2 0.2 0.6 0.6]);
   
C = unique(LFP_Table.Condition);
C = sort(reshape(C,1,numel(C)),'ascend');
P = cell(max(C),1);

iPlot = 0;
for c = C
    iPlot = iPlot + 1;
    subplot(2,3,iPlot);
    ind = abs(LFP_Table.Condition-c)<eps;
    [f,t,P{c}] = mmAverageLFP(LFP_Table.FileName(ind),'NEWFIG',false); %#ok<ASGLU>
    title(['Treatment ' num2str(c)]);
end
suptitle('LFP Spectra by Treatment');
if doSave
   save('2017-08-15_LFP Treatment Averaged Spectra.mat','f','t','P','-v7.3');
end

%% Averages by animal
figure('Name','Average Spectrogram by Animal',...
       'Units','Normalized',...
       'Color','w',...
       'Position',[0.2 0.2 0.6 0.6]);
   
A = unique(LFP_Table.Animal);
A = sort(reshape(A,1,numel(A)),'ascend');
P = cell(max(A),1);

iPlot = 0;
for a = A
    iPlot = iPlot + 1;
    subplot(2,5,iPlot);
    ind = abs(LFP_Table.Animal-a)<eps;
    [f,t,P{a}] = mmAverageLFP(LFP_Table.FileName(ind),'NEWFIG',false); %#ok<ASGLU>
    title(['Animal ' num2str(a)]);
end
suptitle('LFP Spectra by Animal');

if doSave
   save('2017-08-15_LFP Animal Averaged Spectra.mat','f','t','P','-v7.3');
end

end