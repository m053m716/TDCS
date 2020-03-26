function varargout = LFP_Average(varargin)
%LFP_AVERAGE  Defaults for TDCS LFP Averaging
%
%  pars = defs.LFP_AVERAGE();
%  [var1,var2,...] = defs.LFP_AVERAGE('var1Name','var2Name',...);

% Recording options
pars = struct;
pars.TMIN = 5;                   % Start time (minutes)
pars.TMAX = 95;                  % End Time (minutes)
pars.REZ = 100;                  % Smoothing (milliseconds)
pars.K = 101;                    % Number of frequency bins
pars.KMIN = 2;                   % Min. frequency bin
pars.KMAX = 202;                 % Max. frequency bin

pars.N_FREQ_INTERP_PTS = 500;    % # of points to interpolate for freqs
pars.GAUSS_ROWS = 11;            % # of rows for gaussian kernel width
pars.GAUSS_COLS = 201;           % # of columns for gaussian kernel width

% File options
pars.DEF_DIR = 'P:/Rat';         % Default UI selection directory

% Plot options
pars.PLOT = true;                % Plot when finished?
pars.NEWFIG = true;              % Make a new figure for this plot
% pars.CAXIS = [-6 6];             % Default color axis
pars.YTICK = [2 10 60 200]; % Set YTICK marks


[pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS,pars.EPOCH_NAMES,pars.EPOCH_COL] =...
   defs.Experiment('EPOCH_ONSETS','EPOCH_OFFSETS','EPOCH_NAMES','EPOCH_COL'); 

[pars.RECT_CURVATURE,pars.TEXT_COL,pars.LINE_COL,...
   pars.LABEL_OFFSET,pars.LABEL_HEIGHT] = ...
   defs.EpochLabels('RECT_CURVATURE','TEXT_COL','LINE_COL',...
      'LABEL_OFFSET','LABEL_HEIGHT');

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