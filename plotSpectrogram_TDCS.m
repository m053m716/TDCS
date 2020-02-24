function [fig,lfp,acc] = plotSpectrogram_TDCS(blockNum,LFP_Table,lfp)
%PLOTSPECTROGRAM_TDCS  Plot spectral power given a block number
%
%  [fig,lfp] = PLOTSPECTROGRAM_TDCS(blockNum);
%  [fig,lfp] = PLOTSPECTROGRAM_TDCS(blockNum,LFP_Table);
%  [fig,lfp,acc] = PLOTSPECTROGRAM_TDCS(blocknum,lfp);
%
%  in--
%  blockNum  : Number of block (e.g. 85 for 'TDCS-85')
%  LFP_Table : (Optional) As returned by PARSELFP_TABLE();
%
%  OR
%
%  lfp       : (Optional; skips interpolation) Struct with fields
%              * 'f' (as defined in output)
%              * 't' (as defined in output)
%              * 'P' (as defined in output)
%
%  out--
%  fig      :     Figure handle
%  lfp      :     Struct with following fields:
%     -> f  :       1 x N vector of frequency bin centers for rows of P
%     -> t  :       1 x T vector of time "centers" for columns of P
%     -> P  :       N x T matrix of (normalized) average spectral power
%  acc      :     Accelerometery data struct

if nargin < 2
   LFP_Table = parseLFP_Table(); % Load using defaults
elseif isstruct(LFP_Table)
   lfp = LFP_Table;
   LFP_Table = table.empty();
else
   % Get matched table indices
   idx = ismember(LFP_Table.Rec,blockNum);
end

% Parse name and make figure
if ischar(blockNum)
   iToken = regexp(blockNum,'TDCS-','once')+5;
   blockNum = str2double(blockNum(iToken:(iToken+1)));
end
name = sprintf('TDCS-%02g',blockNum);
fig = figure('Name',[name ': LFP and Accelerometer Data'],...
   'NumberTitle','off',...
   'Color','w',...
   'Units','Normalized',...
   'Position',defs.Experiment('TALL_FIG_RAND')); 

ax_top = axes(fig,...
   'XColor','k',...
   'YColor','k',...
   'LineWidth',2.0,...
   'FontName','Arial',...
   'Units','Normalized',...
   'Position',defs.Experiment('TOP_AXES'),...
   'NextPlot','add');

if isfield(lfp,'f') && isfield(lfp,'t') && isfield(lfp,'P')
   [lfp.f,lfp.t,~,~,lfp.P] = mmAverageLFP(ax_top,lfp);
else
   lfp = struct;
   
   [lfp.f,lfp.t,~,~,lfp.P] = mmAverageLFP(ax_top,LFP_Table(idx,:).FileName(:));
end

ax_bot = axes(fig,...
   'XColor','k',...
   'YColor','k',...
   'LineWidth',2.0,...
   'FontName','Arial',...
   'Units','Normalized',...
   'Position',defs.Experiment('BOT_AXES'),...
   'NextPlot','add');

acc = loadAccelerometeryData(name);
if isempty(acc)
   fprintf(1,'<strong>Missing:</strong> accelerometer data for %s\n',name);
   return;
end

h = plotAccelerometeryData(acc,ax_bot);
set(h,...
   'XData',lfp.t/60,... % minutes
   'YData',nansum(lfp.P,1)/size(lfp.P,1),...
   'LineStyle',':',...
   'LineWidth',0.75,...
   'Color',[0.55 0.55 0.55]);
set(ax_bot,...
   'XLim',[5 95],...
   'YLim',get(ax_top,'CLim'),...
   'Children',flipud(ax_bot.Children)); % Flip children ordering


end