%BATCH_LFP_POWER  Iterates on tDCS recordings to plot band-power/condition
clc;

%% LOAD PARAMETERS AND DATA
pars = defs.Experiment('TREATMENT','TREATMENT_FILE_KEY','NAME_KEY','TREATMENT_COL_FILL','TREATMENT_COL_EDGE','MARKUP_KEY');
tank = defs.Experiment('PROCESSED_TANK');
MIN_PTS = 2000;  % Minimum # of points (duration) in order to plot
to_view = 1:6;   % Condition ID numbers

if exist('LFP_Table','var')==0
   LFP_Table = parseLFP_Table();
end

%% MAKE FIGURE AND AXES
fig = figure('Name','Sliding LFP Power',...
      'Units','Normalized',...
      'Color','w',...
      'Position',defs.Experiment('FIG_POS'));
ax = axes(fig,'Units','Normalized','Position',[0.15 0.15 0.7 0.7],...
      'FontName','Arial','XColor','k','YColor','k','LineWidth',1.25,...
      'NextPlot','add');
for i = to_view
   uA = unique(LFP_Table.Animal(LFP_Table.Condition==i));
   fname = fullfile(pwd,[pars.TREATMENT_FILE_KEY{i} '_SlidingPower.mat']);
   if exist(fname,'file')==0
      s = cell(numel(uA),1);
      N = inf;
      keepvec = true(numel(uA),1);
      for a = 1:numel(uA)
         A = uA(a);
         recNum = LFP_Table.Rec(find((LFP_Table.Condition==i) & ...
            (LFP_Table.Animal==A),1,'first'));
         if isempty(recNum)
            fprintf(1,'Skipping recording for %s: <strong>Animal-%g</strong>\n',...
               pars.NAME_KEY{i},A);
            continue;
         end
         [data,fs] = loadDS_Data(recNum);

         [s{a},tmp] = SlidingPower(data,'WLEN',5001,'OV',0.5);
         if numel(s{a}) < MIN_PTS
            keepvec(a) = false;
            continue;
         end
         if numel(s{a}) < N
            N = numel(s{a});
            t = (0:(numel(data)-1))/fs; 
            idx = tmp;
         end
      end   
      s = s(keepvec);
      S = cell2mat(cellfun(@(x)x(1:N),s,'UniformOutput',false));
      t = t(idx);
      save(fname,'S','t','-v7.3'); 
   else
      fprintf(1,'Data for condition ''<strong>%s</strong>'' already extracted. Loading...',...
         pars.NAME_KEY{i});
      load(fname,'S','t');
      fprintf(1,'complete\n');
   end
   mu = nanmean(S,1);
   st_err = nanstd(S,[],1)./sqrt(size(S,1));
   plotWithShadedError(ax,t,mu,st_err,...
      'Color',pars.TREATMENT_COL_EDGE(i,:),...
      'FaceColor',pars.TREATMENT_COL_FILL(i,:),...
      'FaceAlpha',0.25,...
      'DisplayName',pars.NAME_KEY{i},...
      'Tag',pars.NAME_KEY{i},...
      'IconDisplayStyle','on',...
      'LineWidth',1.5);
end

%% ADD LABELS TO FIGURE
addEpochLabelsToAxes(ax,'LABEL_OFFSET',100,'LABEL_HEIGHT',80);
lgd = legend(ax,pars.MARKUP_KEY(to_view),...
   'Orientation','Vertical',...
   'Location','best');
lgd.FontSize = 10;
lgd.FontName = 'Arial';
lgd.Color = [0.85 0.85 0.85];

xlabel(ax,'Time (mins)','FontName','Arial','Color','k','FontSize',14);
ylabel(ax,'LFP RMS (V)','FontName','Arial','Color','k','FontSize',14);
title(ax,'LFP RMS by Treatment','FontName','Arial','Color','k','FontSize',16,'FontWeight','bold');

expAI(fig,'Sliding LFP Power - Shaded Error');
saveas(fig,'Sliding LFP Power - Shaded Error.png');
savefig(fig,'Sliding LFP Power - Shaded Error.fig');
