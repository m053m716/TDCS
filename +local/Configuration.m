function varargout = Configuration(varargin)
%CONFIGURATION  Local parameters that are machine-specific 
%
%  Note: add this file to `.gitignore` to facilitate working between
%        multiple computers.
%
%  pars = local.Configuration();
%  [var1,var2,...] = local.Configuration('var1Name','var2Name',...);

pars = struct;

% File paths
pars.DIR = 'P:\Rat\tDCS';           % MM - KUMC Isilon server
% pars.DIR = 'D:\MATLAB\Data\tDCS'; % MM - Home Desktop

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