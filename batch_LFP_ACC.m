out_dir = 'G:\Lab Member Folders\Max Murphy\Code\_M\170410 tDCS Assist\Accelerometery_LFP';
blockNum = [81 93 85 83 77 76 74 54 49 44 9];
for b = blockNum
   [data,fs] = loadDS_Data(b);
   lfp = struct;
   [~,lfp.f,lfp.t,lfp.P] = spectrogram(data,5*fs,fs,[],fs);
   [lfp.f,lfp.t,lfp.P] = doLFPNormalization([],lfp);
   fig = plotSpectrogram_TDCS(b,lfp);
   fname = sprintf('TDCS-%02g_LFP_ACC',b);
   expAI(fig,fullfile(out_dir,fname));
   saveas(fig,fullfile(out_dir,[fname '.png']));
   savefig(fig,fullfile(out_dir,[fname '.fig']));
   save(fullfile(out_dir,[fname '.mat']),'-struct','lfp');
   delete(fig);
end