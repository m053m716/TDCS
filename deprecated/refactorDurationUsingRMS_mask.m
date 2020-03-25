function S = refactorDurationUsingRMS_mask(S,varargin)
%REFACTORDURATIONUSINGRMS_MASK  Fixes duration of each epoch from mask
%
%  S = refactorDurationUsingRMS_mask(S);
%  S = refactorDurationUsingRMS_mask(S,pars);
%  S = refactorDurationUsingRMS_mask(S,'NAME',value,...);

pars = parseParameters('RefactorDuration',varargin{:});

[Block,iRat] = unique(S.Block);
Rat = S.Rat(iRat);
iStart = round(pars.EPOCH_ONSETS.*60);
iStop = round(pars.EPOCH_OFFSETS.*60);
for ii = 1:numel(Block)
   blockDir = fullfile(pars.TANK,Rat{ii},Block{ii});
   
   maskFile = fullfile(blockDir,sprintf(pars.FILE,Block{ii}));
   f = dir(fullfile(blockDir,[Block{ii} pars.RAW_DIR_TAG],...
      [Block{ii} '*Ch*.mat']));
   in = struct;
   iCur = 1;
   flag = false;
   while ~flag && (iCur <= numel(f))
      in = load(fullfile(f(iCur).folder,f(iCur).name),'fs');
      flag = isfield(in,'fs');
      iCur = iCur + 1;
   end
   if ~flag
      error('Could not find sample rate for %s',Block{ii});
   else
      fs = in.fs;
   end
%    in = load(maskFile,'artifact');
%    artifact = in.artifact;
   in = load(maskFile,'mask');
   mask = in.mask;
%    iStart = round(pars.EPOCH_ONSETS .* 60 .* fs);
%    iStop = round(pars.EPOCH_OFFSETS .* 60 .* fs);
   
   
   i_Block = strcmp(S.Block,Block{ii});
   for iEpoch = pars.EPOCH
      samples = 0;
      i_Epoch = S.Epoch == iEpoch;
      idx = i_Block & i_Epoch;
%       d = pars.EPOCH_DURATION(iEpoch);
%       epochMask = (artifact >= iStart(iEpoch)) & (artifact <= iStop(iEpoch));
%       iStandard = sum(epochMask,1) == 2;
%       samples = samples + ...
%          sum(artifact(2,iStandard) - artifact(1,iStandard));
%       
%       iFirstStop = find(epochMask(2,:),1,'first');
%       if iFirstStop < find(epochMask(1,:),1,'first')
%          samples = samples + (iFirstStop - iStart(iEpoch));
%       end
%       
%       iLastStart = find(epochMask(1,:),1,'last');
%       if iLastStart > find(epochMask(2,:),1,'last')
%          samples = samples + (iStop(iEpoch) - iLastStart);
%       end
%       S.Duration(idx) = max(d - (samples / fs),0);
      samples = ~mask(iStart(iEpoch):min(iStop(iEpoch),numel(mask)));
      if isempty(samples)
         samples = 0;
      end
      S.Duration(idx) = sum(samples);
      if all(S.Duration(idx) > 0)
         S.Rate(idx) = S.NumSpikes(idx) ./ S.Duration(idx);
      else
         S.Rate(idx) = nan;
      end
   end
end

end