function make_RMS_mask(F,varargin)
%MAKE_RMS_MASK  Create RMS "mask" in non-overlapping bins
%
%  MAKE_RMS_MASK(F);
%  --> F : File structure in `pars.FileNames('DATA_STRUCTURE')`
%  --> Uses `defs.make_RMS_mask()` to get `pars`
%
%  MAKE_RMS_MASK(F,pars);
%  --> Takes `pars` directly as an input argument
%
%  MAKE_RMS_MASK(F,'NAME',value,...);
%  --> Uses `defs.make_RMS_mask()` to get `pars`
%     --> Modifies fields of `pars` using `'NAME',value,...` syntax

if nargin < 1
   F = loadOrganizationData;
end

% Iterate on struct array F
if numel(F) > 1
   for i = 1:numel(F)
      make_RMS_mask(F(i),varargin{:});
   end
   return;
end

% Parse parameters struct
pars = parseParameters('make_RMS_mask',varargin{:});

% Skip it if whole recording is to be excluded
if ~F.included
   return;
end

block = fullfile(pars.DIR,F.name,F.base);
output = sprintf(pars.FILE,F.base);
% Check to see if RMS file exists; if it does, then skip export
if (exist(fullfile(block,output),'file')==2) && pars.SKIP_IF_FILE_PRESENT
   fprintf(1,...
      '\t->\t<strong>%s</strong>: RMS mask already exists.\n',F.base);
   fprintf(1,'\t\t->\t(skipped)\n');
   return;
end


f = dir(fullfile(block,...
   [F.base pars.INFILE_TYPE_TAG],[F.base '*' pars.OUTFILE_DELIM '*.mat']));

% Extract or load average from decimated signal
if isempty(f)
   f = dir(fullfile(F.wav.ds,[F.base '*.mat']));
   [data,fs] = extract_common_average(f,pars);
else
   fprintf(1,'\t->\tLoading <strong>CAR</strong> for %s...',...
      F.base);
   in = load(fullfile(f(1).folder,f(1).name)); 
   data = in.data;
   fs = in.fs;
   fprintf(1,'complete\n');
end

fprintf(1,'\t\t->\tExtracting <strong>RMS-MASK</strong> for %s...',F.base);

t = (0:(numel(data)-1))/fs;
pars.RMS.WLEN  = round(pars.BIN * fs);
if rem(pars.RMS.WLEN,2)==0
   pars.RMS.WLEN = pars.RMS.WLEN + 1;
end
[s,n] = SlidingPower(data,pars.RMS); % Computes RMS in sliding 1-second window

% Get amplifier sampling rate to normalize sample indices.
raw = dir(fullfile(F.wav.raw,[F.base pars.RAW_TAG]));
m = matfile(fullfile(raw(1).folder,raw(1).name));
if isprop(m,'fs')
   FS = m.fs;
else
   flag = true;
   for i = 2:numel(raw)
      m = matfile(fullfile(raw(i).folder,raw(i).name));
      if isprop(m,'fs')
         flag = false;
         FS = m.fs;
         break;
      end
   end
   
   if ~isprop(m,'fs') && flag
      in = load(fullfile(block,[F.base pars.INFO_FILE]),'frequency_pars');
      FS = in.frequency_pars.amplifier_sample_rate;
   end
end

% For spike detection, pars.ARTIFACT is a 2 x k array, where the top row is
% the sample index of artifact onset, while the bottom row corresponds to
% the end sample of the artifact.
mask = s > pars.RMS_THRESH;
% Top row is where mask goes from LOW to HIGH
onsets = find([false, diff(mask)>0]);
if isempty(onsets)
   onsets = 1;
end

% Bot row is where mask goes from HIGH to LOW
offsets = find([diff(mask)<0, false]);
if isempty(offsets)
   offsets = numel(mask);
end

% Make sure the beginning and end of each pair make sense
if onsets(1) > offsets(1)
   onsets = [1, onsets];
end
if offsets(end) < onsets(end)
   offsets = [offsets, numel(s)];
end

d_onset = 0.5 * (pars.RMS.WLEN-1)/fs;
d_offset = 0.5 * (pars.RMS.WLEN-1)/fs;
art_ts = [t(n(onsets)) - d_onset; t(n(offsets)) + d_offset];


artifact = round(art_ts .* FS); % Switch it to sample indices
artifact(artifact <= 0) = 1;
if artifact(1,1) == artifact(2,1)
   artifact(1,1) = 1;
end
nmax = size(m,'data',2);  %#ok<GTARG>
artifact(artifact > nmax) = nmax;
if artifact(1,end) == artifact(2,end)
   artifact(2,end) = nmax;
end
fprintf(1,'saving...\n');
save(fullfile(block,output),'s','n','mask','artifact','pars','-v7.3');
fprintf(1,'\b\b\b\b\b\b\b\b\b\bcomplete\n');

end