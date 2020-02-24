maintic = tic;
% For batch run, call using {'TDCS-00','TDCS-01','TDCS-04',...(etc)}
% >> F = dir(fullfile('P:\Rat\tDCS','TDCS-*'));
% >> allNames = {F.name};
% >> acc = getAccelerometeryData_TDCS(allNames);
% acc = getAccelerometeryData_TDCS('TDCS-81');
acc = getAccelerometeryData_TDCS(allNames);
disp('Finished extraction.');
toc(maintic);


% Make figure
% fig = plotAccelerometeryData(acc);

