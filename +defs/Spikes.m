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
pars.MIN_SIZE = 200000;              % Minimum summary file size (bytes)

% Related FileName parameters
[pars.DIR,pars.ASSIGNMENT_FILE,pars.FILE,pars.SUM_ID] = ...
   defs.FileNames('DIR','ASSIGNMENT_FILE','DATA_STRUCTURE','SUMMARY_TAG');

% Related (general) Experiment parameters
[pars.EPOCH_ONSETS,pars.EPOCH_OFFSETS,pars.EPOCH_NAMES,pars.DS_BIN_DURATION] = ...
   defs.Experiment('EPOCH_ONSETS','EPOCH_OFFSETS','EPOCH_NAMES','DS_BIN_DURATION');

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