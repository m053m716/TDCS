function varargout = PowerBars(varargin)
%POWERBARS Pars for plotting 3D RMS power bars for `addPowerBars3` function
%
%  pars = defs.POWERBARS();
%  [var1,var2,...] = defs.POWERBARS('var1Name','var2Name',...);


% DEFAULTS
% Main options
pars = struct;
pars.XCOL = 'k';
pars.YCOL = 'k';
pars.ZCOL = 'k';
pars.NEXT = 'add';
pars.FONT = 'Arial';
pars.LINEW = 1;
pars.XLIM = [0 7];
pars.ZLIM = [0 0.4];
pars.FIG_POS = [0.15 0.20 0.30 0.60];
pars.TITLE = '';
pars.OUTPUT_FILE = '';
pars.BATCH = false;

%
pars.EPOCH_NAMES = defs.Experiment('EPOCH_NAMES');
pars.EPOCH_COLORS = defs.EpochColors(pars.EPOCH_NAMES{:});
pars.BAND_NAMES = defs.LFP('BANDS');

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