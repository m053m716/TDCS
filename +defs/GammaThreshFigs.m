function varargout = GammaThreshFigs(varargin)
%GAMMATHRESHFIGS  TDCS Figure defaults for gamma-fit ISI threshold figs
%
%  pars = defs.GammaThreshFigs();
%  [var1,var2,...] = defs.GammaThreshFigs('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.NAME = 'Gamma ISI Responders';
pars.TITLE = {'BASAL'; ...
         'STIM'; ...
         'POST-1'; ...
         'POST-2'; ...
         'POST-3'; ...
         'POST-4'};
      
pars.FONT_NAME = 'Arial';
pars.FONT_COLOR = 'k';     
pars.YLIM1 = [-4 4];
pars.YLIM2 = [-25 25];

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