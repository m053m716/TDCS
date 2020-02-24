function varargout = ISIDistributionFigs(varargin)
%ISIDISTRIBUTIONFIGS  Defaults for TDCS ISI Distribution Figures
%
%  pars = defs.ISIDistributionFigs();
%  [var1,var2,...] = defs.ISIDistributionFigs('var1Name','var2Name',...);

pars = struct;
pars.ISI_DIR = 'ISI';   % Sub-folder to put figures in
pars.USE_VEC = [];      % Vector mask of recordings to use
pars.XLIM = [0 3000];   % X-axes limits
pars.YLIM = [0 3000];   % Y-axes limits
pars.T_BASAL = 900;     % Duration of BASAL period (seconds)
pars.T_STIM = 1200;     % Duration of STIM period (seconds)
pars.PLOT = true;       % Make plots?


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