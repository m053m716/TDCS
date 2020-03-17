function T = loadSpikeTrains_Table(varargin)
%LOADSPIKETRAINS_TABLE  Load table with spike train data by channel
%
%  T = loadSpikeTrains_Table;
%  --> Uses parameters in defs.FileNames() to load file
%
%  T = loadSpikeTrains_Table('path/filename.mat');
%  --> Provide full filename
%
%  T = loadSpikeTrains_Table('path');
%  --> Gets rest of filename from defs.FileNames();

maintic = tic;
if nargin < 1
   [path,filename] = defs.FileNames('DIR','SPIKE_SERIES');
else
   if exist(varargin{1},'file')==2
      [path,f,e] = fileparts(varargin{1});
      filename = [f,e];
   elseif exist(varargin{1},'dir')==7
      path = varargin{1};
      filename = defs.FileNames('SPIKE_SERIES');
   end
end

if isempty(path)
   path = defs.FileNames('DIR');
end

if isempty(filename)
   filename = defs.FileNames('SPIKE_SERIES');
end

if exist(fullfile(path,filename),'file')==2
   in = load(fullfile(path,filename),'SpikeTrainData');
   T = in.SpikeTrainData(1:3); % Only load PRE - STIM - POST(1)
   toc(maintic);
   return;
end

filename = fullfile(path,defs.FileNames('SPIKE_SERIES'));
F = fullfile(path,filename);
if exist(F,'file')~=2
   error(['tDCS:' mfilename ':MissingFile'],...
            '<strong>[TDCS]:</strong> Could not find file: %s\n',F);
else
   in = load(fullfile(path,filename),'SpikeTrainData');
   T = in.SpikeTrainData(1:3); % Only load PRE - STIM - POST(1)
   toc(maintic);
   return;
end

end