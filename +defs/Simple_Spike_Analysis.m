function varargout = Simple_Spike_Analysis(varargin)
%SIMPLE_SPIKE_ANALYSIS  Defaults for Basic spike analyses
%
%  pars = defs.Simple_Spike_Analysis();
%  [var1,var2,...] = defs.Spikes('var1Name','var2Name',...);

pars = struct;
% DEFAULTS
pars.ISTART = [];
pars.ISTOP = [];
pars.TSTART = [];
pars.TSTOP = [];
pars.LIB_DIR = 'libs';        % Library directory for added functions
pars.USE_START_STOP = false;  % Use 'START' and 'STOP' times in save name
pars.RAT_START = 1;           % Starting index of RAT in block name
pars.RAT_END = 6;             % Ending index of RAT in block name
pars.SAVE_SNIPS = false;      % Save spike snippets associated with each peak?
% (for tDCS, change to 5)

% Warning suppression
pars.W_ID = 'MATLAB:load:variableNotFound';
pars.SAVE_DIR = '';
pars.INSERT_TAG = '';

% Names of directories where spikes are kept
pars.SPK_DIR = '_wav-sneo_CAR_Spikes';
pars.SUB_DIR = '';
pars.SAVE_ID = '_SpikeSummary.mat';

% Table properties parameters
pars.VAR_DESCRIPTIONS_DATA = ...
   {'Name of animal',            ...
   'Recording block name',      ...
   'Probe channel number',      ...
   'Putative unit cluster',     ...
   'Number of observed spikes', ...
   'Recording duration',        ...
   'Average trial spike rate',  ...
   'Burstiness or Uniformity of spike rate (LvR)'};
pars.VAR_UNITS_DATA = ...
   {'','','','', ...
   'Spikes','Seconds',...
   'Spikes per Second','LvR'};
pars.DATASET_DESCRIPTION_DATA = 'General spike data information';

pars.VAR_DESCRIPTIONS_SPK = ...
  {['Sparse matrix with pairs that correspond to spike sample ' ...
   'indices and their peak-to-peak amplitudes'],                ...
   ['Snippets of the waveforms corresponding to'                ...
    'putative action potentials'],                              ...
   'Sampling frequency'};
pars.VAR_UNITS_SPK = {'Sample,P2P Amplitude','uV','Hz'};
pars.DATASET_DESCRIPTION_SPK = 'Sorted extracted spike data';

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