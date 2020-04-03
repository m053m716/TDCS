function varargout = Get_Exemplar(varargin)
%GET_EXEMPLAR  Parameters for creating exemplar processing panels
%
%  pars = defs.Get_Exemplar();
%  [var1,var2,...] = defs.Get_Exemplar('VAR1','VAR2',...);
%  pars = parseParameters('Get_Exemplar','VAR1',var1Val,...);

pars = struct;
pars.TAG = '';          % Only relevant for naming files
pars.NSAMPLES = 1000;   % 2*pars.NSAMPLES+1 total samples to plot
pars.SAMPLE_WEIGHTS = [0.25 0.75; 0.75 0.25]; % Rows by `tAlign`, [nPre nPost] sample proportions
pars.CHANNEL_INDEX = 1; % Channel index 1 ('Channel-008')
pars.BLOCK_INDEX = 10;  % Row 10: Corresponds to TDCS-28
pars.OUTPUT_SUB_DIR = 'Fig 3 - Exemplars'; % Subfolder in Figures folder
pars.OUTPUT_DIR = defs.FileNames('OUTPUT_FIG_DIR'); % Figure output default

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
      for iV = 1:nargin
         idx = strcmpi(F,varargin{iV});
         if sum(idx) == 1
            fprintf('<strong>%s</strong>:',F{idx});
            disp(pars.(F{idx}));
         end
      end
   end
end

end