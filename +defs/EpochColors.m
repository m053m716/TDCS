function c = EpochColors(varargin)
%EPOCHCOLORS  Return colors matched to each named epoch
%
%  c = defs.EpochColors('epoch1','epoch2',...);
%  >> c = defs.EpochColors('STIM','BASAL','BASAL');
%  * would return c = [0.80,0.25,0.15;0.25,0.25,0.25;0.25,0.25,0.25]
%  * each row is matched to an input arg

C_KEY = struct(...
   'BASAL',[0.25 0.25 0.25],...  % grey
   'STIM',[0.80 0.25 0.15],...   % red
   'POST1',[0.30 0.30 1.00], ... % blue (lightest)
   'POST2',[0.20 0.20 0.95], ... % blue
   'POST3',[0.10 0.10 0.90], ... % blue
   'POST4',[0.00 0.00 0.85]  ... % blue (darkest)
   );

F = fieldnames(C_KEY);
c = zeros(nargin,3);
for i = 1:nargin
   idx = ismember(F,varargin{i});
   if sum(idx)~=1
      warning(['TDCS:' mfilename ':BadEpoch'],...
         'No such color field: %s\n',varargin{i});
   else
      c(i,:) = C_KEY.(F{idx});
   end
end

end