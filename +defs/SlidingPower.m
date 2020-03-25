function varargout = SlidingPower(varargin)
%MAKE_RMS_MASK  Pars for `SlidingPower` function
%
%  pars = defs.SlidingPower();
%  [var1,var2,...] = defs.SlidingPower('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.OV = 0; % # of samples to overlap (0 -- no overlap)

% Window length is parsed from `defs.Experiment` (main parameters)
[sec,hz] = defs.Experiment('DS_BIN_DURATION','FS_DECIMATED');
pars.WLEN = round(sec*hz); % Samples
if rem(pars.WLEN,2)==0
   pars.WLEN = pars.WLEN + 1; % Ensure that it's odd
end

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