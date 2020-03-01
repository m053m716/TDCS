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

pars = defs.LFP_Average('EPOCH_ONSETS','EPOCH_OFFSETS','EPOCH_COL',...
   'LABEL_OFFSET','LABEL_HEIGHT','LINE_COL','EPOCH_NAMES','TEXT_COL',...
   'RECT_CURVATURE');

if numel(varargin) < 1
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
      for iV = 1:numel(varargin)
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{iV} = pars.(F{idx});
         end
      end
   else
      for iV = 1:numel(varargin)
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:\n',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end