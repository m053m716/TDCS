function [cb,mu,sd] = mat2cb(data,dim,nSD)
%MAT2CB  Returns lower and upper limits on confidence bounds of data matrix
%
%  cb = eqn.mat2cb(data);
%  --> data : Data matrix to return confidence bounds on
%  --> By default, operates along dim == 1 (treats columns as groups of
%      data points used to compute mean and standard deviation)
%  --> By default, computes bounds using nSD = 1 (mean +/- 1 standard
%        deviation).
%
%  cb = eqn.mat2cb(data,dim,nSD);
%  --> `dim` : (optional) scalar dimension along which to operate
%  --> `nSD` : (optional) # of standard deviations
%
%  [cb,mu,sd] = eqn.mat2cb(__);
%  --> Optionally, return mean 
%        * (mu; computed using nanmean)
%  --> Optionally, return standard deviation by sample 
%        * (sd; computed using nanstd)

if nargin < 2
   dim = 1;
else
   if dim > 2
      error(['tDCS:' mfilename ':InvalidInput'],...
         '\n\t->\t<strong>[MAT2CB]:</strong> `dim` must be 1 or 2');
   end
end

if nargin < 3
   nSD = 1;
else
   nSD = nSD(1);
end

sd = nanstd(data,[],dim) .* nSD;
mu = nanmean(data,dim);

cb = cat(dim,mu-sd,mu+sd);
end