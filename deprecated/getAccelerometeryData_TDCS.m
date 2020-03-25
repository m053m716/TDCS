function acc = getAccelerometeryData_TDCS(blockName,tank)
%GETACCELEROMETERYDATA_TDCS  Returns struct with accelerometer data
%
%  acc = getAccelerometeryData_TDCS(blockName);
%  >> acc = getAccelerometeryData_TDCS('TDCS-81');
%
%  blockName : char array name of the recording rat/block (e.g. 'TDCS-81')
%  * If not given, a UI popup prompts for named folder
%  * If given as cell array, returns struct array corresponding to elements
%     of cell.
%
%  acc : Struct with accelerometery data. Each field is described by the
%        contents of the struct field '.desc'

PROCESSED_TANK = 'P:\Rat\tDCS';
if nargin < 2
   tank = PROCESSED_TANK;
end

if nargin < 1
   p = uigetdir(tank,'Select FOLDER (eg TDCS-81)');
   if p == 0
      acc = struct.empty();
      disp('No selection');
      return;
   end
   [~,name,~] = fileparts(p);
   rat = strsplit(name,'_');
   rat = rat{1};
else
   [rat,name] = getBlockFromName(blockName,tank);
end

if iscell(blockName)
   acc = initAccStruct;
   for i = 1:numel(blockName)
      tic;
      fprintf(1,'\n---\nParsing accelerometery for: <strong>%s</strong>\n',blockName{i});
      acc = horzcat(acc,getAccelerometeryData_TDCS(blockName{i},tank)); %#ok<AGROW>
      toc;
   end
   return;
end

% Parse data files
dataFile.x = fullfile(tank,rat,name,[name '_Digital'],[name '_DIG_AAUX1.mat']);
dataFile.y = fullfile(tank,rat,name,[name '_Digital'],[name '_DIG_AAUX2.mat']);
dataFile.z = fullfile(tank,rat,name,[name '_Digital'],[name '_DIG_AAUX3.mat']);
dataFile.stim = fullfile(tank,rat,name,[name '_Digital'],[name '_DIG_StimON.mat']);
dataFile.out = fullfile(tank,rat,name,[name '_Accelerometry_Data.mat']);

% Load data
try
   acc = initAccStruct(1);
   acc.x = load(dataFile.x,'data','fs');
   acc.y = load(dataFile.y,'data','fs');
   acc.z = load(dataFile.z,'data','fs');
   acc.stim = load(dataFile.stim,'data','fs');
catch
   acc = initAccStruct(0);
   fprintf(1,'\t->Could not parse accelerometry for <strong>%s</strong>\n',name);
   return;
end

acc.rat = rat;
acc.block = name;
% Decimate stim to make it same indexing as x/y/z accelerometers
acc.stim.data = single(decimate(double(acc.stim.data),4));
acc.stim.fs = acc.stim.fs / 4;
acc.sens_mag = sqrt(acc.x.data.^2 + acc.y.data.^2 + acc.z.data.^2);
acc.t = (0:(numel(acc.x.data)-1))/acc.x.fs;

acc.cal = getCalibrationData('A');
acc.x_cal = (acc.x.data - acc.cal.AAUX1.bias)/acc.cal.AAUX1.sens;
acc.y_cal = (acc.y.data - acc.cal.AAUX2.bias)/acc.cal.AAUX2.sens;
acc.z_cal = (acc.z.data - acc.cal.AAUX3.bias)/acc.cal.AAUX3.sens;
acc.sens_mag_cal = sqrt(acc.x_cal.^2 + acc.y_cal.^2 + acc.z_cal.^2);
acc.a_gravity_mag = 1;
acc.a_rest_offset_mag = median(acc.sens_mag_cal);
acc.a_mag_cal = acc.sens_mag_cal./acc.a_rest_offset_mag;

acc.dataFile = dataFile; % Raw data file is associated with struct
% % % % % % % % % % % % % % % % % % % % % % % % 

