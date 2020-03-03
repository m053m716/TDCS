function addHelperRepos(paths)
% ADDHELPERREPOS  Adds all fields of paths to Matlab search path


f = fieldnames(paths);
for iF = 1:numel(f)
   if ~contains(path,paths.(f{iF}))
      addpath(genpath(paths.(f{iF})));
   end
end

end