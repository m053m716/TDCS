function [h,p] = signranktest(x,y,varargin)
%SIGNRANKTEST  Port to match ttest2 order of outputs

[p,h] = signrank(x,y,varargin{:});

end