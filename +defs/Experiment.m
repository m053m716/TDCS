function varargout = Experiment(varargin)
%EXPERIMENT  Defaults for TDCS Experiment
%
%  pars = defs.Experiment();
%  [var1,var2,...] = defs.Experiment('var1Name','var2Name',...);

pars = struct;

% Group info
pars.TREATMENT = [1,2,3,4,5,6];
pars.CURRENT_ID = [-1 1 -1 1 -1 1];
pars.TREATMENT_FILE_KEY = {'0_0mA-Anodal','0_0mA-Cathodal','0_2mA-Anodal','0_2mA-Cathodal','0_4mA-Anodal','0_4mA-Cathodal'};
pars.NAME_KEY = {'0.0 mA Anodal','0.0 mA Cathodal','0.2 mA Anodal','0.2 mA Cathodal','0.4 mA Anodal','0.4 mA Cathodal'};
pars.TREATMENT_COL_FILL = [...
   0.3 1.0 0.3; ... % Lightest green
   0.3 0.3 1.0; ... % Lightest blue
   0.2 0.9 0.2; ... % Medium green
   0.2 0.2 0.9; ... % Medium blue
   0.1 0.8 0.1; ... % Darkest green
   0.1 0.1 0.8  ... % Darkest blue
   ];
pars.TREATMENT_COL_EDGE = [...
   1.0 1.0 1.0; ... % White
   1.0 1.0 1.0; ... % White
   0.5 0.5 0.5; ... % Grey
   0.5 0.5 0.5; ... % Grey
   0.0 0.0 0.0; ... % Black
   0.0 0.0 0.0  ... % Black
   ];
pars.MARKUP_KEY = cell(size(pars.NAME_KEY));
for i = 1:numel(pars.MARKUP_KEY)
   pars.MARKUP_KEY{i} = sprintf('\\fontname{Arial} \\color[rgb]{%g,%g,%g} %s',...
      pars.TREATMENT_COL_FILL(i,1),...
      pars.TREATMENT_COL_FILL(i,2),...
      pars.TREATMENT_COL_FILL(i,3),...
      pars.NAME_KEY{i});
end

% Timing info
pars.EPOCH_NAMES = {'BASAL','STIM','POST1','POST2','POST3','POST4'}; % Labels of epochs
pars.EPOCH_ONSETS = [5  15 35 50 65 80]; % (Values in minutes)
pars.EPOCH_OFFSETS = [15 35 50 65 80 95]; % (Values in minutes)
pars.EPOCH_COL = defs.EpochColors(pars.EPOCH_NAMES{:});

% Path info
pars.PROCESSED_TANK = 'P:\Rat\tDCS';
pars.ACC_TAG = '_Accelerometry_Data.mat';
pars.DS_FOLDER = '_DS';
pars.DS_TAG = '*DS*.mat';

% General: for figures
pars.TOP_AXES = [0.15 0.60 0.75 0.25];
pars.BOT_AXES = [0.15 0.15 0.75 0.25];
pars.TALL_FIG_LEFT  = [0.20, 0.175, 0.25, 0.70];
pars.TALL_FIG_RIGHT = [0.50, 0.175, 0.25, 0.70];
pars.TALL_FIG_RAND  = [rand(1)*0.3+0.2, 0.175, 0.25, 0.70];
pars.SHORT_FIG_RAND  = [rand(1)*0.3+0.2, rand(1)*0.3+0.175, 0.25, 0.25];
pars.FIG_POS = [rand(1)*0.05+0.2,rand(1)*0.05+0.175,0.5,0.6];
addHelperRepos(defs.Repos());
pars.ANIMAL_COL = cbrewer('qual','Set1',9);
pars.CONDITION_COL = cbrewer('qual','Paired',6);

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