function varargout = SigRateChangeFigs(varargin)
%SIGRATECHANGEFIGS  Defaults for TDCS Figures of "significant" responders
%
%  pars = defs.SigRateChangeFigs();
%  [var1,var2,...] = defs.SigRateChangeFigs('var1Name','var2Name',...);

pars = struct;
pars.FONT_NAME = 'Arial';
pars.FONT_COLOR = 'k';
pars.BY_TREATMENT_NAME = 'Significant Units by Treatment';
pars.BY_TREATMENT_BY_ANIMAL_NAME = 'Significant Units by Treatment by Animal';

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
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end