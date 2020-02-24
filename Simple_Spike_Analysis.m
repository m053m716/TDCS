function [D,SPK] = Simple_Spike_Analysis(varargin)
%SIMPLE_SPIKE_ANALYSIS   First step for after SORTCLUSTERS
%
%   [D,SPK] = SIMPLE_SPIKE_ANALYSIS('NAME',value,...)
%
%   --------
%    INPUTS
%   --------
%     'pars.DIR'     :   [Default: specified in directory selection UI]
%                   Can be specified as a path to either the main folder
%                   for a given rat, or a sub-folder for a specific
%                   recording (block) to extract only that block's info.
%
%     Otherwise :
%
%     Any 'NAME', value pair to specify a variable listed in the DEFAULTS
%     section.
%
%       'RAT_END'   :   Stop index of Rat name in block filename
%                       (default: 6; set to 5 for tDCS analysis!)
%
%     -> OTHER SPECIAL CASES <-
%
%       SPECIFYING EITHER OF THE FOLLOWING REMOVES 'SNIPS' FIELD:
%
%       'ISTART'    :   Start index (default: 1)
%
%       'ISTOP'     :   Stop index (default: number of samples in record)
%
%       'INSERT_TAG':   Must be specified together with SAVE_DIR. Specifies
%                       name to insert in front of SAVE_ID for output file.
%
%       'SAVE_DIR':     Must be specified together with INSERT_TAG.
%                       Specifies base directory where the output file will
%                       be saved.
%
%   --------
%    OUTPUT
%   --------
%       D       :      Matlab table with C rows, where C is the total
%                      number of clusters identified.
%                       - Rat
%                       - Block
%                       - Channel
%                       - Cluster
%                       - NumSpikes
%                       - Duration
%                       - Rate
%                       - Regularity
%
%
%       SPK     :       Matlab table with C rows, where C is the total
%                       number of clusters identified.
%                       - Peaks
%                       - Snips
%                       - fs

% DEFAULT CONSTANTS
switch nargin
   case 0
      pars = defs.Simple_Spike_Analysis();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.Simple_Spike_Analysis();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end
% Add any new paths
addpath(genpath(pars.LIB_DIR));
warning('off',pars.W_ID);

% This tries to help in case of weird mapping names
if exist(pars.DEF_DIR,'dir')==0
   pars.DEF_DIR = 'T:';
end

% Check for ISTART and ISTOP, if nonexistant then use whole recording
if isempty(pars.ISTART)
   startflag = true;
   pars.ISTART = 1;
   pars.START_STR = '0000';
else
   startflag = false;
   pars.START_STR = num2str(round(pars.ISTART/pars.FS/60),'%04d');
end

if isempty(pars.ISTOP)
   stopflag = true;
   pars.STOP_STR = 'stop';
else
   stopflag = false;
   pars.STOP_STR = num2str(round(pars.ISTOP/pars.FS/60),'%04d');
end

% GET DIRECTORY IF NOT SPECIFIED
if isempty(pars.DIR)
   pars.DIR = uigetdir(pars.DEF_DIR,'Select animal or recording');
   if pars.DIR==0
      error('No directory specified.');
   end
end

% GET NAME OF RAT
listing = dir(pars.DIR);
temp = {listing.name}.';
for ii = 1:numel(temp)
   temp{ii} = strsplit(temp{ii},'_');
   temp{ii} = temp{ii}{end};
end

% Checks presence of RawData folder to determine whether or not this is the
% "Main Block" for a given animal, or a "Sub Block," which would only
% contain a single recording.
if ismember('RawData',temp)
   temp = strsplit(pars.DIR,filesep);
   bk = temp(end);
   pars.DIR = strjoin(temp(1:end-1),filesep);
   temp = temp{end-1};
   rat = temp;
elseif strcmp(pars.DIR(end-3:end),SUB_DIR)
   temp = strsplit(pars.DIR,filesep);
   pars.DIR  = strjoin(temp(1:end-2),filesep);
   temp = temp{end-1};
   rat  = temp(pars.RAT_START:pars.RAT_END);
   bk   = {temp};
