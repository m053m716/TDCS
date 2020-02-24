function varargout = SigRateSeriesFigs(varargin)
%SIGRATESERIESFIGS  TDCS Figure defaults for "significant" boxplot series
%
%  pars = defs.SigRateSeriesFigs();
%  [var1,var2,...] = defs.SigRateSeriesFigs('var1Name','var2Name',...);

pars = struct;
pars.YLIM_REG     = [0 50];                  % Spikes/second
pars.YLIM_LOG     = [-10 5];                 % log(Spikes/second)
pars.XLIM         = [5 35];                  % Seconds
pars.SAVE_DIR     = 'RATE_PLOTS';            % Save directory
pars.FONT_NAME    = 'Arial';
pars.FONT_COLOR   = 'k';

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