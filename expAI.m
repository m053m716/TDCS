function expAI(fig,filename,varargin)
%EXPAI export figure in appropriate format for Adobe Illustrator
%
%   EXPAI(filename);
%
%   --------
%    INPUTS
%   --------
%      fig      :   Handle to the figure you wish to export.
%
%   filename    :   String with output filename (and extension) of figure
%                   to export for Adobe Illustrator.
%
%   varargin    :   Optional 'NAME', value input argument pairs.
%
%   --------
%    OUTPUT
%   --------
%   A second file with the same name for use with Adobe Illustrator.

% Parse input parameters
pars = parseParameters('expAI',varargin{:});

% Ensure filename has correct extension
[p,f,~] = fileparts(filename);
if strcmp(pars.FORMATTYPE, '-dtiffn')
   ext = '.tif';
elseif strcmp(pars.FORMATTYPE, '-dpsc2')
   ext = '.ps';
elseif strcmp(pars.FORMATTYPE, '-dsvg')
   ext = '.svg';
elseif strcmp(pars.FORMATTYPE, '-dpdf')
   ext = '.pdf';
elseif strcmp(pars.FORMATTYPE, '-depsc')
   ext = '.eps';
else
   ext = '.ai';
end
filename = fullfile(p,[f ext]);

% MODIFY FIGURE PARAMETERS
set(gcf, 'Renderer', pars.RENDERER(2:end));
if pars.FORMATFONT
   c = get(gcf, 'Children');
   for iC = 1:numel(c)
      if ~ismember(class(c(iC)),pars.BAD_CHILD_CLASS_LIST)
         set(c(iC),'FontName',pars.FONTNAME);
         set(c(iC),'FontSize',pars.FONTSIZE);
         if isa(c(iC),'matlab.graphics.axis.Axes')
            xl = get(c(iC),'XLabel');
            set(xl,'FontName',pars.FONTNAME);
            yl = get(c(iC),'YLabel');
            set(yl,'FontName',pars.FONTNAME);
            t = get(c(iC),'Title');
            set(t,'FontName',pars.FONTNAME);
            set(t,'FontSize',pars.FONTSIZE);
            set(c(iC),'LineWidth',max(c(iC).LineWidth,1));
         end
      end
   end
end

% OUTPUT CONVERTED FIGURE
if isempty(pars.RESIZE)
   print(pars.UIOPT,        ...
      pars.RESOLUTION,   ...
      fig,          ...
      pars.FORMATTYPE,   ...
      pars.FORMATOPT{:},    ...
      pars.RENDERER,     ...
      filename);
else
   print(pars.UIOPT,        ...
      pars.RESOLUTION,   ...
      fig,          ...
      pars.RESIZE,       ...
      pars.FORMATTYPE,   ...
      pars.FORMATOPT{:},    ...
      pars.RENDERER,     ...
      filename);
end

end