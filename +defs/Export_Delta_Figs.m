function varargout = Export_Delta_Figs(varargin)
%EXPORT_DELTA_FIGS  Defaults for TDCS Experiment delta-stat figures export
%
%  pars = defs.Export_Delta_Figs();
%  [var1,var2,...] = defs.Export_Delta_Figs('var1Name','var2Name',...);

pars = struct;

[pars.FIG_POS,pars.ANIMAL_COL,pars.CONDITION_CUR_COL,pars.EPOCH_COL_FACTOR,pars.EPOCH_TS,pars.EPOCH_NAMES] = ...
   defs.Experiment('FIG_POS','ANIMAL_COL','CONDITION_CUR_COL','EPOCH_COL_FACTOR','EPOCH_MASK_INDICES','EPOCH_NAMES');
pars.OUT_FOLDER = fullfile(defs.FileNames('DIR'),'Figures');
pars.INTENSITY_FNAME = {'0_0mA','0_2mA','0_4mA'};
pars.INTENSITY_LABEL = {'0.0 mA', '0.2 mA', '0.4 mA'};
pars.CURRENT_FNAME = {'Anodal', 'Cathodal'};
pars.CURRENT_LABEL = {'Anodal', 'Cathodal'};
pars.MARKER_SIZE = 3;
pars.MARKER_FACE_ALPHA = 0.33;
pars.COLOR = [0 0 0];
pars.CONDITION_ID = 1;
pars.EPOCH_ID = 1;
pars.CUR_ID = 1;
pars.XJITTER = 0.15;
pars.XLIM = [0 (2700/60)] + 5;
pars.YLIM = [-100 100];
pars.AX = [];

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