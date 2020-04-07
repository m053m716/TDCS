function varargout = make_RMS_mask(varargin)
%MAKE_RMS_MASK  Pars for `make_RMS_mask` function
%
%  pars = defs.make_RMS_mask();
%  [var1,var2,...] = defs.make_RMS_mask('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.DIR = 'P:\Rat\tDCS';                       % Tank path
pars.FILE = defs.FileNames('RMS_MASK_FILE');    % Filename of RMS mask file
[pars.BIN,pars.RAW_TAG,pars.RMS_THRESH]  = defs.Experiment(...
   'DS_BIN_DURATION','RAW_TAG','RMS_THRESH'); % DS_BIN_DURATION: Seconds
pars.SKIP_IF_FILE_PRESENT = true;  % Do not overwrite old file if it exists

% FOR SLIDINGPOWER
pars.RMS = defs.SlidingPower();
pars.INFO_FILE = '_GenInfo.mat';

% FOR EXTRACT_COMMON_AVERAGE
pars.INFILE_TYPE_TAG = '_DS';
pars.OUTFILE_TYPE_TAG = '_DS';
pars.INFILE_CHANNEL_TOKEN = '_Ch_';
pars.INFILE_DELIM = '_DS_';
pars.OUTFILE_DELIM = '_REF_';

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