function h = plotWithShadedError(x,y,err,varargin)
%PLOTWITHSHADEDERROR  h = plotWithShadedError(x,y,err);
%
%  h = PLOTWITHSHADEDERROR(y,err);
%  h = PLOTWITHSHADEDERROR(x,y,err);
%  h = PLOTWITHSHADEDERROR(ax,x,y,err);
%  h = PLOTWITHSHADEDERROR(___,'Name',value,...);
%
% Returns a Matlab graphics group object containing a line and a patch that
% is a different way of plotting the same thing as 'errorbar' function.
%
%  If 'err' input is a vector, then it is treated as an "error" term that
%  is added and subtracted from 'y' to get vertical bounds of the shaded
%  region. If 'err' is a matrix, then it should be two concatenated vectors
%  of the same length as 'y' that will represent the lower and upper
%  coordinates of the vertical bounds for the shaded region (without
%  addition of 'y'). In this case, order doesn't matter for lb vs ub (it
%  will be identified).
% 
% class(h.Children(1)) == 'matlab.graphics.chart.primitive.Line'
% class(h.Children(2)) == 'matlab.graphics.primitive.Patch'

% PARSE INPUT
if nargin < 2
   error('gfx.plotWithShadedError requires at least 2 input arguments.');
end

if nargin == 2 % If only 2 inputs, assume x is 1:numel(y)
   err = y;
   y = x;
   x = 1:numel(y);
end

% Parse whether AXES was given as one of the inputs
if nargin > 3
   if isa(x,'matlab.graphics.axis.Axes')
      ax = x;
      x = y;
      y = err;
      err = varargin{1};
      varargin(1) = [];
   else
      ax = gca;
   end
else
   if isa(x,'matlab.graphics.axis.Axes')
      if (nargin < 3)
         error(['TDCS:' mfilename ':BadInput'],...
            'plotWithShadedError requires at least 2 input arguments in addition to optional axes argument.');
      else
         ax = x;
         x = 1:numel(y);
      end
   else
      ax = gca;
   end
end

%  Parse configured properties of line/patch objects
p = defs.ShadedErrorPlot();
F = fieldnames(p);
for iV = 1:2:numel(varargin)
   idx = strcmpi(F,varargin{iV});
   if sum(idx)==1
      p.(F{idx}) = varargin{iV+1};
   end
end

%
h = hggroup(ax,...
   'DisplayName',p.DisplayName,...
   'Tag',p.Tag,...
   'UserData',p.UserData);

% Make PATCH X & Y coordinates from combination of y + error
x = reshape(x,1,numel(x));
y = reshape(y,1,numel(y)); % Get correct orientation
if (size(err,1) > 1) && (size(err,2) > 1)
   if (size(err,2) == 2)
      err = err.'; % Transpose
   end
   if err(1,1) > err(2,1)
      err = flipud(err); % "Lower" bounds are first row
   end
   
   ly = err(1,:);
   uy = err(2,:);
else
   err = reshape(err,1,numel(err));
   uy = y + err;
   ly = y - err;
end

pY = [uy, fliplr(ly), uy(1)];
pX = [x, fliplr(x), x(1)];

sh = patch(gca,pX,pY,p.FaceColor,...
   'FaceAlpha',p.FaceAlpha,...
   'EdgeColor',p.EdgeColor,...
   'Tag',p.Tag,...
   'DisplayName',p.DisplayName,...
   'Parent',h);
sh.Annotation.LegendInformation.IconDisplayStyle = 'off';

% Plot LINE
l = plot(gca,x,y,...
   'Marker',p.Marker,...
   'LineWidth',p.LineWidth,...
   'Color',p.Color,...
   'Tag',p.Tag,...
   'DisplayName',p.DisplayName,...
   'Parent',h);
l.Annotation.LegendInformation.IconDisplayStyle = 'on';

h.Annotation.LegendInformation.IconDisplayStyle = p.IconDisplayStyle;

end