function varargout = XCorr_Panels(varargin)
%XCORR_PANELS  Names of various files saved on KUMC server
%
%  pars = defs.XCorr_Panels();
%  [var1,var2,...] = defs.XCorr_Panels('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
% Major parameters
pars.DIR = defs.FileNames('OUTPUT_FIG_DIR');
pars.XLIM = [5 60];
pars.YLIM = [-1.25 1.75];
pars.LINEWIDTH = 1.25;
pars.YTICK = [-1 -0.5 0 0.5 1];
pars.FONTNAME = 'Arial';
pars.XCOLOR = 'k';
pars.YCOLOR = 'k';
pars.MASK_Y = 1.70;
pars.MASK_COLOR = [0.8 0.8 0.8];
pars.LABEL_Y = 1.25;
pars.PRE_X = 8;   % Minutes
pars.STIM_X = 21; % Minutes
pars.POST_X = 45; % Minutes
pars.TAG = '';

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