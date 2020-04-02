function [fig,outputname] = batchHandleFigure(fig,outDir,filenameString,varargin)
%BATCHHANDLEFIGURE  Handles figure saving for batch processing
%
%  batchHandleFigure(fig,filename);
%  batchHandleFigure(fig,outDir,filenameString);
%  fig = batchHandleFigure(fig,outDir,filenameString);
%  --> If `fig` is specified, then does not export to vector graphics and
%      returns handle to figure with modified UserData property
%  [fig,outputname] = ...
%  --> If second output argument is requested, then it does export to
%        vector graphics, and also returns the exact full file name of the
%        output file.

if nargin == 2
   [outDir,filenameString,~] = fileparts(outDir);
else
   if isempty(outDir)
      [outDir,filenameString,~] = fileparts(filenameString);
   else
      [~,filenameString,~] = fileparts(filenameString);
   end
end

if exist(outDir,'dir')==0
   mkdir(outDir);
end

if nargout ~= 1
   pars = p__.parseParameters('Exporting_To_Illustrator',varargin{:});
   fprintf(1,'\t->\tSaving: %s...',filenameString);
   pars.AutoFormat.Font = false;
   [fig,outputname] = gfx__.expAI(fig,fullfile(outDir,filenameString),pars);
   saveas(fig,fullfile(outDir, [filenameString '.png']));
   if exist(fullfile(outDir,'MatFigs'),'dir')==0
      mkdir(fullfile(outDir,'MatFigs'));
   end
   fig.UserData.Saved = true;
   savefig(fig,fullfile(outDir,'MatFigs',[filenameString '.fig']));
   delete(fig);
   fprintf(1,'complete\n');
else % Otherwise set a flag that the figure has not been saved
   if isempty(fig.UserData)
      fig.UserData = struct;
      fig.UserData.Saved = false;
   elseif isstruct(fig.UserData)
      fig.UserData.Saved = false;
   end
   outputname = '';
end


end