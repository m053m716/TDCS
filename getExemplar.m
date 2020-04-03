function [raw,filt,sneo,spike,ch,fig] = getExemplar(E,F,iBlock,iCh,nSamples,tag)
%GETEXEMPLAR  Return exemplar data
%
%  [raw,filt,sneo,spike] = getExemplar();
%   --> Uses defaults for all input arguments
%
%  [raw,filt,sneo,spike] = getExemplar(E,F);
%  -- Inputs --
%   -> E : Table with STIM epoch start/stop data
%   -> F : Organization data struct array
%
%  -- Output --
%   -> raw : `raw` signal data struct for exemplar epoch ('data','t','fs')
%   -> filt : same as `raw` but with bandpass filter & re-reference applied
%   -> sneo : Struct with SNEO signal used for spike detection, from `filt`
%   -> spike: Struct with spike data
%
%     + Each struct is an array with two elements:
%        (1) == Alignment at START of STIM epoch
%        (2) == Alignment at END  of STIM epoch
%        -> For any figures, these correspond to LEFT and RIGHT subset of
%           figure panels.
%
%  [raw,filt,sneo,spike] = getExemplar(E,F,iBlock);
%  --> Default `iBlock` is 10 (TDCS-28)
%
%  [raw,filt,sneo,spike] = getExemplar(E,F,iBlock,iCh,nSamples);
%  --> Default `iCh` is 1 [NOTE: This indexes files, not channels]
%  --> Default `nSamples` is 1000 (-1000 : +1000)
%
%  getExemplar(__,tag)
%  --> tag : char array to append to filename
%   -> If no output is requested, then the figure is automatically saved
%        and exported as a vector graphics file and .png in the location
%        specified by:
%        `defs.Get_Exemplar` --> `defs.FileNames('OUTPUT_FIG_DIR')`
%
%  [raw,filt,sneo,spike,ch,fig] = getExemplar(__);
%  --> ch  : Return char array corresponding to channel number of file
%  --> fig : Return handle to figure
%   -> Figure is not automatically saved/deleted on return
% Load default parameters
pars = defs.Get_Exemplar();

% Parse based on different numbers of input arguments
narg = nargin;
switch nargin   
   case 0
      narg = 0;  
      tag = pars.TAG;
   case 1
      if ischar(E)
         narg = narg - 1;
         tag = E;
      else
         tag = pars.TAG;
      end
   case 2
      if ischar(F)
         narg = narg - 1;
         tag = F;
      else
         tag = pars.TAG;
      end
   case 3
      if ischar(iBlock)
         test = convertName2Block(iBlock);
         if ~isnan(test)
            iBlock = find(E.BlockID == test,1,'first');
            tag = pars.TAG;
         else
            tag = iBlock;
            narg = narg - 1;
         end
      else
         tag = pars.TAG;
      end
   case 4
      if ischar(iCh)
         if ~isnan(str2double(iCh))
            iCh = str2double(iCh);
            tag = pars.TAG;
         else
            tag = iCh;
            narg = narg - 1;
         end
      else
         tag = pars.TAG;
      end      
   case 5
      if ischar(nSamples)
         tag = nSamples;
         narg = narg - 1;
      else
         tag = pars.TAG;
      end
   case 6 % Do nothing
      % continue
   otherwise
      error(['tDCS:' mfilename ':TooManyInputs'],...
         ['\n\t->\t<strong>[TDCS.GETEXEMPLAR]:</strong> ' ...
          'Too many input arguments\n']);
end
if narg < 5
   nSamples = pars.NSAMPLES; % Default 1000 samples --> 2001 points
end
if narg < 4
   iCh = pars.CHANNEL_INDEX; % Default 'Channel-008' (first channels file)
end
if narg < 3
   iBlock = pars.BLOCK_INDEX; % Default (TDCS-28)
end
if narg < 2
   if narg < 1
      [F,~,E] = loadOrganizationData();
   else
      F = loadOrganizationData();
   end
end

% Get alignment times (seconds)
tAlign = [E.tStart(iBlock),E.tStop(iBlock)] .* 60;  % Convert to seconds

% Get file/path info
b = F(iBlock).base;
spikeDir = fullfile(F(iBlock).block,[b '_wav-sneo_CAR_Spikes']);
rawF = dir(fullfile(F(iBlock).wav.raw,[b '*Ch*.mat']));
filtF = dir(fullfile(F(iBlock).wav.filt,[b '*Ch*.mat']));
spikeF = dir(fullfile(spikeDir,[b '*Ch*.mat']));
[~,f,~] = fileparts(rawF(iCh).name);
nameInfo = strsplit(f,'_');
ch = nameInfo{end};
blockName = nameInfo{1};
figName = sprintf('%s - Ch-%s Exemplar Data%s',blockName,ch,tag);

% Load input data struct
in = struct;
in.raw = load(fullfile(rawF(iCh).folder,rawF(iCh).name),'data','fs');
in.t = (0:(numel(in.raw.data)-1))/in.raw.fs; % Time in seconds
in.filt = load(fullfile(filtF(iCh).folder,filtF(iCh).name),'data','fs');
in.spike = load(fullfile(spikeF(iCh).folder,spikeF(iCh).name),'pars');

k = round(pars.SAMPLE_WEIGHTS .* nSamples);
[raw,filt,sneo,spike] = extractTimeChunks(in,tAlign,k(:,1),k(:,2));

if (nargout > 5) || (nargout < 1)
   iThis = mapCondition(F(iBlock).conditionID);
   fig = genExemplarPanels(figName,raw,filt,sneo,spike,iThis);
   if (nargout < 1)
      outdir = fullfile(pars.OUTPUT_DIR,pars.OUTPUT_SUB_DIR);
      batchHandleFigure(fig,outdir,figName);
   end
