function pars = parseParameters(defFile,varargin)
%PARSEPARAMETERS  Parse input default parameters of `defFile`
%
%  pars = parseParameters(defFile);
%  --> Uses file in `+defs/<defFile>.m` to get parameters struct
%
%  pars = parseParameters(defFile,pars);
%  --> Assigns pars directly
%
%  pars = parseParameters(defFile,varargin{:});
%  --> Uses file in `+defs/<defFile>.m` to get parameters struct
%     --> Modifies parameter struct using `'NAME',value,...` syntax

switch numel(varargin)
   case 0
      pars = defs.(defFile)();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.(defFile)();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

end