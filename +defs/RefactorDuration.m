function varargout = RefactorDuration(varargin)
%REFACTORDURATION  TDCS defaults for refactoring epoch durations for spikes
%
%  pars = defs.RefactorDuration();
%  [var1,var2,...] = defs.RefactorDuration('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
[pars.TANK,pars.FILE,pars.RAW_DIR_TAG] = defs.FileNames(...
   'DIR','RMS_MASK_FILE','RAW_DIR_TAG');
[pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS] = defs.Experiment(...
   'EPOCH_ONSETS','EPOCH_OFFSETS'); 
pars.EPOCH = 1:6;
pars.EPOCH_DURATION = (pars.EPOCH_OFFSETS - pars.EPOCH_ONSETS) .* 60;

if nargin < 1
   varargout = {pars};   
else
   F = fieldnames(pars);   
   if (nargout == 1) && (numel(varargin) > 1)
      varargout{1} = struct;
      for iV = 1:numel(varargin)
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{1}.(F{idx}) = pars.(F{idx});
         end
      end
   elseif nargout > 0
      varargout = cell(1,nargout);
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{iV} = pars.(F{idx});
         end
      end
   else
      for iV = 1:nargin
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end