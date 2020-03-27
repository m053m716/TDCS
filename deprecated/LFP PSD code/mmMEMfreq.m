function mmMEMfreq(varargin)
%% MMMEMFREQ     Calculate maximum entropy frequency spectrum estimate.
% 
%   MMMEMFREQ;
%   MMMEMFREQ(pars);
%   MMMEMFREQ('NAME',value,...);
%
%   --------
%    INPUTS
%   --------
%   varargin    :   (Optional) 'NAME', value input argument pairs.
%
%           -> 'DIR' \\ (Default: none) If not specified, will prompt for a
%                       directory containing the down-sampled LFP in
%                       single-channel format.
%
%           -> 'LEN' \\ (Default: 500 ms) Length (in milliseconds) of
%                       sliding window used to compute MEM frequency
%                       estimate.
%
%           -> 'STEP' \\ (Default: 0.8) Proportion of sliding window length
%                        That is overlapped with each consecutive step.
%
%           -> 'ORD' \\ (Default: 50) Model order to use for MEM estimate.
%
%           -> 'PK_START' \\ (Default: 2 Hz) First peak center to use.
%
%           -> 'PK_END' \\ (Default: 202 Hz) Last peak center to use.
%
%           -> 'BW' \\ (Default: 2 Hz) Width of each frequency value.
%
%           -> 'N_EVAL' \\ (Default: 10) Number of points averaged together
%                           to get the frequency estimate from each bin.
%                           E.g. with the default settings, you would be
%                           averaging frequency estimates from 0.2 Hz
%                           increments spacing to get the power estimate
%                           for each frequency bin. With the default
%                           settings, there are 101 frequency bins output.
%
%           -> 'TREND' \\ (Default: true) Removes any slow offset from the
%                          data using a spline fit.
%
%           -> 'NOISE' \\ (Default: []) Can be specified as a vector of
%                         indices for which the signal is noisy.
%
%           -> 'NOTCH' \\ (Def: []) Setting this to empty stops the
%                                notch filter. Alternatively, the desired
%                                frequency bands for the notch can be
%                                altered by changing rows of the NOTCH
%                                matrix.
%
%           -> 'HP' \\ (Def: 1 Hz) Specifies the high-pass cutoff to remove
%                       DC-biased signals from the data. Set to 0 to not
%                       perform this filter.
%   --------
%    OUTPUT
%   --------
%   Saves files in the _MEM directory of the selected block (creates it if
%   not already present). They have three variables: amp, which is a matrix
%   for a given channel where each row is the time-power values of a given
%   frequency bin and each column is the value for each each frequency bin
%   centered at the middle of the sampling window; fs, which is the
%   decimated sampling frequency; and pars, which is the structure
%   containing all the input parameters for the run.
%
% Adapted by: Max Murphy    v2.0    08/15/2017 (Matlab R2017a)
%   Original: David Bundy   v1.0    ??/??/????
%
%   See also: MMDS, QDS, QMMMEMFREQ

%% DEFAULTS
pars = struct;

% MEM estimate parameters
pars.LEN = 500;         % milliseconds
pars.STEP = 0.8;        % proportion overlapping
pars.ORD = 50;          % MEM model order
pars.PK_START = 2;      % (Hz; starting frequency bin)
pars.PK_END = 202;      % (Hz; ending frequency bin)
pars.BW = 2;            % (Hz, frequency bin bandwidth)
pars.N_EVAL = 10;       % # frequency points averaged per bin
pars.TREND = true;      % true: remove spline trend from data

