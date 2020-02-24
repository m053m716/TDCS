%% DEFAULTS
clc;
DIR = 'P:\Rat\tDCS';        % Data directory
FILT_PATH = '_Filtered';    % Filt data directory
FS_ID = '_Filt_P1_Ch_008';  % File containing sampling freq
TT = [5, 15; ...
      15, 35; ...
      35, 50; ...
      50, 65; ...
      65, 80; ...
      80, inf];

%% GET SIMPLE LFP DATA
% F = dir([DIR filesep 'TDCS-*']);
tStart = tic; 
% LFPData = cell(1,6);

% Get info for BEFORE stim period
FS = nan(size(F,1),1);

for iT = 1:size(TT,1)
    fprintf(1,'\tExtracting LFP data from %d minutes to %d minutes...\n', ...
                TT(iT,1),TT(iT,2));
    for ii = 1:size(F,1)
        fprintf(1,'\t->\t%s\n',F(ii).name);
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

        FS(ii) = fs;
        iStart = TT(iT,1) * 60 * FS(ii);
        iStop = TT(iT,2) * 60 * FS(ii);
        
        LFPData{1,iT} = [LFPData{1,iT}; ...
                            Simple_LFP_Analysis( ...
                            'DIR',pname, ...
                            'DATA_START',iStart, ...
                            'DATA_END', iStop, ...
                            'TSTART',tStart)];
    end
    fprintf(1,'\t- - - - - - - - - - - - - - - - - -\n');
    ElapsedTime(tStart);
end