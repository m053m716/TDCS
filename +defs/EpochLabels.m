function varargout = EpochLabels(varargin)
%LFP_AVERAGE  Defaults for TDCS LFP Averaging
%
%  pars = defs.LFP_AVERAGE();
%  --> Returns scalar struct with all related parameter fields
%  
%  pars = defs.LFP_AVERAGE('EPOCH_ONSETS','EPOCH_OFFSETS');
%  --> Returns scalar struct with 2 fields
%
%  [var1,var2,...] = defs.LFP_AVERAGE('var1Name','var2Name',...);
%  --> Returns individual variables for each input argument

pars = struct;
[pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS,pars.EPOCH_COL,pars.EPOCH_NAMES] = ...
   defs.Experiment('EPOCH_ONSETS','EPOCH_OFFSETS','EPOCH_COL','EPOCH_NAMES');

pars.RECT_CURVATURE = [0.2 0.4];
pars.TEXT_COL = [1.00 1.00 1.00];
pars.LINE_COL = [0.55 0.55 0.55];         % Color of dashed separator lines for epochs
pars.LINE_STYLE = ':';
pars.LINE_WIDTH = 2;
pars.LABEL_FIXED_Y = []; % If empty, use LABEL_OFFSET, otherwise, fix Y
pars.LABEL_OFFSET = 1.5; % Value subtracted from minimum freq bin to create bar at bottom
pars.LABEL_HEIGHT = 1.5;

pars.ADD_EPOCH_DELIMITER_LINES = true;

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