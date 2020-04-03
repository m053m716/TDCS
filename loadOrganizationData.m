function [F,pars,E] = loadOrganizationData(varargin)
%LOADORGANIZATIONDATA  Loads data "organization struct" array (`F`)
%
%  F = loadOrganizationData();
%  --> Loads default `pars` from `defs.FileNames()`
%
%  F = loadOrganizationData(pars);
%  --> Override default `pars`
%
%  F = loadOrganizationData('NAME',value,...);
%  --> Modify 'NAME',value pairs of default `pars`
%
%  [F,pars,E] = ...
%  --> Also returns `pars` struct with other FileName paths info
%  --> E is a table matching elements of F, which contains STIM epoch start
%           and stop times (minutes) for recording blocks in F
%
%  -- outputs --
%  F: Struct array containing fields describing processing state,
%     inclusion state, condition/animal ID for a given recording, and other
%     path info specific to that recording.
%
%  pars : Parameters struct from `defs.FileNames`
%
%  E  : Data table for STIM epoch start/stop times (minutes)

pars = parseParameters('FileNames',varargin{:});

in = load(fullfile(pars.DIR,pars.DATA_STRUCTURE),'F');
F = in.F([in.F.included] &...
          ~isnan([in.F.animalID]) & ...
          ~isnan([in.F.conditionID]));
       
if nargout > 2
   in = load(fullfile(pars.DIR,pars.STIM_EPOCH_TABLE),'E');
   E = in.E;
end

end