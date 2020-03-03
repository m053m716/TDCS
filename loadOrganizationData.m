function [F,pars] = loadOrganizationData(varargin)
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
%  [F,pars] = ...
%  --> Also returns `pars` struct with other FileName paths info
%
%  -- outputs --
%  F: Struct array containing fields describing processing state,
%     inclusion state, condition/animal ID for a given recording, and other
%     path info specific to that recording.

pars = parseParameters('FileNames',varargin{:});

in = load(fullfile(pars.DIR,pars.DATA_STRUCTURE),'F');
F = in.F([in.F.included] &...
          ~isnan([in.F.animalID]) & ...
          ~isnan([in.F.conditionID]));

end