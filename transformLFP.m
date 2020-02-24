function P_out = transformLFP(P_in,varargin)
%TRANSFORMLFP  Transform z-scored LFP for image scaling
%
%  P_out = transformLFP(f_in,t_in,P_in);
%  P_out = transformLFP(f_in,t_in,P_in,'param1',val1,...);
%
%  P_in  : Matrix of frequency power values ([numel(f_in) x numel(t)] dims)
%
%  Parameter names:
%  'KMIN'  : Minimum frequency bin value (Hz; default 2)
%  'KMAX'  : Maximum frequency bin value (Hz; default 202)
%  'K'     : Number of frequency bins
%
%  P_out : Matrix of frequency power values ([numel(f_out) x numel(t)])

pars = defs.LFP_Transform;
for iV = 1:2:numel(varargin)
   pars.(varargin{iV}) = varargin{iV+1};
end

fprintf(1,'Smoothing spectrogram...');
P_out = imgaussfilt(P_in,'FilterSize',[pars.GAUSS_ROWS,pars.GAUSS_COLS]);
fprintf(1,'<strong>complete</strong>\n');

end