function varargout = ShadedErrorPlot(varargin)

pars = struct;

pars.DisplayName = '';
pars.Tag = '';
pars.UserData = [];
pars.FaceColor = [0.66 0.66 0.66];
pars.FaceAlpha = 0.75;
pars.EdgeColor = 'none';

pars.Marker = 'none';
pars.LineWidth = 1.25;
pars.Color = 'k';
pars.IconDisplayStyle = 'off';


if nargin < 1
   varargout = {pars};   
else
   F = fieldnames(pars);   
   if (nargout == 1) && (numel(varargin) > 1)
      varargout{1} = struct;
      for iV = 1:numel(varargin)
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{1}.(F{idx}) = pars.(F{idx});
         end
      end
   elseif nargout > 0
      varargout = cell(1,nargout);
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx)==1
            varargout{iV} = pars.(F{idx});
         end
      end
   else
      for iV = 1:nargout
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end
end