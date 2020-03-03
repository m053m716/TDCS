function [ax,b,l] = addPowerBars3(ax,P,name,varargin)
%ADDPOWERBARS3  Adds 3D bar graph row for data struct `P` to axes `ax`
%
%  ax = addPowerBars3(P);
%
%  [ax,b] = addPowerBars3(ax,P,name);
%
%  output: 
%  ax - Current axes
%  b  - "Bar" object
%  l  - "Error line" object

if ~isa(ax,'matlab.graphics.axis.Axes')
   if nargin >= 3
      varargin = [name, varargin];
   end
   if nargin >= 2
      varargin = [P, varargin];
   end
   P = ax;
   ax = gca;
   updateFlag = true;
else
   updateFlag = false;
end

pars = parseParameters('PowerBars',varargin{:});

if updateFlag
   name = pars.BAND_NAMES;
   ax.NextPlot = pars.NEXT;
   ax.FontName = pars.FONT;
   ax.FontSize = 13;
   ax.LineWidth = pars.LINEW;
   ax.XColor = pars.XCOL;
   ax.YColor = pars.YCOL;
   ax.ZColor = pars.ZCOL;
   ax.XLim = [0 numel(pars.EPOCH_NAMES) + 1];
   ax.XTick = 1:numel(pars.EPOCH_NAMES);
   ax.XTickLabels = pars.EPOCH_NAMES;
   ax.YLim = [0 numel(pars.BAND_NAMES) + 1];
   ax.YTick = 1:numel(pars.BAND_NAMES);
   ax.YTickLabels = strrep(pars.BAND_NAMES,'_','-');
   ax.YDir = 'reverse';
   ax.ZLim = pars.ZLIM;
   view(ax,3);
   set(gcf,'Units','Normalized');
   set(gcf,'Position',pars.FIG_POS);
   set(gcf,'Name','RMS Power');
   set(gcf,'Color','w');
end

if iscell(name)
   idx = nan(size(name));
   Y = nan(numel(name),numel(pars.BAND_NAMES));
   eZ = [];
   eX = [];
   eY = [];
   for i = 1:numel(name)
      idx(i) = find(strcmp(pars.BAND_NAMES,name{i}),1,'first');
%       bar3(ones(size(P.(name{i}).mu)).*idx(i),P.(name{i}).mu);
      Y(i,:) = P.(name{i}).mu_z;
      tmp = [...
         Y(i,:) + P.(name{i}).sd_z./sqrt(P.(name{i}).n); ...
         Y(i,:) - P.(name{i}).sd_z./sqrt(P.(name{i}).n); ...
         nan(1,size(Y,2))];
      eZ = [eZ; tmp(:)];  %#ok<AGROW>
      tmp = [ones(2,size(Y,2)).*idx(i); nan(1,size(Y,2))];
      eY = [eY; tmp(:)]; %#ok<AGROW>
      tmp = [1:size(Y,1); 1:size(Y,1); nan(1,size(Y,1))];
      eX = [eX; tmp(:)]; %#ok<AGROW>
   end
   o = min(min(Y));
   Y = Y - o;
   eZ = eZ - o;
   
   if ~updateFlag
      cla(ax);
   end
   b = bar3(ax,idx,Y,0.75);
   l = line(ax,eX,eY,eZ,'Color','k','LineWidth',3,'Tag','Error',...
      'Marker','sq','MarkerFaceColor','k');
   for i = 1:numel(b)
      b(i).Tag = pars.EPOCH_NAMES{i};
      b(i).FaceColor = pars.EPOCH_COLORS(i,:);
      b(i).EdgeColor = 'w';
      b(i).FaceAlpha = 0.50;
      b(i).LineWidth = 1.5;
   end
   for i = numel(b):-1:1
      uistack(b(i),'top');
   end

else
   idx = find(strcmp(pars.BAND_NAMES,name),1,'first');
%    bar3(ones(size(P.(name).mu)).*idx,P.(name).mu);
   b = bar3(ax,idx,P.(name).mu_z,0.75);
   n = numel(P.(name).mu_z);
   xx = [1:n; 1:n; nan(1,n)];
   xx = xx(:);
   yy = [ones(2,n); nan(1,n)];
   yy = yy(:);
   zz = [...
      P.(name).mu_z + (P.(name).sd_z/sqrt(P.(name).n)); ...
      P.(name).mu_z - (P.(name).sd_z/sqrt(P.(name).n)); ...
      nan(1,n)];
   zz = zz(:);
   l = line(ax,xx,yy,zz,'Color','k','LineWidth',3,'Tag','Error',...
      'Marker','sq','MarkerFaceColor','k');
end

if ~isempty(pars.TITLE)
   if strcmpi(pars.TITLE(1:4),'TDCS')
      title_txt = strsplit(pars.TITLE,'_');
      title_txt = [title_txt{1} ': ' title_txt{2} '-' title_txt{3} '-' title_txt{4}];
   else
      title_txt = strrep(pars.TITLE,'_','-');
   end
   title(title_txt,'FontName','Arial','FontSize',16,'FontWeight','bold',...
      'Color','k');
end

if pars.BATCH && (nargout == 0) && ~isempty(pars.OUTPUT_FILE)
   [path,fname,~] = fileparts(pars.OUTPUT_FILE);
   if exist(path,'dir')==0
      mkdir(path);
   end
   expAI(gcf,fullfile(path,fname));
   savefig(gcf,fullfile(path,[fname '.fig']));
   saveas(gcf,fullfile(path,[fname '.png']));
   delete(gcf);
end


end