elseif ismember(SUB_DIR,temp)
   temp = strsplit(pars.DIR,filesep);
   pars.DIR  = strjoin(temp(1:end-1),filesep);
   temp = temp{end};
   rat  = temp(pars.RAT_START:pars.RAT_END);
   bk   = {temp};
else
   temp = strsplit(pars.DIR,filesep);
   temp = temp{end};
   rat  = temp;
   listing = dir([pars.DIR filesep rat '*']);
   bk   = {listing.name}.';
end

% GO THROUGH EACH BLOCK AND PERFORM BASIC DATA ORGANIZATION
% Initialize
Rat = [];           tempRat = [];
Block = [];         tempBlock = [];
Channel = [];       tempChannel = [];
Cluster = [];       tempCluster = [];
NumSpikes = [];     tempNumSpikes = [];
Duration = [];      tempDuration = [];
Rate = [];          tempRate = [];
Regularity = [];    tempRegularity = [];

Peaks = [];         tempPeaks = [];
Snips = [];         tempSnips = [];
fs = [];            tempfs = [];

for iB = 1:numel(bk)
   % Get all files from "Good" directory
   if pars.USE_SPK_SUB_DIR
      bDIR = [pars.DIR filesep bk{iB} filesep bk{iB} pars.SPK_DIR ...
         filesep pars.SUB_DIR filesep];
      if exist(bDIR,'dir')==0
         bDIR = [pars.DIR filesep bk{iB} filesep bk{iB} pars.CAR_SPK_DIR ...
            filesep];
      end
      
      if exist(bDIR,'dir')==0
         bDIR = [pars.DIR filesep bk{iB} filesep pars.SUB_DIR filesep];
      end
   else
      bDIR = [pars.DIR filesep bk{iB} filesep bk{iB} pars.SPK_DIR ...
         filesep];
      if exist(bDIR,'dir')==0
         bDIR = [pars.DIR filesep bk{iB} filesep bk{iB} pars.CAR_SPK_DIR ...
            filesep];
      end
      
      if exist(bDIR,'dir')==0
         bDIR = [pars.DIR filesep bk{iB} filesep];
      end
   end
   
   listing = dir([bDIR rat '*']);
   if pars.SHOW_PROGRESS
      h = waitbar(0,['Please wait, extracting spike info for ' ...
         strrep(bk{iB}, '_', '\_')]);
   end
   nL = numel(listing);
   for iL = 1:nL
      spk = load([bDIR listing(iL).name],'peak_train','spikes','pars');
      if stopflag
         pars.ISTOP = numel(spk.peak_train);
      end
      if (startflag && stopflag)
         ptrain = spk.peak_train;
      else
         if pars.ISTOP > numel(spk.peak_train)
            continue
         else
            ptrain = spk.peak_train(pars.ISTART:pars.ISTOP);
         end
      end
      
      if isfield(spk,'pars')
         fs = [fs; spk.pars.FS];
         dur = (pars.ISTOP - pars.ISTART + 1)./spk.pars.FS;
         t = find(ptrain)./spk.pars.FS;
      else
         fs = [fs; pars.FS];
         dur = (pars.ISTOP - pars.ISTART + 1)./pars.FS;
         t = find(ptrain)./pars.FS;
      end
      
      Peaks = [Peaks; {ptrain}];
      if (startflag && stopflag)
         Snips = [Snips; {spk.spikes}];
      else
         Snips = [Snips; nan];
      end
      
      ch = str2double(listing(iL).name((end-8):(end-6)));
      if isnan(ch)
         ch = str2double(listing(iL).name((end-7):(end-6)));
      end
      cl = str2double(listing(iL).name(end-4));
      
      n = numel(t);
      rt = n./dur;
      lvr = LvR(t);
      
      
      Rat = [Rat; {rat}];
      Block = [Block; bk{iB}];
      Channel = [Channel; ch];
      Cluster = [Cluster; cl];
      NumSpikes = [NumSpikes; n];
      Duration = [Duration; dur];
      Rate = [Rate; rt];
      Regularity = [Regularity; lvr];
      if pars.SHOW_PROGRESS
         waitbar(iL/nL);
      end
   end
   if pars.SHOW_PROGRESS
      delete(h);
   end
   
   % Spike data
   SPK = table(Peaks,Snips,fs);
   SPK.Properties.Description = pars.DATASET_DESCRIPTION_SPK;
   SPK.Properties.VariableUnits = pars.VAR_UNITS_SPK;
   SPK.Properties.VariableDescriptions = pars.VAR_DESCRIPTIONS_SPK;
   
   tempPeaks = [tempPeaks; Peaks]; Peaks = [];
   tempSnips = [tempSnips; Snips]; Snips = [];
   tempfs = [tempfs; fs];          fs = [];
   
   % General data
   D = table(Rat,Block,Channel,Cluster,NumSpikes,Duration,Rate,Regularity);
   D.Properties.Description = pars.DATASET_DESCRIPTION_DATA;
   D.Properties.VariableUnits = pars.VAR_UNITS_DATA;
   D.Properties.VariableDescriptions = pars.VAR_DESCRIPTIONS_DATA;
   
   tempRat = [tempRat; Rat]; Rat = [];
   tempBlock = [tempBlock; Block]; Block = [];
   tempChannel = [tempChannel; Channel]; Channel = [];
   tempCluster = [tempCluster; Cluster]; Cluster = [];
   tempNumSpikes = [tempNumSpikes; NumSpikes]; NumSpikes = [];
   tempDuration = [tempDuration; Duration]; Duration = [];
   tempRate = [tempRate; Rate]; Rate = [];
   tempRegularity = [tempRegularity; Regularity]; Regularity = [];
   
   if pars.USE_START_STOP
      if isempty(pars.SAVE_DIR) || isempty(pars.INSERT_TAG)
         save(fullfile(pars.DIR,bk{iB},[bk{iB} '_' pars.START_STR '_' pars.STOP_STR ...
            pars.SAVE_ID]),'D','SPK','-v7.3');
      else
         save(fullfile(pars.SAVE_DIR,[pars.INSERT_TAG '_' pars.START_STR '_' pars.STOP_STR ...
            pars.SAVE_ID]),'D','SPK','-v7.3');
      end
   else
      if isempty(pars.SAVE_DIR) || isempty(pars.INSERT_TAG)
         save(fullfile(pars.DIR,bk{iB},[bk{iB} pars.SAVE_ID]),'D','SPK','-v7.3');
      else
         save(fullfile(pars.SAVE_DIR,[pars.INSERT_TAG pars.SAVE_ID]),'D','SPK','-v7.3');
      end
   end
   
end
warning('on',pars.W_ID);

% MAKE AGGREGATE OUTPUT DATA TABLES
Peaks = tempPeaks;
Snips = tempSnips;
fs = tempfs;
Rat = tempRat;
Block = tempBlock;
Channel = tempChannel;
Cluster = tempCluster;
NumSpikes = tempNumSpikes;
Duration = tempDuration;
Rate = tempRate;
Regularity = tempRegularity;

% Spike data
SPK = table(Peaks,Snips,fs);
SPK.Properties.Description = pars.DATASET_DESCRIPTION_SPK;
SPK.Properties.VariableUnits = pars.VAR_UNITS_SPK;
SPK.Properties.VariableDescriptions = pars.VAR_DESCRIPTIONS_SPK;

% General data
D = table(Rat,Block,Channel,Cluster,NumSpikes,Duration,Rate,Regularity);
D.Properties.Description = pars.DATASET_DESCRIPTION_DATA;
D.Properties.VariableUnits = pars.VAR_UNITS_DATA;
D.Properties.VariableDescriptions = pars.VAR_DESCRIPTIONS_DATA;


end
