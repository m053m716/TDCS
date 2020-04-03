function varargout = LFP_Spectra_Figure(varargin)
%LFP_SPECTRA_FIGURE  Pars for `genLFPSpectraPanelFigure`
%
%  pars = defs.LFP_Spectra_Figure();
%  [v1,v2,...] = defs.LFP_Spectra_Figure('var1','var2',...);

% DEFAULTS
% Main options
pars = struct;
[pars.DIR,pars.FNAME] = ...
   defs.FileNames('OUTPUT_FIG_DIR','PANEL_SPECTRUM_FIGURE_NAME');
[pars.POL_ID,pars.NAME,pars.COLORS,pars.EPOCH_NAMES] = ...
      defs.Experiment('CURRENT_ID','NAME_KEY',...
         'CONDITION_CUR_COL','EPOCH_NAMES');
pars.DIR = fullfile(pars.DIR,'LFP-Spectra');
pars.TAG = ''; % For file naming

% Plotting parameters: `gfx__.plotWithShadedError`
pars.ALPHA = 0.05;
pars.C_IDX = [5,6];
pars.YLIM = [-2,2];
pars.MAIN_LINEWIDTH = 2.0;
pars.ANNOTATION = 'on';
pars.ERROR_COEFF = 1;    % # of 'SEM' or 'SD' to shade
pars.ERROR_TYPE  = 'SEM'; % Can be 'SEM' or 'SD'

% Legend parameters
pars.LEGEND_AXES_ADDRESS = [2,2];
pars.LEGEND_FONTNAME = 'Arial';
pars.LEGEND_FONTSIZE = 8;
pars.LEGEND_FONTCOLOR = 'black';
pars.LEGEND_LOCATION = 'best';
pars.LEGEND_BOX = 'off';
pars.LEGEND_BGCOLOR = 'none';
pars.LEGEND_POSITION = [0.30 0.65 0.50 0.075];

% Plotting parameters: `gfx__.addSignificanceLine`
pars.SIG_LINEWIDTH = 2.0;
pars.SIG_COLOR     = [0.15 0.15 0.15]; % Dark-grey
pars.SIG_LINEJOIN  = 'chamfer'; % 'chamfer','miter','round' are options
pars.SIG_YTOP = 1.45;  % Fixed (z-score) for bracket "top"
pars.SIG_YBOT = 1.42;  % Fixed (z-score) for bracket "tick"
pars.SIG_REPEATED = 0; % Do not require repeated
pars.SIG_ANNOTATION = 'on';
pars.SIG_SHOW_PROBABILITY = true;
pars.SIG_STR = 'Significant (''%s''|\\alpha = %s)';
pars.SIG_TESTFCN = @alltests;

% Axes properties for `label__.setEvenLimits`
pars.XLABEL = 'Frequency (Hz)';
pars.XLIM = [0 110]; % Add small buffer to right of axes (max freq = 105)
pars.XSCALE = 'log'; % Essentially makes it a log-log plot
pars.XTICK =    [0   5  7   10  30  50  80  100];
pars.XTICKLAB = {'','5','','10','','50','','100'};
pars.YLIM = [-1.5 1.5];
pars.YLABEL = '\Delta (log(P))';

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