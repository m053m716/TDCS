function T = export_LFP_bandpower__rm_stats(F,varargin)
%EXPORT_LFP_BANDPOWER__RM_STATS Export LFP RMS for repeated-measures
%
%  T = EXPORT_LFP_BANDPOWER__RM_STATS(F);
%  --> Uses `defs.LFP()` to obtain `pars`
%
%  T = EXPORT_LFP_BANDPOWER__RM_STATS(F,pars); 
%  --> Assign `pars` directly
%
%  T = EXPORT_LFP_BANDPOWER__RM_STATS(F,'NAME',value,...);
%  --> Uses `defs.LFP()` to obtain `pars`
%     --> Updates fields of `pars` using 'NAME',value,... syntax
%
%  -- outputs --
%  T : Table of stats data that is exported to SQL database

% Iterate on all elements of "organization" struct array
if numel(F) > 1
   % Exclude any "bad" elements of F
   F = F([F.included] & ~isnan([F.animalID]) & ~isnan([F.conditionID]));
   
   if nargout > 0
      T = [];
   end
   for i = 1:numel(F)
      if nargout > 0
         T = [T; export_LFP_bandpower__rm_stats(F(i),varargin{:})];  %#ok<AGROW>
      else
         export_LFP_bandpower__rm_stats(F(i),varargin{:});
      end
   end
   return;
end

% If this is an excluded element, then skip it
if ~F.included
   fprintf(1,'\t\t->\t%s skipped\n',F.base);
   T = [];
   return;
end

% Parse input parameters for LFP
pars = parseParameters('LFP',varargin{:});

% Variables from organization struct
ds_dir = F.wav.ds;
block = F.block;
name = F.base;

% Load LFP data (if present)
f = dir(fullfile(ds_dir,[name pars.LFP_DATA_TAG '*.mat']));
if isempty(f)
   fprintf(1,'\t->\t<strong>Missing %s file</strong>\n',pars.LFP_DATA_TAG);
   fprintf(1,'\t\t->\t%s skipped\n\n',F.base);
   return;
else
   fprintf(1,'\t->\t<strong>LFP power</strong> (%s)...loading...',name);
   lfp = load(fullfile(f(1).folder,f(1).name),'data','fs');
   fs = lfp.fs;
   fprintf(1,'\b\b\b\b\b\b\b\b\b\bcomputing...');
end

rmsdata = load(fullfile(block,sprintf(pars.RMS_MASK_FILE,name)),'mask');
F.conditionID = ceil(F.conditionID/2);
T = extract_LFP_bands(lfp.data,rmsdata.mask,fs,F,pars);

end