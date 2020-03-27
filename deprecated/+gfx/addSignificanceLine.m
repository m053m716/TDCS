function [h,c,p] = addSignificanceLine(x,y,h0,alpha,varargin)
%ADDSIGNIFICANCELINE  Add line to axes indicating significant epoch(s)
%
%  h = gfx.addSignificanceLine(y);
%  --> Tests significance of each sample of `y` against null hypothesis of
%        zero-mean, Gaussian random variable, with default alpha of 0.95
%  
%  h = gfx.addSignificanceLine(x,y);
%  --> Places samples of `y` at points `x` on the output line
%
%  h = gfx.addSignificanceLine(x,y,h0,alpha);
%  --> Can optionally specify both `h0` (null-hypothesis mean or matched
%      samples for samples of `y`) and `alpha` (threshold for significance)
%
%  h = gfx.addSignificanceLine(ax,y); 
%  --> Specify the axes to add the significance line to
%
%  h = gfx.addSignificanceLine(ax,x,y);
%  --> Specify axes, and plot points using `x`
%
%  h = gfx.addSignificanceLine(ax,x,y,h0);
%  --> Compare samples of `y` and `h0` at points specified in `x` 
%
%  h = gfx.addSignificanceLine(___,'Name',value,...);
%  --> Note: if `ax` is given as first argument, then `alpha` must be set
%        using the <'Alpha',alphavalue,>... 'Name',value syntax
%  --> Other parameters correspond to <'Name',value> pairs for
%        'matlab.graphics.primitive.Line' objects. Exceptions include:
%     * 'TestFcn' : default == @ttest2  (@ranksum or @ttest2)
%        --> Could be any test function that returns 1 when rejecting null
%              hypothesis (that data come from the same distribution):
%              Should be able to take arguments in the format
%           >> p = pars.TestFcn(y{ii},h0{ii},'Alpha',alpha);
%              --> Where p is true or false; y{ii} is data in sample ii,
%                    and h0 is the null distribution for sample ii. alpha
%                    sets the significance threshold  
%     * 'Alpha' : default == 0.90 (significance level for `ttest2` or `ranksum`)
%     * 'H0'    : default == 0    (test against zero-mean)
%     * 'NormalizedBracketY'  :  default = 0.9  (y-value of "bracket" part)
%           [0 -> bottom of axes; 1 -> top of axes]
%     * 'NormalizedTickY'     :  default = 0.875 (y-value of "tick" part)
%           [0 -> bottom of axes; 1 -> top of axes]
%     * 'MinDiffScale'        :  default = 0.1 (x-offset for "enclosing")
%           [(for emphasizing "included" vs. "excluded" samples; offset)]
%     * 'PLineColorFactor'    :  default = 0.75 (value to scale color data)
%     * 'AddDataPlot'         :  default = true (If no Children of axes,
%           adds the data as a line plot)
%     * 'PlotColor'           :  default = 'auto' (Color for optional plot)
%        --> If 'auto', then uses current axes .ColorOrder and
%            .ColorOrderIndex properties
%
%  -- Inputs --
%  x : Column vector of XData of sample points for comparison. 
%  y : YData of sample points for comparison. Can be given as a cell array
%        as long as # cell elements is same as # rows of `x`;
%        alternatively, can be given as a matrix with the same # rows as
%        `x` (if each observed sample has the same number of observations)
%  h0 : Null-hypothesis
%
%  -- Output --
%  h : Handle to 'matlab.graphics.primitive.Line' object
%  c : Handle to optionally plotted data line or else all (handles visible)
%        children of current axes
%  p : (If requested) adds a "probability" line as well for p-value at each
%        hypothesis test that is conducted to generate significance line.
%
%  Returns handle to created 'matlab.graphics.primitive.Line' object, which
%  denotes regions in which `ttest2` indicated a statistically significant
%  difference from the null-hypothesis under the assumption of normality of
%  both distributions.
%
% By: Max Murphy (max.murphy11@gmail.com)

