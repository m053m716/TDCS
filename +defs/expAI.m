function varargout = expAI(varargin)
%EXPAI  Defaults for TDCS vector graphics export function
%
%  pars = defs.expAI();
%  [var1,var2,...] = defs.expAI('var1Name','var2Name',...);

pars = struct;

%Boolean options
pars.FORMATFONT  = true;                 %Automatically reconfigure axes fonts

%Figure property modifiers
pars.FONTNAME = 'Arial';                 %Set font name (if FORMATFONT true)
pars.FONTSIZE = 16;                      %Set font size (if FORMATFONT true)

%Print function modifiers
pars.FORMATTYPE = '-depsc';              % EPS Level 3 Color
% pars.FORMATTYPE  = '-dpsc2';             % Vector output format
% pars.FORMATTYPE = '-dpdf';               % Full-page PDF
% pars.FORMATTYPE = '-dsvg';               % Scaleable vector graphics format
% pars.FORMATTYPE = '-dpsc';               % Level 3 full-page PostScript, color
% pars.FORMATTYPE = '-dmeta';              % Enhanced Metafile (WINDOWS ONLY)
% pars.FORMATTYPE = '-dtiffn';             % TIFF 24-bit (not compressed)
pars.UIOPT       = '-noui';              % Excludes UI controls
% pars.FORMATOPT   = {'-cmyk'};              % Format options for color
% pars.FORMATOPT   = {'-loose'};             % Use loose bounding box
pars.FORMATOPT = {'-cmyk','-loose','-tiff'}; % Uses all options in cell ('-tiff' shows preview; eps, ps only)
pars.RENDERER    = '-painters';          % Graphics renderer
pars.RESIZE = '';
% pars.RESIZE      = '-fillpage';        % Alters aspect ratio
% pars.RESIZE      = '-bestfit';         % Choose best fit to page
pars.RESOLUTION  = '-r600';              % Specify dots per inch (resolution)
pars.BAD_CHILD_CLASS_LIST = {...   % List of "bad" child classes to skip setting fonts
   'matlab.ui.container.Menu'; ...
   'matlab.ui.container.Toolbar'; ...
   'matlab.ui.container.ContextMenu'; ...
   };

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