function varargout = FlatThreshRateFigs(varargin)
%FLATTHRESHRATEFIGS Defaults for TDCS flat-threshold rate figures
%
%  pars = defs.FlatThreshRateFigs();
%  [var1,var2,...] = defs.FlatThreshRateFigs('var1Name','var2Name',...);

pars = struct;

pars = struct;
pars.THRESH = 1;

pars.EX_NEG_THRESH = -11.7;
pars.EX_POS_THRESH = 2.6;
pars.FIG_NAME = 'Rate Change 1 Hz Responders';
pars.FIG_POS = [0.2 0.2 0.6 0.6];
pars.TITLE = {'BASAL'; ...
         'STIM'; ...
         'POST-1'; ...
         'POST-2'; ...
         'POST-3'; ...
         'POST-4'};
     
pars.YLIM = [-6 6];

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
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end