if isa(x,'matlab.graphics.axis.Axes')
   if nargin < 2
      error(['gfx:' mfilename ':TooFewInputs'],...
            ['\n\t->\t<strong>[ADDSIGNIFICANCELINE:]</strong> ' ...
            'Not enough inputs.\n']);
   end
   ax = x;
   
   switch nargin
      case 2
         x = 1:max(size(y));
         h0 = [];
         alpha = [];
      case 3
         x = y;
         y = h0;
         h0 = [];
         alpha = [];
      case 4
         x = y;
         y = h0;
         h0 = alpha;
         alpha = [];
      otherwise
         x = y;
         y = h0;
         h0 = alpha;
         if ischar(varargin{1})
            alpha = [];
         else
            alpha = varargin{1};
         end
   end
else
   ax = gca;
   switch nargin
      case 1
         y = x;
         x = 1:max(size(y));
         h0 = [];
         alpha = [];
      case 2
         h0 = [];
         alpha = [];
      case 3
         alpha = [];
      otherwise % Do nothing
         
   end
end
% Get default parameters
pars = parseParameters('SignificanceLine',varargin{:});

% Check input shape / presence
if isrow(x)
   x = x.';
end

if isempty(alpha)
   alpha = pars.Alpha;
end

% Make sure `h0` and `y` are in "cell" format
if ~iscell(y)
   y = mat2cell(y,ones(1,numel(x)),size(y,2));
end

if isempty(h0)
%    h0 = cellfun(@(C)ones(size(C)).*pars.H0,y,'UniformOutput',false);
   h0 = num2cell(ones(size(x)).*pars.H0);
elseif ~iscell(h0)
   h0 = mat2cell(h0,ones(1,numel(x)),size(h0,2));
end

% Rows of `h0` must match samples of `x`
if size(h0,1)~=size(x,1)
   h0 = h0.';
   if size(h0,1)~=size(x,1)
      error(['gfx:' mfilename ':DimensionMismatch'],...
         ['\n\t->\t<strong>[ADDSIGNIFICANCELINE]:</strong> ' ...
         'Dimension mismatch between `h0` and `x`. Check inputs.\n']);
   end
end

% Rows of `y` must match samples of `x`
if size(y,1)~=size(x,1)
   y = y.';
   if size(y,1)~=size(x,1)
      error(['gfx:' mfilename ':DimensionMismatch'],...
         ['\n\t->\t<strong>[ADDSIGNIFICANCELINE]:</strong> ' ...
         'Dimension mismatch between `y` and `x`. Check inputs.\n']);
   end
end
% Initialize "past sample" significance state
isSignificant = false;

% Get offset, which depends on `MinDiffScale`
d = min(diff(x)) * pars.MinDiffScale;

ax.NextPlot = 'add'; 
if isempty(ax.Children) && pars.AddDataPlot
   if strcmpi(pars.PlotColor,'auto')
      pars.PlotColor = ax.ColorOrder(ax.ColorOrderIndex,:);
      ax.ColorOrderIndex = rem(ax.ColorOrderIndex,size(ax.ColorOrder,1))+1;
   end
   nSamples = cellfun(@(x)numel(x),y);
   nAvg = round(median(nSamples));
   yy = y(nSamples >= nAvg);
   xData = x(nSamples >= nAvg);
   yData = cell2mat(cellfun(@(C)C(1:nAvg),yy,'UniformOutput',false));
   c = gfx.plotWithShadedError(ax,xData,yData,...
      'Color',pars.PlotColor,...
      'LineStyle',pars.PlotLineStyle,...
      'LineWidth',pars.PlotLineWidth);
else
   c = get(gca,'Children');
end

if strcmpi(pars.Color,'auto')
   pars.Color = ax.ColorOrder(ax.ColorOrderIndex,:);
   ax.ColorOrderIndex = rem(ax.ColorOrderIndex,size(ax.ColorOrder,1))+1;
end

if isempty(pars.UserData)
   pars.UserData = pars; % Store the parameters with object somehow
end

h = line(ax,nan,nan,...
   'Color',pars.Color,...
   'DisplayName',sprintf('Significant (\alpha = %g)',alpha),...
   'LineWidth',pars.LineWidth,...
   'LineStyle',pars.LineStyle,...
   'LineJoin',pars.LineJoin,...
   'AlignVertexCenters',pars.AlignVertexCenters,...
   'Marker',pars.Marker,...
   'MarkerSize',pars.MarkerSize,...
   'MarkerEdgeColor',pars.MarkerEdgeColor,...
   'MarkerFaceColor',pars.MarkerFaceColor,...
   'Visible',pars.Visible,...
   'SelectionHighlight',pars.SelectionHighlight,...
   'Clipping',pars.Clipping,...
   'Interruptible',pars.Interruptible,...
   'BusyAction',pars.BusyAction,...
   'PickableParts',pars.PickableParts,...
   'HitTest',pars.HitTest,...
   'ButtonDownFcn',pars.ButtonDownFcn,...
   'CreateFcn',pars.CreateFcn,...
   'DeleteFcn',pars.DeleteFcn,...
   'Tag',pars.Tag,...
   'UserData',pars.UserData...
   );
