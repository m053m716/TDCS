function varargout = SpikeStats(varargin)
%SPIKESTATS  TDCS defaults for Stats export on spike series
%
%  pars = defs.SpikeStats();
%  [var1,var2,...] = defs.SpikeStats('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.BASAL = 1;  % Cell containing BASAL epoch
pars.STIM = 2;   % Cell containing STIM epoch
pars.FILENAME = 'TDCS Wilcoxon Rate Test.xlsx';

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