function h = plotWithShadedError(x,y,err,varargin)
%PLOTWITHSHADEDERROR  h = plotWithShadedError(x,y,err);
%
%  h = gfx.plotWithShadedError(x,data);
%  --> If no `y` is given, then extrapolate from `data` along with `err`
%  --> Uses `nanmean` and `nanstd` to compute mean and standard deviation
%        (see: eqn.mat2cb) 
%
%  h = gfx.plotWithShadedError(x,y,err);
%  --> Can provide `err` directly as a matrix with either 2 rows or 2
%      columns, which indicate the lower and upper bounds at each
%      observation. Note: order does not matter for upper vs lower, as long
%      as it is the same for each sample.
%
%  h = gfx.plotWithShadedError(ax,x,y,err);
%  --> First argument can always be an axes handle specifying which axes to
%        place the shaded error plot on
% 
%  h = gfx.plotWithShadedError(ax,data);
%  --> Extrapolate `x`, `y`, and `err` from `data` assuming that columns 
%        are grouped variables (samples) and rows different time-series 
%        instants (observations).
%
%  h = gfx.plotWithShadedError(ax,x,data);
%  --> Extrapolates `y`, `err` from `data` using size of `x`
%
%  h = gfx.plotWithShadedError(x,y,err,'Name',value,...);
%  h = gfx.plotWithShadedError(ax,x,y,err,'Name',value,...);
%  h = gfx.plotWithShadedError(ax,x,data,'Name',value,...);
%  --> Any of the above syntaxes allow specification of parameters using
%        <'Name',value> input argument pair syntax.
%
%  -- OUTPUT --
%     h  :  'matlab.graphics.primitive.Group' object
%     --> Contains a line and a patch representing the "spread" along the 
%         plotted line of the data of interest.
%
% class(h.Children(1)) == 'matlab.graphics.chart.primitive.Line'
% class(h.Children(2)) == 'matlab.graphics.primitive.Patch'

% PARSE INPUT
if nargin < 2
   error(['gfx:' mfilename ':TooFewInputs'],...
      ['\n\t->\t<strong>[PLOTWITHSHADEDERROR]:</strong> ' ...
      'gfx.plotWithShadedError requires at least 2 input arguments.\n']);
end

if nargin == 2  % If only 2 inputs, depend on class of first arg
   pars = defs.ShadedErrorPlot();
   if isa(x,'matlab.graphics.axis.Axes')
      ax = x;
      x = 1:size(y,2);
   else % Otherwise, assume `x` and `y` supplied correctly: compute `err`
      ax = gca;
   end
   data = y;
   dim = abs(find(size(x) == size(data))-2)+1;
   [err,y] = eqn.mat2cb(data,dim,pars.StandardDeviations);
end

if nargin == 3
   pars = defs.ShadedErrorPlot();
   if isa(x,'matlab.graphics.axis.Axes')
      ax = x;
      x = y;
      data = err;
      dim = abs(find(size(x) == size(data))-2)+1;
      [err,y] = eqn.mat2cb(data,dim,pars.StandardDeviations);
      
   else
      ax = gca;
   end
end

% Parse whether AXES was given as one of the inputs
if nargin > 3
   
   if isa(x,'matlab.graphics.axis.Axes')
      ax = x;
      x = y;
      if ischar(varargin{1})
         data = err;
         pars = parseParameters('ShadedErrorPlot',varargin{:});
         dim = abs(find(size(x) == size(data))-2)+1;
         [err,y] = eqn.mat2cb(data,dim,pars.StandardDeviations);
      else
         y = err;
         err = varargin{1};
         varargin(1) = [];
         pars = parseParameters('ShadedErrorPlot',varargin{:});
      end
   else
      pars = parseParameters('ShadedErrorPlot',varargin{:});
      ax = gca;
   end
end
% Create output matlab.graphics.primitive.Group object
h = hggroup(ax,...
   'DisplayName',pars.DisplayName,...
   'Tag',pars.Tag,...
   'UserData',pars.UserData);

% Make PATCH X & Y coordinates from combination of y + error
if iscolumn(x)
   x = x.';
end
if iscolumn(y)
   y = y.'; % Get correct orientation
end
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

F = [1:numel(pY),1];
V = [pX.',pY.'];

sh = patch(ax,...
   'Faces',F,'Vertices',V,...
   'FaceColor',pars.FaceColor,...
   'FaceAlpha',pars.FaceAlpha,...
   'EdgeColor',pars.EdgeColor,...
   'Tag',pars.Tag,...
   'DisplayName',pars.DisplayName,...
   'Parent',h);
sh.Annotation.LegendInformation.IconDisplayStyle = 'off';

% Plot LINE
l = plot(gca,x,y,...
   'Marker',pars.Marker,...
   'LineWidth',pars.LineWidth,...
   'Color',pars.Color,...
   'Tag',pars.Tag,...
   'DisplayName',pars.DisplayName,...
   'Parent',h);
l.Annotation.LegendInformation.IconDisplayStyle = 'on';

h.Annotation.LegendInformation.IconDisplayStyle = pars.IconDisplayStyle;

end