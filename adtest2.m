function [h,p] = adtest2(x,y,varargin)
%ADTEST2  Return Anderson-Darling test for (x - y)
%
%  [h,p] = adtest2(x,y,'Name',value,...);
%
%  -- inputs --
%  x : Data vector to test
%  y : Either a vector of same size as x, or a scalar. Corresponding
%        elements of y will be subtracted from x, so they should be matched
%        up if y is a vector.
%  
%  -- output --
%  h : Test result (1 if reject null hypothesis of zero-mean normal 
%                   distribution; 0 if fail to reject)
%  p : Probability of result greater than or equal to test-statistic

if isempty(y)
   pd = makedist('Normal','mu',0,'sigma',1);
   [h,p] = adtest(x,varargin{:},...
         'Distribution',pd,...
         'Asymptotic',numel(x)>120); % Per documentation
elseif isscalar(y)
   if isnan(y)
      pd = makedist('Normal','mu',0,'sigma',1);
      [h,p] = adtest(x,varargin{:},...
         'Distribution',pd,...
         'Asymptotic',numel(x)>120); % Per documentation
   else
      x = x - y;
      [h,p] = adtest(x,varargin{:});
   end
else
   if all(isnan(y))
      pd = makedist('Normal','mu',0,'sigma',1);
   else
      pd = makedist('Normal','mu',nanmean(y),'sigma',nanstd(y));
   end
   [h,p] = adtest(x,varargin{:},...
      'Distribution',pd,...
      'Asymptotic',numel(x)>120); % Per documentation
end


end