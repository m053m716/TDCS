function varargout = Make_Stim_Epoch_Table(varargin)
%MAKE_STIM_EPOCH_TABLE Parameters for aggregating stim epoch table
%
%  pars = defs.Make_Stim_Epoch_Table();
%  [var1,var2,...] = defs.Make_Stim_Epoch_Table('VAR1','VAR2',...);
%  pars = parseParameters('Make_Stim_Epoch_Table','VAR1',var1Val,...);

pars = struct;
[pars.TAG,pars.OUT_DIR,pars.OUT_NAME] = ...
   defs.FileNames('STIM_EPOCH_TIMES_FILE','DIR','STIM_EPOCH_TABLE');

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