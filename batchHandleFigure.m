function batchHandleFigure(fig,outDir,filenameString)
%BATCHHANDLEFIGURE  Handles figure saving for batch processing
%
%  batchHandleFigure(fig,filename);
%  batchHandleFigure(fig,outDir,filenameString);

if nargin == 2
   [outDir,filenameString,~] = fileparts(outDir);
else
   if isempty(outDir)
      [outDir,filenameString,~] = fileparts(filenameString);
   else
      [~,filenameString,~] = fileparts(filenameString);
   end
end

fprintf(1,'\t->\tSaving: %s...',filenameString);
expAI(fig,fullfile(outDir,filenameString));
saveas(fig,fullfile(outDir, [filenameString '.png']));
savefig(fig,fullfile(outDir,[filenameString '.fig']));
delete(fig);
fprintf(1,'complete\n');

end