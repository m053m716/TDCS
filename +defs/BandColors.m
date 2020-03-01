function c = BandColors(varargin)
%BANDCOLORS  Return colors matched to each named frequency band
%
%  c = defs.EpochColors('epoch1','epoch2',...);
%  >> c = defs.EpochColors('STIM','BASAL','BASAL');
%  * would return c = [0.80,0.25,0.15;0.25,0.25,0.25;0.25,0.25,0.25]
%  * each row is matched to an input arg

C_KEY = struct(...
   'Delta',[0.05 0.05 0.70],...    % dark blue
   'Theta',[0.25 0.25 0.85],...    % light blue
   'Alpha',[0.70 0.05 0.05], ...   % dark red
   'Beta',[0.85 0.25 0.25], ...    % light red
   'Low_Gamma',[0.05 0.70 0.05], ...  % dark green
   'High_Gamma',[0.25 0.85 0.25]  ... % light green
   );

if nargin == 0
   varargin = {'Delta','Theta','Alpha','Beta','Low_Gamma','High_Gamma'};
end

F = fieldnames(C_KEY);
c = zeros(numel(varargin),3);
for i = 1:numel(varargin)
   idx = ismember(F,varargin{i});
   if sum(idx)~=1
      warning(['TDCS:' mfilename ':BadEpoch'],...
         'No such color field: %s\n',varargin{i});
   else
      c(i,:) = C_KEY.(F{idx});
   end
end

end