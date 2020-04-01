function T = fixChannelIDs(T)
%FIXCHANNELIDS  Ensure all ChannelID is in range [8, 23]
%
%  T = fixChannelIDs(T);
%  T : Any table containing the `Channel` and `Name` variables

if ismember('Rat',T.Properties.VariableNames)
   blockNameID = 'Rat';
elseif ismember('Name',T.Properties.VariableNames)
   blockNameID = 'Name';
else
   blockNameID = 'BlockID';
end

if ismember('Channel',T.Properties.VariableNames)
   channelNameID = 'Channel';
else
   channelNameID = 'ChannelID';
end

U = unique(T.(blockNameID));
if ~iscell(U)
   U = num2cell(U);
end
for ii = 1:numel(U)
   idx = ismember(T.(blockNameID),U{ii});
   if min(T.(channelNameID)(idx)) < 8
      C = T.(channelNameID)(idx);
      T.(channelNameID)(idx) = C + (8 - min(C));
   end
end


end