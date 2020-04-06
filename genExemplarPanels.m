function fig = genExemplarPanels(figName,raw,filt,sneo,spike,pars)
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
%  fig = genExemplarPanels(figName,raw,filt,sneo,spike,pars);
%  --> pars : Condition-specific parameters struct
%   -> iThis : By default, NaN (no condition highlight)
%   -> C : Color ([1 x 3] double in range [0,1], for this condition)
%
%     ## Mapping iThis ##
%        1 : +0.4 mA
%        2 : +0.2 mA
%        3 :  0.0 mA
%        4 : -0.2 mA
%        5 : -0.5 mA

if nargin < 6
   pars = struct('iThis',nan,'C',[0.9 0.9 0.9],'doCurrentLines',true);
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
   xl_this = [raw(i).t(1), raw(i).t(end)];
   xlim(ax,xl_this);
   line(ax,raw(i).t,raw(i).data,...
      'Color','k',...
      'LineWidth',1.5,...
      'DisplayName','Raw Activity');
   hold on;
   ax.LineWidth = 1;
   yyaxis(ax,'right'); % Switch to right-hand axes
   addCurrentIndicator(ax,raw(i).epoc,pars); % Add current intensity lines
   ylim(ax,[-0.5 0.5]);
   xlim(ax,xl_this);
   ax.YTick = [-0.4 -0.2 0 0.2 0.4];
   ax.LineWidth = 1;
   if i == numel(raw)
      ax.YColor = ones(1,3) .* 0.8;
      ylabel(ax,'Intensity (mA)','FontName','Arial','Color','k','FontSize',12);
   else
      ax.YColor = 'none';
   end
   
   yyaxis(ax,'left'); % Switch back to left-hand axes
   ax.YTick = [-400 -200 0 200 400];   
   ax.XColor = ones(1,3) .* 0.8; % Time-scale matches digital indicator
   ax.XTick = raw(i).epoc.ticks;
   ax.XTickLabels = ...
      {sprintf('%3.1f',raw(i).epoc.ticklabels(1)),...
       sprintf('%3.1f',raw(i).epoc.ticklabels(2))};
   xlabel(ax,'Time (min)','FontName','Arial','Color','k','FontSize',12);
   
   ax.FontName = 'Arial';
   ylim(ax,[-500 500]);
   xlim(ax,[raw(i).t(1) raw(i).t(end)]);
   if i == 1
      ax.YColor = [0 0 0];
      ylabel(ax,'Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   else
      ax.YColor = 'none';
   end

end

% % % BOTTOM AXES - UNIT ACTIVITY % % %
pars.doCurrentLines = false; % Don't add "Current line" indicators
for i = 1:numel(filt)
   ax = subplot(2,2,i+numel(filt));
   filt_data = line(ax,filt(i).t,filt(i).data,...
      'Color','k',...
      'LineWidth',1.5,...
      'LineStyle','-',...
      'DisplayName','Unit Activity');
   hold on;
   xl_this = [filt(i).t(1) filt(i).t(end)];
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
   yyaxis(ax,'right');
   ax.LineWidth = 1;
   sneo_data = line(ax,sneo(i).t,sneo(i).data,...
      'Color','r',...
      'LineWidth',1.5,...
      'LineStyle',':',...
      'DisplayName','SNEO');
   th = ones(1,numel(sneo(i).t)).*sneo(i).threshold;
   sneo_thresh = line(ax,sneo(i).t,th,...
      'Color',[0.8 0 0],...
      'LineWidth',1.5,...
      'LineStyle','--',...
      'DisplayName','SNEO Threshold');
   ax.YScale = 'log';
   ylim(ax,[0 2500]);
   xlim(ax,xl_this);   
   ax.YTick = [0 1000];
   if i == numel(filt)
      ax.YColor = [1 0 0]; % Red
      ylabel(ax,'SNEO (a.u.)','FontName','Arial','Color','k','FontSize',12);
   else
      ax.YColor = 'none';
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
   xlim(ax,xl_this);
   ax.YTick =  [-100 0 100];
   ax.LineWidth = 1;     
   if i == numel(filt)
      ax.YColor = 'none';
   else
      ax.YColor = [0 0 0];
      ylabel(ax,'Amplitude (\muV)','FontName','Arial','Color','k','FontSize',12);
   end
%    addCurrentIndicator(ax,raw(i).epoc,pars); % Add "epoch patches" only
end

% Apply main title
str = strrep(figName,'_',' - '); % Fix for LaTeX formatting
suptitle(str); % Print name of figure on figure as well

   function addCurrentIndicator(ax,s,pars)
      %ADDCURRENTINDICATOR  Add line indicating current amplitude
      %
      %  addCurrentIndicator(ax,s);
      %  addCurrentIndicator(ax,s,pars);
      %  --> pars : Struct with fields:
      %  + 'iThis'
      %    -> Index indicating the condition for THIS exemplar
      %     -> Indicated line will be highlighted in yellow-orange
      %  + 'C'
      %    -> [1 x 3] double color vector matching this condition
      
      % Parse input
      if nargin < 3
         pars = struct(...
            'iThis',nan,...
            'C',[0.9 0.5 0.0],...
            'doCurrentLines',true);
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
      if pars.doCurrentLines
         for k = 1:5
            if isequal(k,pars.iThis)
               line(ax,s.t,s.Y(k,:),...
                  'LineStyle','-',...
                  'LineWidth',LW(k),...
                  'Color',HL,...
                  'DisplayName',sprintf('%g-mA',nanmax(s.Y(k,:))));
            else
               line(ax,s.t,s.Y(k,:),...
                  'LineStyle','-',...
                  'LineWidth',LW(k),...
                  'Color',COL,...
                  'DisplayName',sprintf('%g-mA',nanmax(s.Y(k,:))));
            end
         end
      end
      
      % Add "epoch" patches as well
      F = [1:4, 1];
      tP1 = [s.t(2); s.t(2); s.t(3); s.t(3)];
      tP2 = [s.t(4); s.t(4); s.t(5); s.t(5)];
      if s.Y(1,2) > 0 % Then high - low == STIM - POST
         p1_str = 'Stim';
         p2_str = 'Post';
         alpha_1 = 0.45;
         alpha_2 = 0.15;
      else
         p1_str = 'Pre';
         p2_str = 'Stim';
         alpha_1 = 0.15;
         alpha_2 = 0.45;
      end
      yl = get(gca,'YLim');
      Y = [yl(1);yl(2);yl(2);yl(1)];
      
      h1 = patch(ax,'Faces',F,'Vertices',[tP1, Y],...
         'FaceColor',pars.C,...
         'EdgeColor','none',...
         'FaceAlpha',alpha_1,...
         'HandleVisibility','off');
      
      h2 = patch(ax,'Faces',F,'Vertices',[tP2, Y],...
         'FaceColor',pars.C,...
         'EdgeColor','none',...
         'FaceAlpha',alpha_2,...
         'HandleVisibility','off');
      
      x1 = (tP1(2) + tP1(3))/2;
      x2 = (tP2(2) + tP2(3))/2;
      
      
      text(ax,x1,yl(1),p1_str,...
         'FontName','Arial',...
         'Color','k',...
         'FontSize',14,...
         'FontWeight','bold',...
         'HorizontalAlignment','center',...
         'HandleVisibility','off',...
         'VerticalAlignment','bottom');
      text(ax,x2,yl(1),p2_str,...
         'FontName','Arial',...
         'Color','k',...
         'FontSize',14,...
         'FontWeight','bold',...
         'HorizontalAlignment','center',...
         'HandleVisibility','off',...
         'VerticalAlignment','bottom');
   end

end