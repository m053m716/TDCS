function S = deltaSamples2Rows(T)
%DELTASAMPLES2ROWS  Convert `delta_sqrt_Stim` variable to rows of table
%
%  S = deltaSamples2Rows(T);
%
%  T : Table from `compute_delta_FR`
%  
%  S : Same as T, but only has `delta_sqrt_Stim` (no `mask`,
%           `delta_sqrt_Rate`, etc) and has one row for every sample in
%           `delta_sqrt_Stim`

n = cellfun(@numel,T.delta_sqrt_Stim);
N = sum(n);

BlockID = nan(N,1);
AnimalID = nan(N,1);
ConditionID = nan(N,1);
CurrentID = nan(N,1);
Channel = nan(N,1);
delta_sqrt_Stim = nan(N,1);

vec = 0;
for ii = 1:size(T,1)
   if n(ii) == 0
      continue;
   end
   vec = (vec(end)+1):(vec(end)+n(ii));
   BlockID(vec,1) = T.BlockID(ii);
   AnimalID(vec,1) = T.AnimalID(ii);
   ConditionID(vec,1) = T.ConditionID(ii);
   CurrentID(vec,1) = T.CurrentID(ii);
   Channel(vec,1) = T.Channel(ii);
   delta_sqrt_Stim(vec,1) = T.delta_sqrt_Stim{ii}.';
end
top_responder = zeros(N,1);
n_responsive_per_tail = round(0.05 * N);
[~,iTop] = sort(delta_sqrt_Stim,'descend');
[~,iBot] = sort(delta_sqrt_Stim,'ascend');
iResponds = [iTop(1:n_responsive_per_tail),iBot(1:n_responsive_per_tail)];
top_responder(iResponds) = 1;

S = table(BlockID,AnimalID,ConditionID,CurrentID,Channel,...
   delta_sqrt_Stim,top_responder);
S.Properties.Description = T.Properties.Description;
S.Properties.UserData = T.Properties.UserData;


end