end

   function [raw,filt,sneo,spike] = extractTimeChunks(in,tAlign,nPre,nPost)
      [raw,filt,sneo,spike] = initOutputStructArray(numel(tAlign));
      if numel(tAlign) > 1
         for i = 1:numel(tAlign)
            [raw(i),filt(i),sneo(i),spike(i)] = ...
               extractTimeChunks(in,tAlign(i),nPre(i),nPost(i));
         end
         return;
      end
      iAlign  = round(tAlign * in.raw.fs);
      N = numel(in.raw.data);
      vec = max(1,iAlign-nPre) : min(N,iAlign+nPost);

      % Reduce the total number of samples needed for spike detection
      nBuffSamplesPre = round(1.1*nPre);
      nBuffSamplesPost = round(1.1*nPost);
      bvec = max(1,iAlign-nBuffSamplesPre):min(N,iAlign+nBuffSamplesPost);
      
      % Create output structs
      raw.data = in.raw.data(vec);
      raw.t = in.t(vec);
      raw.fs = in.raw.fs;
      p = nPre / (nPost + nPre);
      T = raw.t(end) - raw.t(1);
      dt = [(p-0.1)*T, (p+0.1)*T] + raw.t(1);
      
      % Parse data for `raw` epoc struct
      raw.epoc.t(1,2:5) = [raw.t(1), dt raw.t(end)];
      if nPre < nPost
         raw.epoc.Y(:,2:5) = getCurrentAmplitudes('Pre');
      else
         raw.epoc.Y(:,2:5) = getCurrentAmplitudes('Post');
      end
      raw.epoc.ticks = dt;                                    % To superimpose
      raw.epoc.ticklabels = [(tAlign-30)/60,(tAlign+30)/60];  % Different timescales  
      
      % Parse data for `filt` struct
      filt.data = in.filt.data(vec);
      filt.t = in.t(vec);
      filt.fs = in.filt.fs;
      sneo.t = in.t(vec);
      sneo.fs = in.filt.fs;
      spike.pars = in.spike.pars; 
      
      [~,spike.peakIndices,spike.peakValues,~,~,sneo.data,thresh] = ...
         eqn.SNEO_Threshold(in.filt.data(bvec),spike.pars,[]);
      
      % Fix apparent time offset from shortened vector
      spike.peakIndices = spike.peakIndices + bvec(1) - 1;
      spike.peakTimes = spike.peakIndices ./ in.filt.fs;

      % Select matched subset from SNEO stream
      sneo_idx = ismember(bvec,vec);
      sneo.data = sneo.data(sneo_idx); 
      sneo.threshold = thresh.sneo;

      % Get reduced subset of spike based on spikes within the focused window
      spike_index = (spike.peakIndices >= vec(1)) & ...
                    (spike.peakIndices <= vec(end));
      spike.peakIndices = spike.peakIndices(spike_index);
      spike.peakTimes = spike.peakTimes(spike_index);
      spike.peakValues = spike.peakValues(spike_index);
      spike.threshold = thresh.data;
      
   end

   function A = getCurrentAmplitudes(epochName)
      %GETCURRENTAMPLITUDES  Return matrix of current amplitudes
      %
      %  A = getCurrentAmplitudes(epochName);
      %
      %  epochName : 'Pre' or 'Post'
      
      switch lower(epochName)
         case 'pre'
            A = [...
                0.0  0.0  0.4  0.4; ...
                0.0  0.0  0.2  0.2; ...
                0.0  0.0  0.0  0.0; ...
                0.0  0.0 -0.2 -0.2; ...
                0.0  0.0 -0.4 -0.4  ...
            ];
         case 'post'
            A = [...
                 0.4  0.4 0.0  0.0; ...
                 0.2  0.2 0.0  0.0; ...
                 0.0  0.0 0.0  0.0; ...
                -0.2 -0.2 0.0  0.0; ...
                -0.4 -0.4 0.0  0.0 ...
            ];
         otherwise
            error('Invalid epochName');
      end
   end

   function [raw,filt,sneo,spike] = initOutputStructArray(n)
      %INITOUTPUTSTRUCTARRAY  Initialize output data struct arrays
      %
      %  [raw,filt,sneo,spike] = initOutputStructArray();
      %  --> Initialize scalar struct with correct fields for each output
      %
      %  [raw,filt,sneo,spike] = initOutputStructArray(n);
      %  --> Initialize array with n elements for each output
      
      if nargin < 1
         n = 1;
      end
      raw = struct('data',[],'t',[],'fs',[],...
         'epoc',struct('t',nan(1,6),'Y',nan(5,6),...
         'ticks',nan(1,2),'ticklabels',nan(1,2)));
      raw = repmat(raw,n,1);
      filt = struct('data',[],'t',[],'fs',[]);
      filt = repmat(filt,n,1);
      sneo = struct('data',[],'t',[],'fs',[],'threshold',[]); 
      sneo = repmat(sneo,n,1);
      spike = struct('peakIndices',[],'peakTimes',[],'peakValues',[],'threshold',[],'pars',struct);  
      spike = repmat(spike,n,1);
   end

   function iThis = mapCondition(conditionID)
      %MAPCONDITION  Returns integer [1 - 5] indicating mapping from ID
      %
      %  iThis = mapCondition(conditionID);
      
      switch conditionID
         case 1
            iThis = 3;
         case 2
            iThis = 3;
         case 3
            iThis = 4;
         case 4
            iThis = 2;
         case 5
            iThis = 5;
         case 6
            iThis = 1;
         otherwise
            error('Bad conditionID: %g',conditionID);
      end
   end

end