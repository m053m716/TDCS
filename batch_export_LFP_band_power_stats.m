%% Export LFP band power values for statistical analyses
% clear; clc;
% [F,pars] = loadOrganizationData();
% 
% T = export_LFP_bandpower__stats(F); % old -- probably does not work
% 
% if exist(pars.OUTPUT_STATS_DIR_CSV,'dir')==0
%    mkdir(pars.OUTPUT_STATS_DIR_CSV);
% end
% if exist(pars.OUTPUT_STATS_DIR_MAT,'dir')==0
%    mkdir(pars.OUTPUT_STATS_DIR_MAT);
% end
% writetable(T,fullfile(pars.OUTPUT_STATS_DIR_CSV,...
%    [datestr(datetime,'YYYY-mm-dd_HH-MM-SS') '_' pars.LFP_STATS_FILE '.csv']));
% save(fullfile(pars.OUTPUT_STATS_DIR_MAT,[pars.LFP_STATS_FILE '.mat']),...
%    'T','-v7.3');

%% Export LFP Band powers for repeated-measures analysis
% clear; clc;
% [F,pars] = loadOrganizationData();
% 
% T = export_LFP_bandpower__rm_stats(F); % should work
% 
% if exist(pars.OUTPUT_STATS_DIR_CSV,'dir')==0
%    mkdir(pars.OUTPUT_STATS_DIR_CSV);
% end
% if exist(pars.OUTPUT_STATS_DIR_MAT,'dir')==0
%    mkdir(pars.OUTPUT_STATS_DIR_MAT);
% end
% writetable(T,fullfile(pars.OUTPUT_STATS_DIR_CSV,...
%    [datestr(datetime,'YYYY-mm-dd_HH-MM-SS') '_' pars.LFP_RM_STATS_FILE '.csv']));
% save(fullfile(pars.OUTPUT_STATS_DIR_MAT,[pars.LFP_RM_STATS_FILE '.mat']),...
%    'T','-v7.3');

%% Export LFP Band powers for detailed (many rows) statistics
clear; clc;
[F,pars] = loadOrganizationData();

T = export_LFP_bandpower__stats_detailed(F); % should work

if exist(pars.OUTPUT_STATS_DIR_CSV,'dir')==0
   mkdir(pars.OUTPUT_STATS_DIR_CSV);
end
if exist(pars.OUTPUT_STATS_DIR_MAT,'dir')==0
   mkdir(pars.OUTPUT_STATS_DIR_MAT);
end
writetable(T,fullfile(pars.OUTPUT_STATS_DIR_CSV,...
   [datestr(datetime,'YYYY-mm-dd_HH-MM-SS') '_' pars.LFP_DETAILED_STATS_FILE '.csv']));
save(fullfile(pars.OUTPUT_STATS_DIR_MAT,[pars.LFP_DETAILED_STATS_FILE '.mat']),...
   'T','-v7.3');

%% Export LFP Band powers for detailed (many columns) time-series JMP
% clear; clc;
% [F,pars] = loadOrganizationData();
% 
% T = export_LFP_bandpower__stats_detailed_timeseries(F); % should work
% 
% if exist(pars.OUTPUT_STATS_DIR_CSV,'dir')==0
%    mkdir(pars.OUTPUT_STATS_DIR_CSV);
% end
% if exist(pars.OUTPUT_STATS_DIR_MAT,'dir')==0
%    mkdir(pars.OUTPUT_STATS_DIR_MAT);
% end
% writetable(T,fullfile(pars.OUTPUT_STATS_DIR_CSV,...
%    [datestr(datetime,'YYYY-mm-dd_HH-MM-SS') '_' pars.LFP_DETAILED_STATS_TS_FILE '.csv']));
% save(fullfile(pars.OUTPUT_STATS_DIR_MAT,[pars.LFP_DETAILED_STATS_TS_FILE '.mat']),...
%    'T','-v7.3');