% % % Identify epoch start and stop points % % %
stim_onset = find(acc.stim.data > 0,1,'first');
if isempty(stim_onset)
   % Then use 15-minute ts as marker
   [~,stim_onset] = min(abs(acc.t - (15*60)));
end

stim_offset = find(acc.stim.data > 0,1,'last');
if isempty(stim_offset)
   % Then use 15-minute ts as marker
   [~,stim_offset] = min(abs(acc.t - (35*60)));
end

[~,valid_onset] = min(abs(acc.t - (5*60))); % "Valid" is 5-minutes and on

% For basal, "work backwards"
basal_offset = stim_onset-1;
basal_onset = max(valid_onset,(basal_offset - (10*60*acc.x.fs)));

% All others, "work forwards"
post1_onset = stim_offset + 1;
post1_offset = post1_onset + (15*60*acc.x.fs);
post2_onset = post1_offset + 1;
post2_offset = post2_onset + (15*60*acc.x.fs);
post3_onset = post2_offset + 1;
post3_offset = post3_onset + (15*60*acc.x.fs);
post4_onset = post3_offset + 1;
post4_offset = post4_onset + (15*60*acc.x.fs);

acc.idx = struct('BASAL',basal_onset:basal_offset,...
                 'STIM',stim_onset:stim_offset,...
                 'POST1',post1_onset:post1_offset,...
                 'POST2',post2_onset:post2_offset,...
                 'POST3',post3_onset:post3_offset,...
                 'POST4',post4_onset:post4_offset);

% Remove any epochs that would extend beyond the recorded record
F = {'BASAL','STIM','POST1','POST2','POST3','POST4'};
for iF = 1:numel(F)
   if acc.idx.(F{iF})(end) > numel(acc.t)
      acc.idx = rmfield(acc.idx,F{iF});
   end
end
acc.epochs = fieldnames(acc.idx);
acc.epochColors = {'b','r','b','b','b','b'};

% % % % % % % % % % % % % %
% Add "percent of time moving"
acc.pct_move = estimatePercentMoving(acc);

% % % % % % % % % % % % % %
                            
% % % Append metadata % % %
% Add descriptions for everything
acc.desc = struct(...
   'x','Raw x-dimension accelerometer data struct (.data, .fs)',...
   'x_cal','(acc.x.data - cal.AAUX1.bias)/cal.AAUX1.sens',...
   'y','Raw y-dimension accelerometer data data struct (.data, .fs)',...
   'y_cal','(acc.y.data - cal.AAUX2.bias)/cal.AAUX2.sens',...
   'z','Raw z-dimension accelerometer data data struct (.data, .fs)',...
   'z_cal','(acc.z.data - cal.AAUX3.bias)/cal.AAUX3.sens',...
   'stim','logical indicator of when stimulation was turned on (HIGH)',...
   't','(0:(numel(acc.x.data)-1))/acc.x.fs',...
   'pct_move','See: estimatePercentMoving.m (Returns % time estimated to be moving)',...
   'cal','Approximate accelerometer calibration (exact headstages used were not recorded)',...
   'a_gravity_mag','Always = 1g after calibration',...
   'a_rest_offset_mag','median(acc.sens_mag_cal); % Approximate offset not accounted for by calibration',...
   'sens_mag','sqrt(acc.x.data.^2 + acc.y.data.^2 + acc.z.data.^2)',...
   'sens_mag_cal','sqrt(acc.x_cal.^2 + acc.y_cal.^2 + acc.z_cal.^2)',...
   'a_mag_cal','acc.sens_mag_cal./acc.a_rest_offset_mag',...
   'idx','indexing struct for each "phase"',...
   'rat','"rat" name (really the Block)',...
   'block','"full" block name',...
   'dataFile','struct with file names for raw data files',...
   'epochs','Cell array of included epoch names',...
   'epochColors','Cell array of colors for each epoch',...
   'desc','this notes struct' ...
   );

save(dataFile.out,'-struct','acc');
% % % % % % % % % % % % % %


end