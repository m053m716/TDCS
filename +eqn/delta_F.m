function dF = delta_F(Ft,Fpre)
%DELTA_F  Based on Bogaard et al 2019 for computing change in spike rate
%
%  dF = eqn.delta_F(Fstim,Fpre);
%
%  Ft    : Spike rate at time t (sqrt(spikes)/second)
%  Fpre  : MEDIAN Spike rate (sqrt(spikes)/second) during pre-stimulation epoch
%
%  dF    : Change in spike rate (bound between -100 and 100)

if numel(Ft) > 1
   if numel(Fpre) ~= numel(Ft)
      error(['tDCS:' mfilename ':BadInputSizes'],...
         ['<strong>[TDCS]:</strong> ' ...
         'Expected Ft and Fpre to have same input dimensions.']);
   end
   dF = zeros(size(Ft));
   for ii = 1:numel(Ft)
      dF(ii) = eqn.delta_F(Ft(ii),Fpre(ii));
   end
   return;
end

dF = 100 * (Ft - Fpre) / max(Ft,Fpre); 

end