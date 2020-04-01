function [h,p] = alltests(x,y,varargin)
%ALLTESTS  Returns "consensus" of all statistical tests
%
%  [h,p] = alltests(x,y,'Name',value,...);
%  [h,p] = alltests(x,y,alpha,'Name',value,...);
%
%  Tests include:
%  * kstest2
%  * adtest2
%  * ranksumtest
%  * ttest2
%
%  h is based on max[p] (supremum given all tests) being less than alpha

pars = struct('Alpha',0.01); % Default Alpha
if nargin >= 3
   if isnumeric(varargin{1})
      pars.Alpha = varargin{1};
      varargin(1) = [];
   end
end

for iV = 1:2:numel(varargin)
   pars.(varargin{iV}) = varargin{iV+1};
end

p = ones(1,4);
[~,p(1)] = kstest2(x,y,varargin{:});
[~,p(2)] = adtest2(x,y,varargin{:});
[~,p(3)] = ranksumtest(x,y,varargin{:});
[~,p(4)] = ttest2(x,y,varargin{:});
p = max(p); % Use "supremum" of significance test results
h = p <= pars.Alpha;

end