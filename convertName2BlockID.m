function BlockID = convertName2BlockID(Name)
%CONVERTNAME2BLOCKID  Utility to convert cell char 'TDCS' name to Block ID
%
%  BlockID = convertName2BlockID(Name);

BlockID = cellfun(@(C)str2double(C((regexp(C,'-','once')+1):end)),Name);
end