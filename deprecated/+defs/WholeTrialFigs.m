function varargout = WholeTrialFigs(varargin)
%WHOLETRIALFIGS  Pars for plotting "whole trial" RainCloudPlots
%
%  pars = defs.WholeTrialFigs();
%  [var1,var2,...] = defs.WholeTrialFigs('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.ANIMAL = [];
pars.CONDITION = [];
pars.EPOCH = [];
pars.DATA = [];
pars.BY_ANIMAL_FIG_NAME = 'Whole-trial: by Rat';
pars.BY_ANIMAL_FILE_NAME = 'Rates_by-Animal';
pars.BY_TREATMENT_FIG_NAME = 'Whole-trial: by Treatment';
pars.BY_TREATMENT_FILE_NAME = 'Rates_by-Treatment';
pars.BY_TREATMENT_BY_EPOCH_FIG_NAME = 'Whole-Trial: by Treatment and Epoch';
pars.BY_TREATMENT_BY_EPOCH_FILE_NAME = 'Rates_by-Treatment_by-Epoch';
pars.XLAB = 'log(spikes/second)';
pars.XLIM = [0.5 6.5];  
pars.XTICK = [1 3 5];
pars.YLAB = 'Density';
pars.YLIM = [-0.5 2];
pars.YTICK = [0 1 2];
pars.YTICKLAB = {'0','','2'};

pars.XTICK_CROSSED = [0 4 8];
pars.XLIM_CROSSED = [-0.5 8];
% pars.YTICK_CROSSED = [];
pars.YLIM_CROSSED = [-1 13];
pars.TEXT_X_OFFSET = 3.5;
pars.TEXT_TAGX_OFFSET = 0.25;
pars.KS_OFFSETS = 0:2:10;

[pars.CONDITION_COLORS,pars.ANIMAL_COLORS,pars.EPOCH_NAMES] = defs.Experiment(...
   'CONDITION_COL','ANIMAL_COL','EPOCH_NAMES');

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