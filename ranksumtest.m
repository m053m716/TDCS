function [h,p] = ranksumtest(x,y,varargin)
%RANKSUMTEST  Port to match ttest2 order of outputs
%
%  [h,p] = ranksumtest(x,y,'Name',value,...);

[p,h] = ranksum(x,y,varargin{:});

end