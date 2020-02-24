%% DEFAULTS
clc;
DIR = 'P:\Rat\tDCS';        % Data directory
FILT_PATH = '_Filtered';    % Filt data directory
FS_ID = '_Filt_P1_Ch_008';  % File containing sampling freq
START_BASAL = 5;            % Start of basal period (minutes)
START_STIM = 15;            % Start of stimulation (minutes)
STOP_STIM = 35;             % End of stimulation (minutes)
STOP_POST1 = 50;            % End of POST-1 period (minutes)
STOP_POST2 = 65;            % End of POST-2 period (minutes)
STOP_POST3 = 80;            % End of POST-3 period (minutes)


%% INITIALIZE
% F = dir([DIR filesep 'TDCS-*']);
tStart = tic; 


%% SPIKE PRE-STIM
D_PRE = []; SPK_PRE = []; 
FS = nan(size(F,1),1);
fprintf(1,'\tExtracting PRE-stim metrics...\n');
for ii = 1:size(F,1)
    fprintf(1,'\t->\t%s...',F(ii).name);
    temp = dir(fullfile(DIR,F(ii).name,'TDCS*'));
    if numel(temp) > 1
        tempcheck = 1;
        pname = fullfile(DIR,F(ii).name,temp(1).name);
        fname = fullfile(pname, ...
         [temp(tempcheck).name FILT_PATH], ...
         [temp(tempcheck).name FS_ID '.mat']);
        while exist(fname,'file')==0
            tempcheck = tempcheck + 1;
            pname = fullfile(DIR,F(ii).name,temp(tempcheck).name);
            fname = fullfile(pname, ...
                             [temp(tempcheck).name FILT_PATH], ...
                             [temp(tempcheck).name FS_ID '.mat']);
        end
    else
        pname = fullfile(DIR,F(ii).name,temp.name);
        fname = fullfile(pname, ...
                         [temp.name FILT_PATH], ...
                         [temp.name FS_ID '.mat']);
                     
        
    end
    load(fname,'fs');
    fprintf(1,'...');
    FS(ii) = fs;
    iStart_basal = START_BASAL * 60 * FS(ii);
    iStop_basal = START_STIM * 60 * FS(ii);
    [d,spk] = Simple_Spike_Analysis( ...
                'DIR',[DIR filesep F(ii).name], ...
                'SHOW_PROGRESS',false, ...
                'ISTART',iStart_basal, ...
                'ISTOP',iStop_basal, ...
                'FS',FS(ii));
    D_PRE = [D_PRE; d]; 
    SPK_PRE = [SPK_PRE; spk]; 
    fprintf(1,'complete.\n');
    clear d spk;
end
fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
ElapsedTime(tStart);

%% SPIKE DURING-STIM
D_STIM = []; SPK_STIM = []; 
tStart = tic; 
fprintf(1,'\n\tExtracting DURING-stim metrics...\n');
for ii = 1:size(F,1)
    fprintf(1,'\t->\t%s...',F(ii).name);
    iStart_stim = START_STIM * 60 * FS(ii);
    iStop_stim = STOP_STIM * 60 * FS(ii);
    fprintf(1,'...');
    [d,spk] = Simple_Spike_Analysis( ...
                'DIR',[DIR filesep F(ii).name], ...
                'SHOW_PROGRESS',false, ...
                'ISTART',iStart_stim, ...
                'ISTOP',iStop_stim, ...
                'FS',FS(ii));
    D_STIM = [D_STIM; d]; 
    SPK_STIM = [SPK_STIM; spk]; 
    fprintf(1,'complete.\n');
    clear d spk;
end
fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
ElapsedTime(tStart);

%% SPIKE POST-STIM1
D_POST1 = []; SPK_POST1 = []; 
tStart = tic; 
fprintf(1,'\n\tExtracting POST-STIM1 metrics...\n');
for ii = 1:size(F,1)
    fprintf(1,'\t->\t%s...',F(ii).name);
    iStop_stim = STOP_STIM * 60 * FS(ii);
    iStop_post1 = STOP_POST1 * 60 * FS(ii);
    fprintf(1,'...');
    [d,spk] = Simple_Spike_Analysis( ...
                'DIR',[DIR filesep F(ii).name], ...
                'SHOW_PROGRESS',false, ...
                'ISTART',iStop_stim, ...
                'ISTOP',iStop_post1, ...
                'FS',FS(ii));
    D_POST1 = [D_POST1; d]; 
    SPK_POST1 = [SPK_POST1; spk]; 
    fprintf(1,'complete.\n');
    clear d spk;
end
fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
ElapsedTime(tStart);

%% SPIKE POST-STIM2
D_POST2 = []; SPK_POST2 = []; 
tStart = tic; 
fprintf(1,'\n\tExtracting POST-STIM2 metrics...\n');
for ii = 1:size(F,1)
    fprintf(1,'\t->\t%s...',F(ii).name);
    iStop_post1 = STOP_POST1 * 60 * FS(ii);
    iStop_post2 = STOP_POST2 * 60 * FS(ii);
    fprintf(1,'...');
    [d,spk] = Simple_Spike_Analysis( ...
                'DIR',[DIR filesep F(ii).name], ...
                'SHOW_PROGRESS',false, ...
                'ISTART',iStop_post1, ...
                'ISTOP',iStop_post2, ...
                'FS',FS(ii));
    D_POST2 = [D_POST2; d]; 
    SPK_POST2 = [SPK_POST2; spk]; 
    fprintf(1,'complete.\n');
    clear d spk;
end
fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
ElapsedTime(tStart);

%% SPIKE POST-STIM3
D_POST3 = []; SPK_POST3 = []; 
tStart = tic; 
fprintf(1,'\n\tExtracting POST-STIM3 metrics...\n');
for ii = 1:size(F,1)
    fprintf(1,'\t->\t%s...',F(ii).name);
    iStop_post2 = STOP_POST2 * 60 * FS(ii);
    iStop_post3 = STOP_POST3 * 60 * FS(ii);
    fprintf(1,'...');
    [d,spk] = Simple_Spike_Analysis( ...
                'DIR',[DIR filesep F(ii).name], ...
                'SHOW_PROGRESS',false, ...
                'ISTART',iStop_post2, ...
                'ISTOP',iStop_post3, ...
                'FS',FS(ii));
    D_POST3 = [D_POST3; d]; 
    SPK_POST3 = [SPK_POST3; spk]; 
    fprintf(1,'complete.\n');
    clear d spk;
end
fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
ElapsedTime(tStart);

%% SPIKE POST-STIM4
D_POST4 = []; SPK_POST4 = []; 
tStart = tic; 
fprintf(1,'\n\tExtracting POST-STIM4 metrics...\n');
for ii = 1:size(F,1)
    fprintf(1,'\t->\t%s...',F(ii).name);
    iStop_post3 = STOP_POST3 * 60 * FS(ii);
    fprintf(1,'...');
    [d,spk] = Simple_Spike_Analysis( ...
                'DIR',[DIR filesep F(ii).name], ...
                'SHOW_PROGRESS',false, ...
                'ISTART',iStop_post3, ...
                'FS',FS(ii));
    D_POST4 = [D_POST4; d]; 
    SPK_POST4 = [SPK_POST4; spk]; 
    fprintf(1,'complete.\n');
    clear d spk;
end
fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
ElapsedTime(tStart);

