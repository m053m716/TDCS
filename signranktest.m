function [h,p] = signranktest(x,y,varargin)
%SIGNRANKTEST  Port to match ttest2 order of outputs
%
%  [h,p] = signranktest(x,y,'Name',value,...);

if numel(x) ~= numel(y)
   if isscalar(y)
      y = ones(size(x)) .* y;
   elseif isempty(y)
      y = [];
   else
      y = nanmedian(y);
      if isnan(y)
         y = [];
      else
         y = ones(size(x)) .* y;
      end
   end
end

[p,h] = signrank(x,y,varargin{:});

end