h.Annotation.LegendInformation.IconDisplayStyle = pars.Annotation;

if nargout > 2
   p = copy(h);
   p.Parent = ax;
   p.Color = p.Color .* pars.PLineColorFactor;
   if isempty(h.Tag)
      p.DisplayName = 'P_{reject}';
   else
      p.DisplayName = [h.Tag ': P_{reject}'];
   end
   p.Annotation.LegendInformation.IconDisplayStyle = pars.Annotation;
end

yBrace = getNormalizedValue(ax.YLim,pars.NormalizedBracketY);
yTick = getNormalizedValue(ax.YLim,pars.NormalizedTickY);
pVal = nan(size(x));

N = numel(x);
nRepeat = round(pars.RepeatedThresholdRatio*N);
counter = 0;

for ii = 1:N
   [testResult,pVal(ii)] = pars.TestFcn(y{ii},h0{ii},'Alpha',alpha);
   if testResult
      if ~isSignificant % If previous wasn't significant, add new "Start"
         counter = counter + 1;
         if counter == nRepeat
            h = addLineStartIndicator(h,x(ii-floor(nRepeat/2)),...
               d,yTick,yBrace);
            isSignificant = true; % "Past sample was significant"   
            counter = 0;
         end
      else % Otherwise was already significant (line being drawn)
         counter = 0; % Reset the counter
      end
   else
      if isSignificant % If previous was significant, add "Stop" indicator
         h = addLineStopIndicator(h,x(ii-1)+d,yTick,yBrace);
         isSignificant = false;  % "Past sample was not significant"
      else % Otherwise no line is currently being drawn
         counter = 0;
      end
   end
end

% Add "end" demarcation (if still indicating significance)
if isSignificant
   h = addLineStopIndicator(h,x(end)+d,yTick,yBrace);
end

if isempty(pars.MarkerIndices)
   pars.MarkerIndices = 1:numel(h.XData);
end
h.MarkerIndices = pars.MarkerIndices;

% If it's requested, update the "p-value" line data
if nargout > 2
   p.XData = x;
   p.YData = getNormalizedValue(ax.YLim,pVal,pars.PMinNormValue);
end

% "Helper" functions to append data to significance lines
   function h = addLineStartIndicator(h,xStart,xOffset,yTick,yBrace)
      %ADDLINESTARTINDICATOR  Add "start" tick / bracket line data
      %
      %  h = addLineStopIndicator(h,xStart,xOffset,yTick,yBracket);
      %  --> h : 'matlab.graphics.primitive.Line' object
      
      h.XData = [h.XData,   xStart,   xStart,  xStart+xOffset];
      h.YData = [h.YData,    yTick,   yBrace,          yBrace];
   end

   function h = addLineStopIndicator(h,xEnd,yTick,yBrace)
      %ADDLINESTOPINDICATOR  Add "stop" tick / bracket line delimiter data
      %
      %  h = addLineStopIndicator(h,xEnd,yTick,yBrace);
      %  --> h : 'matlab.graphics.primitive.Line' object
      
      h.XData = [h.XData,   xEnd,  xEnd, nan];
      h.YData = [h.YData, yBrace, yTick, nan];
      
   end

   function y = getNormalizedValue(yLim,z,offset)
      %GETNORMALIZEDVALUE  Return `data` y- value from normalized [0,1] val
      %
      %  y = getNormalizedValue(yLim,z);
      %  --> `z`::0 -> y == yLim(1); 
      %  --> `z`::1 -> y == yLim(2);
      %
      %  y = getNormalizedValue(yLim,z,offset);
      %  --> Introduce arbitrary "floor" offset
      
      if nargin < 3
         offset = yLim(1);
      end
      y = z .* (yLim(2) - offset) + offset;
   end
end