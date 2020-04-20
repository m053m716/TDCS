function data = loadDataStruct(dataTank,varargin)
%LOADDATASTRUCT  Loads `data` struct as defined in `main.m`
%
%  data = loadDataStruct();
%  --> Uses default `dataTank` from `+defs`
%
%  data = loadDataStruct(dataTank,'NAME',value,...);
%  --> Specify `dataTank` as char array of folder where data lives
%  --> Defaults for 'NAME' value pairs are from `+defs.FileNames.m`
%  
%  See also: main.m, loadOrganizationData.m

% Make sure correct repos are on path
addHelperRepos;

% Parse input
if nargin < 1
   dataTank = defs.FileNames('DIR');
end

pars = parseParameters('FileNames',varargin{:});

% Make data structure and begin loading data
data = struct;
loadingTic = tic;

% Load organization file data
[data.F,~,data.E] = loadOrganizationData();

% Load raw spike train data table
data.raw_spikes = loadFunction(dataTank,...
   pars.SPIKE_SERIES_TABLE,{'T'},'raw spikes');

% Load binned spike rate data table
data.binned_spikes = loadFunction(dataTank,...
   pars.SPIKE_SERIES_BINNED_TABLE,{'T'},'binned spike counts');

% Load change in spike rate data table
data.delta_spikes = loadFunction(dataTank,...
   pars.SPIKE_SERIES_DELTA_TABLE,{'T'},'changes in spike rate');

% Load LvR data table
data.LvR = loadFunction(dataTank,...
   pars.SPIKE_SERIES_LVR_TABLE,{'T'},'LvR data table');

% Load LFP data table
data.LFP = loadFunction(dataTank,...
   pars.LFP_TABLE,{'LFP'},'LFP data');

toc(loadingTic);

   % Helper functions
   function out = loadFunction(p,f,v,name)
      %LOADFUNCTION  Helper function to load data repeatedly
      %
      % out = loadFunction(p,f,v,name);
      %  --> `p` : Path to data (`dataTank`)
      %  --> `f` : Filename of data to load (file only, no path)
      %  --> `v` : Cell array of variables to load
      %  --> `name` : Name of data field (struct field name)
      %
      %  --> `out` : Output (loaded variable or struct of variables)
      
      if ~iscell(v)
         v = {v};
      end
      fprintf(1,'Loading %s...',strrep(name,'_',' '));
      in = load(fullfile(p,f),v{:});
      if numel(v) > 1
         out = struct;
         for iV = 1:numel(v)
            if isfield(in,v{iV})
               out.(name).(v{iV}) = in.(v{iV});
            else
               warning('Could not find variable: `%s` for %s',v{iV},name);
               out.(name).(v{iV}) = [];
            end
         end
      else
         if isfield(in,v{1})
            out = in.(v{1});
         else
            warning('Could not find variable: `%s` for %s',v{1},name);
            out = [];
         end
      end
      fprintf(1,'complete\n');
   end

end