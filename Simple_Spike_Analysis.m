function [D,SPK] = Simple_Spike_Analysis(F,varargin)
%SIMPLE_SPIKE_ANALYSIS   First step for after SORTCLUSTERS
%
%  [D,SPK] = SIMPLE_SPIKE_ANALYSIS(F,'NAME',value,...)
%
%  Example simple analysis for entire recordings:
%  >> [F,pars] = loadOrganizationData();
%  >> [D,SPK] = Simple_Spike_Analysis(F);
%
%  Example batch analysis for multiple epochs within recordings:
%  >> [F,pars] = loadOrganizationData();
%  >> [tStart,tStop] = defs.EpochLabels('EPOCH_ONSETS','EPOCH_OFFSETS');
%  >> e = defs.EpochLabels('EPOCH_NAMES');
%  >> D = struct; SPK = struct;
%  >> for iEpoch = 1:numel(tStart)
%  >>    [D.(e{iEpoch}),SPK.(e{iEpoch})] = Simple_Spike_Analysis(F, ...
%  >>       'TSTART',tStart,'TSTOP',tStop);
%  >> end
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
%       'TSTART'    :   Start time (minutes)
%
%       'ISTOP'     :   Stop index (default: number of samples in record)
%
%       'TSTOP'     :   Stop time (minutes)
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


if numel(F) > 1
   if nargout > 0
      D = [];
      SPK = [];
   end
   for i = 1:numel(F)
      if nargout > 0
         [tmpD,tmpSPK] = Simple_Spike_Analysis(F(i),varargin{:});
         D = [D; tmpD]; %#ok<AGROW>
         SPK = [SPK; tmpSPK]; %#ok<AGROW>
      else
         Simple_Spike_Analysis(F(i),varargin{:});
      end
   end
   return;
end

% Get default parameters
pars = parseParameters('Simple_Spike_Analysis',varargin{:});

% Add any new paths
addpath(genpath(pars.LIB_DIR));
warning('off',pars.W_ID);

% Check for ISTART and ISTOP, if nonexistant then use whole recording
if isempty(pars.ISTART)
   iStart = [];
else
   iStart = pars.ISTART;
end

if isempty(pars.ISTOP)
   iStop = [];
else
   iStop = pars.ISTOP;
end

rat = F.name;
bk = F.base;

% Get all files from "Good" directory
if ~isempty(pars.SUB_DIR)
   bDIR = fullfile(F.block,[bk pars.SPK_DIR],pars.SUB_DIR);
else
   bDIR = fullfile(F.block,[bk pars.SPK_DIR]);
end

spikeFiles = dir(fullfile(bDIR,[rat '*']));

% For "D" output
nFiles = numel(spikeFiles);
Rat = repmat({rat},nFiles,1);
Block = repmat({bk},nFiles,1);
Channel = nan(nFiles,1);   
% Cluster = nan(nFiles,1);
Cluster = ones(nFiles,1);
NumSpikes = nan(nFiles,1);     
Duration = nan(nFiles,1);   
Rate = nan(nFiles,1);   
Regularity = nan(nFiles,1);   

% For "SPK" output
fs = nan(nFiles,1);
Peaks = cell(nFiles,1);  
Snips = cell(nFiles,1); 
keepVec = true(nFiles,1);

% Actual time labels parsed from indexing so leave blank for now
tStart = [];
tStop = [];

