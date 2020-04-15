function varargout = XCorr(varargin)
%XCORR  Defaults for TDCS Cross-correlation analyses
%
%  pars = defs.XCorr();
%  [var1,var2,...] = defs.XCorr('var1Name','var2Name',...);

pars = struct;

% Group info
[pars.RMS_THRESH, ...
 pars.N,...
 pars.NSD_THRESH,...
 pars.TRANSFORM_FCN] = ...
      defs.Experiment(...
         'RMS_THRESH',...
         'RATE_SAMPLES_PER_XCORR',...
         'RATE_NSD_THRESH',...
         'RATE_TRANSFORM_FCN'...
         );
pars.OVERLAP = pars.N - 1; % # binned rate samples to overlap
pars.ParameterDescriptions = struct(...
   'RMS_THRESH','Threshold for setting RMS Mask',...
   'N','Number of spike rate samples per xcorr window',...
   'NSD_THRESH','Threshold for # standard deviations to set artifact reject window above median',...
   'TRANSFORM_FCN','Spike rate transform function',...
   'BINNED_SPIKES_TABLE_PARS','Original `data.binned_spikes` table parameters'...
   );

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