function varargout = Panelized_Rate_Figure(varargin)
%GENSPIKERATEPANELFIGURE  Pars for `genSpikeRatePanelFigure`
%
%  pars = defs.Panelized_Rate_Figure();
%  [v1,v2,...] = defs.Panelized_Rate_Figure('var1','var2',...);

% DEFAULTS
% Main options
pars = struct;
[pars.DIR,pars.FNAME] = ...
   defs.FileNames('OUTPUT_FIG_DIR','PANEL_RATE_FIGURE_NAME');
[pars.POL_ID,pars.NAME,pars.COLORS,...
   pars.EPOCH_COL_FACTOR,pars.EPOCH_NAMES,...
   pars.CONDITION_NAMES,pars.BIN_WIDTH] = ...
      defs.Experiment('CURRENT_ID','NAME_KEY',...
         'CONDITION_CUR_COL','EPOCH_COL_FACTOR','EPOCH_NAMES',...
         'NAME_KEY_MAT','DS_BIN_DURATION');
pars.DIR = fullfile(pars.DIR,'Panelized-Rate-Changes');
pars.TAG = ''; % For file naming
pars.FIG_POS = [0.15 0.2 0.35 0.70];

% Plotting parameters: `gfx__.plotWithShadedError`
pars.ALPHA = 0.001;
pars.SIG_STR = 'Significant (\\alpha = %s)';
pars.MAIN_LINEWIDTH = 2.0;
pars.ANNOTATION = 'on';
pars.ERROR_COEFF = 1.0;     % # of 'SEM' or 'SD' to shade
pars.ERROR_TYPE = 'SD';     % Can be 'SEM' or 'SD'
pars.WHITEN_W = 30;      % Number of samples to whiten (length of epoch)
pars.WHITEN_OVERLAP = 0; % Number of samples to overlap (whiten)
pars.H0 = []; % If H0 is empty, uses the combined SHAM conditions

% Legend parameters
pars.LEGEND_AXES_ADDRESS = [2,2];
pars.LEGEND_FONTNAME = 'Arial';
pars.LEGEND_FONTSIZE = 10;
pars.LEGEND_FONTCOLOR = 'black';
pars.LEGEND_LOCATION = 'none';
pars.LEGEND_POSITION = [0.30 0.65 0.50 0.075];
pars.LEGEND_ORIENTATION = 'vertical';
pars.LEGEND_BOX = 'off';
pars.LEGEND_BGCOLOR = 'none';

% Plotting parameters: `gfx__.addSignificanceLine`
pars.SIG_LINEWIDTH = 1.5;
pars.SIG_COLOR     = [0 0 0];   % Black
pars.SIG_LINEJOIN  = 'chamfer'; % 'chamfer','miter','round' are options
pars.SIG_Y_BRACKET = 65;
pars.SIG_Y_TICK =    63;  
pars.SIG_SHOW_PROBABILITY = true;
pars.SIG_TEST = @ttest2;
% For replications selection:
% Lowest integer to remove significance from PRE epoch

% Axes properties for `label__.setEvenLimits`
pars.XLIM = [0 (2700/60 + 2)] + 3; % Minutes
pars.YLIM = [-50 100];
pars.YTICK = [-50 -25 0 25 50];
pars.YTICKLABELS = {'-50','','0','','50'};
pars.LABEL_HEIGHT = 15; % Height of epoch labels (data units)
pars.LABEL_FIXED_Y = -50;

pars.ADD_EPOCH_DELIMITER_LINES = false;
pars.YLABEL = '\Delta \surd (FR)';
pars.XLABEL = 'Time (min)';
pars.XTICK = [20 35];
pars.XMINORTICK = [5 15 40 55];
pars.MAX_T_VAL_MINS = 120;
pars.LABEL_TEXT_COL = [0 0 0]; % Color of text on epoch labels
pars.RECTIFY = false; % Setting to true auto-changes other settings

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