fprintf(1,'<strong>[SIMPLE_SPIKE_ANALYSIS]</strong>::%s...000%%\n',bk);
for ii = 1:nFiles
   spk = load(fullfile(bDIR,spikeFiles(ii).name));
   
   if isfield(spk,'pars')
      fs(ii) = spk.pars.FS;
   elseif isfield(spk,'fs')
      fs(ii) = spk.fs;
   elseif isfield(spk,'FS')
      fs(ii) = spk.FS;
   else
      error(['SpikeAnalysis:' mfilename ':MissingData'],...
         ['\n\t\t->\t<strong>[SIMPLE_SPIKE_ANALYSIS]</strong>::%s: ' ...
         'No sample rate saved in _Spikes file.\n'],bk);
   end
   
   if isempty(iStart)
      if isempty(pars.TSTART)
         iStart = 1;
      else
         iStart = max(round(pars.TSTART*60*fs(ii)),1);
      end
   end
   if isempty(tStart)
      tStart = round(iStart/fs(ii)/60);
   end
   
   if isempty(iStop)
      if isempty(pars.TSTOP)
         iStop = numel(spk.peak_train);
      else
         iStop = min(round(pars.TSTOP*60*fs(ii)),numel(spk.peak_train));
      end
   end   
   if isempty(tStop)
      tStop = round(iStop/fs(ii)/60);
      fprintf(1,'\b\b\b\b\b\n\t->\t<strong>[EPOCH]:</strong> '); 
      fprintf(1,'%g-minutes||%g-minutes:%03g%%\n',...
            tStart,tStop,round((ii-1)/nFiles*100));
   end
   vec = iStart:iStop;

   if numel(vec) == 0
      keepVec(ii) = false;
      fprintf(1,'\t\t->\t%s too few samples (<strong>skipped</strong>)\n',spikeFiles(ii).name);
      fprintf(1,'<strong>[SIMPLE_SPIKE_ANALYSIS]</strong>::%s...%03g%%\n',...
         bk,round(ii/nFiles*100));
      continue
   elseif iStop > numel(spk.peak_train)
      keepVec(ii) = false;
      fprintf(1,'\t\t->\t%s too few samples (<strong>skipped</strong>)\n',spikeFiles(ii).name);
      fprintf(1,'<strong>[SIMPLE_SPIKE_ANALYSIS]</strong>::%s...%03g%%\n',...
         bk,round(ii/nFiles*100));
      continue
   end
   
   ptrain = spk.peak_train(vec);
   dur = (iStop - iStart + 1)./fs(ii);
   tPeak = find(ptrain)./fs(ii);
   
   Peaks{ii} = ptrain;
   if pars.SAVE_SNIPS
      Snips{ii} = spk.spikes; 
   end
   
   [~,strInfo,~] = fileparts(spikeFiles(ii).name);
   strInfo = strsplit(strInfo,'_');
   iCh = find(strcmp(strInfo,'Ch'),1,'first')+1;
   
   ch = str2double(strInfo{iCh});
%    cl = str2double(spikeFiles(ii).name(end-4));
   
   n = numel(tPeak);
   rt = n./dur;
   lvr = LvR(tPeak);
   
   Channel(ii) = ch;
%    Cluster(ii) = cl;
   NumSpikes(ii) = n;
   Duration(ii) = dur;
   Rate(ii) = rt;
   Regularity(ii) = lvr;
   fprintf(1,'\b\b\b\b\b%03g%%\n',round(ii/nFiles*100));
end

% Spike data
SPK = table(Peaks,Snips,fs);
SPK.Properties.Description = pars.DATASET_DESCRIPTION_SPK;
SPK.Properties.VariableUnits = pars.VAR_UNITS_SPK;
SPK.Properties.VariableDescriptions = pars.VAR_DESCRIPTIONS_SPK;
SPK(~keepVec,:) = []; % Remove invalid entries

% Make sure data is valid
fs_tmp = mode(SPK.fs);
if any(fs~=fs_tmp)
   error(['SpikeAnalysis:' mfilename ':BadData'],...
      ['\n\t\t->\t<strong>[SIMPLE_SPIKE_ANALYSIS]</strong>::%s: ' ...
      'Different sample rates detected for same Block.\n'],bk);
end

% Strings convert stop times to minutes
epochString = sprintf('%04d_%04d',tStart,tStop);

% General data
D = table(Rat,Block,Channel,Cluster,NumSpikes,Duration,Rate,Regularity);
D.Properties.Description = pars.DATASET_DESCRIPTION_DATA;
D.Properties.VariableUnits = pars.VAR_UNITS_DATA;
D.Properties.VariableDescriptions = pars.VAR_DESCRIPTIONS_DATA;
D(~keepVec,:) = []; % Remove invalid entries

% Get save path info
if isempty(pars.SAVE_DIR)
   pname = F.block;
else
   pname = pars.SAVE_DIR;
end

if isempty(pars.INSERT_TAG)
   tag = bk;
else
   tag = pars.INSERT_TAG;
end
fname = sprintf('%s_%s%s',tag,epochString,pars.SAVE_ID);
save(fullfile(pname,fname),'D','SPK','pars','-v7.3');

warning('on',pars.W_ID);

end
