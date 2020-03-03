function varargout = Spikes(varargin)
%SPIKES  Defaults for TDCS Spikes
%
%  pars = defs.Spikes();
%  [var1,var2,...] = defs.Spikes('var1Name','var2Name',...);

pars = struct;
pars.MIN_N_SPK = 570; % = 0.1 Hz over 95 minutes
pars.ANIMAL_COLUMN = 9;
pars.CONDITION_COLUMN = 10;
pars.USE_RAT = true;
pars.MIN_RATE = 0.1;
pars.GROUPS = {...
   'BASAL', ...
   'STIM', ...
   'POST1', ...
   'POST2', ...
   'POST3', ...
   'POST4'};
pars.BINVEC = -3:0.1:3;
pars.DIR = 'P:\Rat\tDCS';                                  % Data directory
pars.ASSIGNMENT_FILE = defs.FileNames('ASSIGNMENT_FILE');
pars.FILE = defs.FileNames('DATA_STRUCTURE');  % Data struct file
pars.SUM_ID = '_SpikeSummary.mat';   % Spike summary file ID
pars.MIN_SIZE = 200000;              % Minimum summary file size (bytes)

% Experiment parameters
[pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS] = defs.Experiment('EPOCH_ONSETS','EPOCH_OFFSETS');

% Used in `FindSigUnits.m`:
pars.MIN_SPIKES_X = 900;
pars.MIN_SPIKES_Y = 1200;
pars.MAX_ISI = 3000;
pars.DIST_TO_FIT = 'Gamma';

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