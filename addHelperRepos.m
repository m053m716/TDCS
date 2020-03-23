function addHelperRepos(paths)
% ADDHELPERREPOS  Adds all fields of paths to Matlab search path

if nargin < 1
   paths = defs.Repos();
end

f = fieldnames(paths);
for iF = 1:numel(f)
   pathname = fullfile(paths.(f{iF}));
   if ~contains(path,pathname)
      addpath(genpath(pathname));
   end
   % Added this part for convenience with defs.Repos mismatch between lab
   % workstation and home desktop path setup
   if ~contains(path,pathname)
      p = strsplit(pathname,filesep);
      pathname = strjoin(p(2:end),filesep);
      if ~contains(path,pathname)
         addpath(genpath(pathname));
      end
   end
end

end