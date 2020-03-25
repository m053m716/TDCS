function T = fixChannelIDs(T)
%FIXCHANNELIDS  Ensure all ChannelID is in range [8, 23]
%
%  T = fixChannelIDs(T);
%  T : Any table containing the `Channel` and `Name` variables

U = unique(T.Name);
for ii = 1:numel(U)
   idx = ismember(T.Name,U{ii});
   if min(T.Channel(idx)) < 8
      T.Channel(idx) = T.Channel(idx)+(8 - min(T.Channel(idx)));
   end
end


end