% Filtering parameters
pars.NOISE = [];        % indexes of "noisy" periods to remove
pars.NOTCH = [];        % k x 2 matrix; each row is the start and stop frequency cutoffs for notch filter
pars.HP = 1;            % (Hz) high-pass cutoff frequency
pars.LP = 300;          % (Hz) low-pass cutoff frequency
pars.MAX_FS_LP = 600;   % Lowpass anything above this frequency
pars.CHEBY_ORD = 4;     % chebyshev filter older
pars.RP = 0.05;         % passband ripple
pars.RE_REF = 'none';   % Options: {'car'/'none'/[(scalar CH #)]}
                        % Note: if set to a scalar CH #, must be the
                        % relative channel number for that probe (i.e. if
                        % the channel number starts with 0 in the file name
                        % convention, that is channel 1)

% File info
pars.DEF_DIR = 'P:/Rat';
pars.IN_ID = 'DS';
pars.DELIM = '_';
pars.OUT_ID = 'MEM';
pars.PROBE_IND = 2;     % Number of '_' delimited indexes back from end

%% PARSE VARARGIN
if nargin == 1
    pars = varargin{1};
else
    for iV = 1:2:numel(varargin)
        pars.(upper(varargin{iV})) = varargin{iV+1};
    end
end

%% GET DIRECTORY
if ~isfield(pars,'DIR')
    pars.DIR = uigetdir(pars.DEF_DIR,'Select recording BLOCK');
    if pars.DIR==0
        error('No block selected. Script aborted.');
    end
end

%% GET FILE NAME INFO
base = strsplit(pars.DIR,filesep);
base = base{end};
finfo = strsplit(base,pars.DELIM);

indir = fullfile(pars.DIR,[base pars.DELIM pars.IN_ID]);
outdir = strrep(indir,pars.IN_ID,pars.OUT_ID);
F = dir(fullfile(indir,['*' pars.IN_ID '*.mat']));

% Get # probes
pnum = 1;
for iF = 1:numel(F)
    splitname = strsplit(F(iF).name,pars.DELIM);
    if strcmp(splitname{end-pars.PROBE_IND}(1),'P')
        pnum = max(pnum,str2double(splitname{end-pars.PROBE_IND}(2:end)));
    else
        error('Incorrect probe # index. Check pars.PROBE_IND.');
    end
end



%% LOAD DATA
fprintf(1,'\nLoading DS data for %s', finfo{1});
iP = zeros(1,pnum);
Data = cell(1,pnum);
FileName = cell(1,pnum);

for iF = 1:numel(F)
    fprintf(1,'. ');
    % Load
    load(fullfile(indir,F(iF).name),'data','fs');
    splitname = strsplit(F(iF).name,pars.DELIM);
    p = str2double(splitname{end-pars.PROBE_IND}(2:end));
    iP(p) = iP(p) + 1;
    
    % De-noise and filter
    Data{p}{iP(p),1} = mmDN_FILT(data,fs,pars);
    FileName{p}{iP(p),1} = F(iF).name;
end
fprintf(1,'complete.\n');

%% CONSOLIDATE TO MATRICES
for iP = 1:pnum
    Data{iP} = cell2mat(Data{iP});
end

%% DO RE-REFERENCING
fprintf(1,'Doing referencing...');
ref = str2double(pars.RE_REF);
if isnan(ref)
    if strcmpi(pars.RE_REF,'car') % Common average re-reference
        for iP = 1:pnum
            re_ref = mean(Data{iP},1);
            Data{iP}=Data{iP}-repmat(re_ref,size(Data{iP},1),1);
        end
        refTxt='_CAR';
    elseif strcmpi(pars.RE_REF,'none') % No re-reference
        refTxt = '_NoREF';
    end
else
    for iP = 1:pnum % Single-channel re-reference
        re_ref = Data{iP}(ref,:);
        Data{iP}=Data{iP}-repmat(re_ref,size(Data{iP},1),1);
    end
    refTxt=sprintf('_REF%03d',ref);
end

% Ensure correct orientation
for iP = 1:pnum
    Data{iP} = Data{iP}.';
end
fprintf(1,'complete.\n');

%% PRE-ALLOCATE
fprintf(1,'Allocating matrices for frequency bins...');
pars.NSAMP_WIN=round(pars.LEN*1e-3*fs);
pars.NSAMP_STEP=round(pars.NSAMP_WIN*(1-pars.STEP));
pars.NUM_WIN=floor((size(Data{1},1)-pars.NSAMP_WIN)/pars.NSAMP_STEP);
pars.NSAMP_PER_WIN=zeros(1,pars.NUM_WIN);

% Make params structure for mex file
params=[pars.ORD,...    
        pars.PK_START,...
        pars.PK_END, ...
        pars.BW, ...
        pars.N_EVAL,...
        pars.TREND,...
        fs];

[~,pars.FREQS]=mem(Data{1}(1:1+pars.NSAMP_WIN,:),params);
fprintf(1,'complete.\n');

%% COMPUTE MEM AND SAVE
for iP = 1:pnum
Amp=zeros(size(Data{iP},2),numel(pars.FREQS),pars.NUM_WIN);

    for ii=1:pars.NUM_WIN
        if rem(ii,5000)==0
            fprintf(1,['->\tComputing MEM spectral estimate:' ...
                       ' window %d of %d. (Probe %d of %d)\n'],...
                       ii,pars.NUM_WIN,iP,pnum);
        end
        xStart=1+(ii-1)*pars.NSAMP_STEP;
        xEnd=xStart+pars.NSAMP_WIN-1;
        [tempAmp,~]=mem(Data{iP}(xStart:xEnd,:),params); 
        Amp(:,:,ii)=tempAmp.';
        pars.NSAMP_PER_WIN(ii)=round(xStart+pars.NSAMP_WIN/2);
        
    end
    
    if exist(outdir,'dir')==0
        mkdir(outdir);
    end
    
    fprintf(1,'Saving MEM spectral estimates (Probe %d of %d)',iP,pnum);
    for iCh = 1:size(Data{iP},2)
        fprintf(1,'. ');
        fname = strrep(FileName{iP}{iCh,1},pars.IN_ID,...
                        [pars.OUT_ID refTxt]);      
        amp = squeeze(Amp(iCh,:,:));
        save(fullfile(outdir,fname),'amp','fs','pars');
    end
    fprintf(1,'complete.\n');
end

beep;

end