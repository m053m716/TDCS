function varargout = SignificanceLine(varargin)
%SIGNIFICANCELINE  Defaults for `SignificanceLine` plots
%
%  pars = defs.SignificanceLine();
%  [var1,var2,...] = defs.SignificanceLine('var1Name','var2Name',...);

pars = struct;
% "SignificanceLine"  specific properties:
pars.TestFcn = @ttest2;
pars.Alpha = 0.90;               % Default significance threshold
pars.H0    = 0;                  % Default null-hypothesis is zero-mean
pars.RepeatedThresholdRatio = 0.02; % Sets threshold for repeated tests; 
%  e.g. If 300 sample points, with value of 0.02 this requires 6 
%       consecutive "significant" tests, which would then draw the start of
%       the "significant" line at the 3rd (halfway through) consecutive
%       positive test (to account for offset based on forward vs backward
%       test). 
%       Similarly, once threshold is crossed, requires the same number of
%       consecutive "non-significant" tests to stop drawning the 
%       "significance" line
pars.PLineColorFactor = 0.75;    % Factor for "lightening" `p` line
pars.PMinNormValue = 0;          % [0,1] range, normalized minimum value of `p` p-value line
pars.NormalizedBracketY = 0.9;   % 0 -> Bottom of axes; 1 -> Top of axes
pars.NormalizedTickY = 0.875;    % 0 -> Bottom of axes; 1 -> Top of axes
pars.MinDiffScale = 0.1;         % Scalar for min diff (for adding end of bracket)
pars.PlotColor = 'auto';         % Color for plotting optional "data" line
pars.PlotLineWidth = 1.25;
pars.PlotLineStyle = '-';
pars.AddDataPlot = true;

% matlab.graphics.primitive.Line properties:
pars.Color = 'auto';
pars.LineWidth = 2.5;
pars.Marker = 'none';
pars.MarkerIndices = []; % Leave empty for default `line` behavior
pars.MarkerSize = 6;    
pars.MarkerEdgeColor = 'auto';
pars.MarkerFaceColor = 'none';
pars.Annotation = 'on'; % Set to 'off' to exclude from Legend
pars.LineStyle = '-';
pars.LineJoin = 'round';
pars.AlignVertexCenters = 'off';

pars.Visible = 'on';
pars.SelectionHighlight = 'on';
pars.Clipping = 'off';

pars.Interruptible = 'on';
pars.BusyAction = 'queue';
pars.PickableParts = 'visible';
pars.HitTest = 'on';

% Interactive callbacks
pars.ButtonDownFcn = '';
pars.CreateFcn = '';
pars.DeleteFcn = '';

% Identifiers
pars.Tag = '';
pars.UserData = [];

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