function [f_out,t_out,P] = doLFPNormalization(F,f_in,t_in,S_in)
%DOLFPNORMALIZATION  Does normalization on LFP spectral data
%
%  [f_out,t_out,P] = doLFPNormalization(pathnames);
%  [f_out,t_out,P] = doLFPNormalization([],f_in,t_in,S_in);

pars = defs.LFP_Average('TMIN','TMAX','REZ','K','KMAX','KMIN');

if isempty(F)
   if nargin < 4
      if isstruct(f_in)
         t_in = f_in.t;
         S_in = f_in.P;
         f_in = f_in.f;
      else
         error(['TDCS:' mfilename ':BadInputs'],...
            'If providing data directly, must specify all 3 data args.');
      end
   end
   N = 1;
   p = nan(size(S_in,1),size(S_in,2),N);
else
   N = numel(F);
   T = (pars.TMIN*60):(pars.REZ*1e-3):(pars.TMAX*60);
   p = nan(pars.K,numel(T),N);
end
f_out = logspace(log10(pars.KMIN),log10(pars.KMAX),pars.K);

for iCh = 1:N
   if ~isempty(F)
      indata = load(F{iCh},'amp','fs','pars');
      S_in = indata.amp;
      f_in = indata.pars.FREQS;
      t_out = indata.pars.NSAMP_PER_WIN/indata.fs;
      fprintf(1,'Normalizing file %d of %d...',iCh,numel(F));
   else
      fprintf(1,'Normalizing spectrum...');
      t_out = t_in;
   end
   
   % Do transformation on power data
   S_in = log(S_in);

   % Interpolate vector so all time series match up
   p(:,:,iCh) = (S_in-nanmean(S_in,2)) ./ nanstd(S_in,[],2);
   fprintf(1,'complete\n');
end

P = nanmean(p,3);
idx = any(isnan(P),1);
P(:,idx) = [];
t_out(idx) = [];

end