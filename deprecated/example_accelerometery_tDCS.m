%EXAMPLE_ACCELEROMETERY_TDCS  Gets accelerometery data for `allNames`
% [likely deprecated]
clc;

%% EXTRACT ACCELEROMETERY DATA FOR ALL DESIRED TDCS RECORDINGS
maintic = tic;
% For batch run, call using {'TDCS-00','TDCS-01','TDCS-04',...(etc)}
% >> F = dir(fullfile('P:\Rat\tDCS','TDCS-*'));
% >> allNames = {F.name};
% >> acc = getAccelerometeryData_TDCS(allNames);
% acc = getAccelerometeryData_TDCS('TDCS-81');

if exist(allNames,'var')==0
   error('Missing `allNames`: see comments above.');
end
acc = getAccelerometeryData_TDCS(allNames);
disp('Finished extraction.');
toc(maintic);


% Make figure
% fig = plotAccelerometeryData(acc);

