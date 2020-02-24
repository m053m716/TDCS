F = dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-224\R19-224*');
F = [F; dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-226\R19-226*')];
F = [F; dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-227\R19-227*')];
F = [F; dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-230\R19-230*')];
F = [F; dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-231\R19-231*')];
F = [F; dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-232\R19-232*')];
F = [F; dir('P:\Rat\BilateralReach\Solenoid Experiments\R19-234\R19-234*')];

TIC = tic;
for iF = 1:numel(F)
   qDS('DIR',fullfile(F(iF).folder,F(iF).name),...
      'TIC',TIC,...
      'CLUSTER_LIST',{'CPLMJS2';'CPLMJS3'});   
end