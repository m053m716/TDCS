function varargout = DS(varargin)
%DS  Pars for `mmDS` function (decimation / LPF)
%
%  pars = defs.DS();
%  [var1,var2,...] = defs.DS('var1Name','var2Name',...);


% DEFAULTS
% Main options
pars = struct;
pars.DIR = '';
pars.DEC_FS = 1000;    % Desired sample rate (Hz; may not end up exact)
pars.NOTCH = [57,  63;  ...
              117, 123; ... % If empty, no notch applied; otherwise, use
              177, 183; ... % bands specified by rows of this matrix.
              237, 243];

% Directory info
pars.DEF_DIR = 'P:\Rat\tDCS';    % Default UI selection direcotry
pars.IN_PATH = 'RawData';        % Appended folder name for raw data
pars.IN_ID = 'Raw';              % Tag for files to input
pars.OUT_ID = 'DS';              % Tag/appended folder name for DS data
pars.DELIM = '_';                % Delimiter for file name inputs

% Cluster info
pars.USE_CLUSTER=false;        % Option to run on Isilon cluster
pars.UNC_PATH='\\kumc.edu\data\research\SOM RSCH\NUDOLAB\Processed_Data\';


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