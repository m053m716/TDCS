function varargout = LFP_Transform(varargin)
%LFP_Transform  Defaults for TDCS LFP transformations
%
%  pars = defs.LFP_Transform();
%  [var1,var2,...] = defs.LFP_Transform('var1Name','var2Name',...);

pars = struct;
pars.KMIN = 2;          % min. freq bin
pars.KMAX = 202;        % max. freq bin
pars.K =    500;        % # freq points
pars.GAUSS_ROWS = 11;   % Number of rows for bandwidth of gaussian kernel
pars.GAUSS_COLS = 201;  % Number of cols for bandwidth of gaussian kernel

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
   else
      varargout = cell(1,nargout);
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{iV} = pars.(F{idx});
         end
      end
   end
end

end