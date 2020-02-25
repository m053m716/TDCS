function varargout = extract_common_average(varargin)
%EXTRACT_COMMON_AVERAGE   Pars for `extract_common_average` function
%
%  pars = defs.extract_common_average();
%  [var1,var2,...] = defs.extract_common_average('var1','var2',...);

pars = struct;
% DEFAULTS
% Folder identifiers
pars.INFILE_TYPE_TAG = '_Filtered'; % Input file "type" tag/identifier
pars.OUTFILE_TYPE_TAG = '_FilteredCAR'; % Output file "type" tag/identifier
pars.INFILE_CHANNEL_TOKEN = '_Ch_'; % Input file channel token indicator; truncates output name before this
pars.INFILE_DELIM = '_Filt_'; % Part that allows recovery of "block" name
pars.OUTFILE_DELIM = '_REF_'; % This will replace INFILE_DELIM in output name

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