function varargout = RainCloudPlots(varargin)
%RAINCLOUDPLOTS  Pars for plotting "whole trial" RainCloudPlots
%
%  pars = defs.RainCloudPlots();
%  [var1,var2,...] = defs.RainCloudPlots('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.ANIMAL = [];
pars.POLARITY = [];
pars.INTENSITY = [];
pars.EPOCH = [];
pars.DATA = [];
pars.INTENSITY = [];
pars.POLARITY = [];
% pars.XLAB = 'log(spikes/second)';
pars.XLAB = 'auto';
pars.YLAB = 'Density';
pars.LINE_WIDTH = 1;
% pars.XTICK = 'auto';
pars.XTICK = [0.5 1.5 2.5];
pars.XTICKLABELS = 'auto';
pars.XLIM = [0.5 3.0];
% pars.XLIM = 'auto';
% pars.XLIM = [0.5 6.5];  
pars.XCOLOR = 'k';
pars.XLABEL_FONT = 'Arial';
pars.XLABEL_SIZE = 14;
% pars.YTICK = 'auto';
pars.YTICK = [0 1 2];
pars.YTICKLAB = {'0','','2'};
% pars.YTICKLAB = 'auto';
pars.YLIM = 'auto';
% pars.YLIM = [-0.5 2];
pars.YCOLOR = 'k';
pars.YLABEL_FONT = 'Arial';
pars.YLABEL_SIZE = 14;
pars.XTICKLAB = 'auto';
pars.XTICK_CROSSED = [0.5, 1.5, 2.5];
pars.XLIM_CROSSED = [-0.5 4];
pars.YTICK_CROSSED = [6 8 10];
pars.YLIM_CROSSED = [4 15];
pars.TEXT_X_OFFSET = 1.5;
pars.TEXT_TAGX_OFFSET = 0.25;
pars.KS_OFFSETS = 0:2:10;
pars.BANDWIDTH = []; % For ksdensity (auto-estimate)
pars.NBINS = 200;    % # of bins for ksdensity
pars.METHOD = 'ks'; % 'ks', 'rash'
pars.RAINDROP_ALPHA = 0.33;
pars.RAINDROP_SIZE = 10;
pars.TAG = '';

[pars.CONDITION_COLORS,pars.ANIMAL_COLORS,pars.EPOCH_NAMES,...
 pars.FILE_KEY,pars.NAME_KEY,pars.EPOCH_COL_FACTOR] = ...
   defs.Experiment(...
      'CONDITION_CUR_COL','ANIMAL_COL','EPOCH_NAMES',...
      'TREATMENT_FILE_KEY_MAT','NAME_KEY_MAT','EPOCH_COL_FACTOR',...
      'TALL_FIG_LEFT','TALL_FIG_RIGHT','FIG_POS');
pars.EPOCH_COL_FACTOR = pars.EPOCH_COL_FACTOR';

[pars.OUTPUT_DIR,pars.BY_ANIMAL_FIG_NAME,pars.BY_ANIMAL_FILE_NAME,...
   pars.BY_TREATMENT_FIG_NAME,pars.BY_TREATMENT_FILE_NAME,...
   pars.BY_TREATMENT_BY_EPOCH_FIG_NAME,pars.BY_TREATMENT_BY_EPOCH_FILE_NAME] ...
   = defs.FileNames('RAINCLOUD_FIG_DIR','BY_ANIMAL_FIG_NAME',...
   'BY_ANIMAL_FILE_NAME','BY_TREATMENT_FIG_NAME',...
   'BY_TREATMENT_FILE_NAME','BY_TREATMENT_BY_EPOCH_FIG_NAME',...
   'BY_TREATMENT_BY_EPOCH_FILE_NAME');
pars.FIG_POS_A = [rand(1)*0.05+0.2,rand(1)*0.05+0.175,0.5,0.6];
pars.FIG_POS_B = [rand(1)*0.10+0.2,rand(1)*0.10+0.175,0.5,0.6];
pars.FIG_POS_C = [rand(1)*0.05+0.2,rand(1)*0.05+0.175,0.6,0.7];

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
      for iV = 1:numel(varargin)
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end