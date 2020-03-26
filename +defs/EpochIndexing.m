function varargout = EpochIndexing(varargin)
%EPOCHINDEXING  Defaults for getting epoch sample indices
%
%  pars = defs.EpochIndexing();
%  [var1,var2,...] = defs.EpochIndexing('var1Name','var2Name',...);

pars = struct;
[pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS,pars.DS_BIN_DURATION] = ...
   defs.Experiment(...
      'EPOCH_ONSETS','EPOCH_OFFSETS','DS_BIN_DURATION');
   
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