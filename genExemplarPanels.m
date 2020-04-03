function fig = genExemplarPanels(figName,raw,filt,sneo,spike,iCondition)
%GENEXEMPLARPANELS  Generate exemplar panels for TDCS project
%
%  fig = genExemplarPanels(figName,raw,filt,sneo,spike);
%  --> See `getExemplar` for what each of these should be;
%   -> figName : char array figure name
%   -> raw : Raw data struct with fields 
%                 * 'data', 't'
%   -> filt : Filtered data struct with fields 
%                 * 'data', 't'
%   -> sneo : Smoothed nonlinear energy operator struct with fields
%                 * 'data','t','threshold'
%   -> spike : Spike times struct with fields
%                 * 'peakIndices','peakValues','peakTimes','threshold'
%
%  fig = genExemplarPanels(figName,raw,filt,sneo,spike,iCondition);
%  --> iCondition: By default, NaN (no condition highlight)
%
%     ## Mapping iCondition ##
%        1 : +0.4 mA
%        2 : +0.2 mA
%        3 :  0.0 mA
%        4 : -0.2 mA
%        5 : -0.5 mA

if nargin < 6
   iCondition = nan;
end

TITLE_LAB = {'Pre - Stim';...% First column
             'Stim - Post'}; % Second column 

fig = figure(...
   'Name',figName,...
   'Units','Normalized',...
   'Color','w',...
   'Position',[0.35 0.1 0.3 0.7]...
   );

% % % TOP AXES - RAW ACTIVITY % % %
for i = 1:numel(raw)
   ax = subplot(2,2,i);
   line(ax,raw(i).t,raw(i).data,...
      'Color','k',...
      'LineWidth',1.5,...
      'DisplayName','Raw Activity');
   hold on;
   ax.LineWidth = 1;
   yyaxis(ax,'right'); % Switch to right-hand axes
   addCurrentIndicator(ax,raw(i),iCondition);
   ylim(ax,[-0.5 0.5]);
   ax.YTick = [-0.4 -0.2 0 0.2 0.4];
   ax.YColor = ones(1,3) .* 0.8;
   ax.LineWidth = 1;
   if i == numel(raw)
      ylabel(ax,'Intensity (mA)','FontName','Arial','Color','k','FontSize',12);
   end
   
   yyaxis(ax,'left'); % Switch back to left-hand axes
   ax.YTick = [-200 0 200];
   ax.YColor = [0 0 0]; % Left-hand axes color is black
   
   ax.XColor = ones(1,3) .* 0.8; % Time-scale matches digital indicator
   ax.XTick = raw(i).epoc.ticks;
   ax.XTickLabels = raw(i).epoc.ticklabels;
   xlabel(ax,'Time (min)','FontName','Arial','Color','k','FontSize',12);
   
   ax.FontName = 'Arial';
   ylim(ax,[-400 200]);
   xlim(ax,[raw(i).t(1) raw(i).t(end)]);
   if i == 1
      ylabel(ax,'Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   end
   title(ax,TITLE_LAB{i},'FontName','Arial','Color','k','FontSize',14);

end

% % % BOTTOM AXES - UNIT ACTIVITY % % %
for i = 1:numel(filt)
   ax = subplot(2,2,i+numel(filt));
   filt_data = line(ax,filt(i).t,filt(i).data,...
      'Color','k',...
      'LineWidth',1.5,...
      'LineStyle','-',...
      'DisplayName','Unit Activity');

   hold on;
   spike_times = line(ax,spike(i).peakTimes,-spike(i).peakValues,...
      'Color',[0 0 1],...
      'LineStyle','none',...
      'Marker','*',...
      'MarkerFaceColor','b',...
      'MarkerEdgeColor','b',...
      'Displayname','Spikes'...
      );
   th = -ones(1,numel(filt(i).t)).*spike(i).threshold;
   spike_thresh = line(ax,filt(i).t,th,...
      'Color',[0 0 0.8],... % Darker blue
      'LineWidth',1.5,...
      'LineStyle','--',...
      'DisplayName','Unit Threshold');
   ax.YTick =  [-100 0 100];
   ax.LineWidth = 1;
   ax.YColor = [0 0 0]; % Black
   if i == 1
      ylabel(ax,'Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   end
   yyaxis(ax,'right')
   sneo_data = line(ax,sneo(i).t,sneo(i).data,...
      'Color','r',...
      'LineWidth',1.5,...
      'LineStyle',':',...
      'DisplayName','SNEO');
   hold on;
   th = ones(1,numel(sneo(i).t)).*sneo(i).threshold;
   sneo_thresh = line(ax,sneo(i).t,th,...
      'Color',[0.8 0 0],...
      'LineWidth',1.5,...
      'LineStyle','--',...
      'DisplayName','SNEO Threshold');
   sneo_max = max(sneo(i).data);
   ylim(ax,[-2500, 2500]);
   ax.YScale = 'log';
   ax.YTick = [0 10 100 1000];
   ax.YColor = [1 0 0]; % Red
   ax.LineWidth = 1;
   if i == numel(filt)
      ylabel(ax,'SNEO (a.u.)','FontName','Arial','Color','k','FontSize',12);
      lg = legend([filt_data,spike_times,spike_thresh,sneo_data,sneo_thresh]);
      lg.Orientation = 'Horizontal';
      lg.Position = [0.20 0.45 0.60 0.05];
      lg.TextColor = 'black';
      lg.FontName = 'Arial';
      lg.Color = 'none';
      lg.FontSize = 8;
      lg.Box = 'off';
   end
   xlabel(ax,'Time (sec)','FontName','Arial','Color','k','FontSize',12);
   ax.XColor = [0 0 0]; % Set X-Color to black
   ax.FontName = 'Arial';
   yyaxis(ax,'left');
   ylim(ax,[-125 125]);
   xlim(ax,[filt(i).t(1) filt(i).t(end)]);
end

% Apply main title
str = strrep(figName,'_',' - '); % Fix for LaTeX formatting
suptitle(str); % Print name of figure on figure as well

   function addCurrentIndicator(ax,s,iThis)
      %ADDCURRENTINDICATOR  Add line indicating current amplitude
      %
      %  addCurrentIndicator(ax,s);
      %  addCurrentIndicator(ax,s,iThis);
      %  --> Index indicating the condition for THIS exemplar
      %   -> Indicated line will be highlighted in yellow-orange
      
      % Parse input
      if nargin < 3
         iThis = nan;
      end
      
      % Defaults
      % Colors
      COL = ones(1,3) .* 0.8; % Standard: light-grey
      HL = [1.0 0.6 0.0];     % Highlight: yellow-orange
      % Line-widths
      LW = [3.00; ...         % Thickest:  0.4 mA
            1.75; ...         % Medium  :  0.2 mA
            1.00; ...         % Thinnest:  0.0 mA
            1.75; ...         % Medium  : -0.2 mA
            3.00];            % Thickest: -0.4 mA
      
      % Add all 5 lines
      for k = 1:5
         if isequal(k,iThis)
            line(ax,s.epoc.t,s.epoc.Y(k,:),...
               'LineStyle','-',...
               'LineWidth',LW(k),...
               'Color',HL);
         else
            line(ax,s.epoc.t,s.epoc.Y(k,:),...
               'LineStyle','-',...
               'LineWidth',LW(k),...
               'Color',COL);
         end
            
      end
   end

end