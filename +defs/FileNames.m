function varargout = FileNames(varargin)
%FILENAMES  Names of various files saved on KUMC server
%
%  pars = defs.FileNames();
%  [var1,var2,...] = defs.SpikeStats('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.DIR = 'P:\Rat\tDCS';
pars.RATE_CHANGES = '2017-07-18_Rate Changes.mat';
pars.WORKSPACE = '2017-07-20_tDCS Workspace.mat';
pars.SPIKE_SERIES = '2017-11-22_Updated Spike Series.mat';
pars.LFP = '2017-07-13_LFP Data.mat';
pars.DATA_STRUCTURE = '2017 TDCS Data Structure Organization.mat';
pars.EPOCH_DATA = '2017-06-17_Concatenated Epoch Data.mat';

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