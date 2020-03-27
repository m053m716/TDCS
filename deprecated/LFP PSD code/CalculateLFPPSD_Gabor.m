function CalculateLFPPSD_Gabor(FileName,Path,F,W,...
    LFP1Ch,LFP2Ch,LFP1Noisy,LFP2Noisy,...
    NotchON,RefType)

%% Function to calculate the FFT of an LFP signal
% Inputs:
%   Filename: downsampled data file to use
%   Path: Path to directory containing data and results
%   Windowsize: The time window to calculate the FFT on using a hamming
%               window
%   WIndowStep: The time in seconds to shift between windows
%   LFP1Ch/LFP2Ch: List of LFP1/LFP2 Channels
%   LFP1Noisy/LFP2Noisy: List of noisy channels in LFP1/LFP2
%   NotchON: 0 no 60Hz harmonics filtered, 1 filter 60 Hz harmonics
%   RefType: 0 no additional rereferencing, 1 remove Common Avg., 2 remove
%               channel 1 signal

%% Loading Data
load([Path '\ProcessedData\' FileName '_DS.mat'],'LFP1','LFP2','fDS',...
    'HPFreq','LPFreq',...
    'PelletBreaks','BeamBreaks','ButtonPress',...
    'PelletBreaks_Success','BeamBreaks_Success','ButtonPress_Success');

LFP1Clean=LFP1Ch;LFP1Clean(LFP1Noisy)=[];
LFP2Clean=LFP2Ch;LFP2Clean(LFP2Noisy)=[];

%% Notch Filter if we want it
if NotchON
    [b,a]=cheby1(4,0.05,[57 63]*(2/fDS),'stop');
    LFP1=(filtfilt(b,a,LFP1'))';LFP2=(filtfilt(b,a,LFP2'))';
    [b,a]=cheby1(4,0.05,[117 123]*(2/fDS),'stop');
    LFP1=(filtfilt(b,a,LFP1'))';LFP2=(filtfilt(b,a,LFP2'))';
    [b,a]=cheby1(4,0.05,[177 183]*(2/fDS),'stop');
    LFP1=(filtfilt(b,a,LFP1'))';LFP2=(filtfilt(b,a,LFP2'))';
    [b,a]=cheby1(4,0.05,[237 243]*(2/fDS),'stop');
    LFP1=(filtfilt(b,a,LFP1'))';LFP2=(filtfilt(b,a,LFP2'))';
end

%% HP Filter if it has not been done already
if HPFreq==0
    [b,a]=cheby1(4,0.05,1*(2/fDS),'high');
    LFP1=(filtfilt(b,a,LFP1'))';LFP2=(filtfilt(b,a,LFP2'))';
    HPFreq=1;
end

if LPFreq==0 && fDS>600
    [b,a]=cheby1(4,0.05,300*(2/fDS));
    LFP1=(filtfilt(b,a,LFP1'))';LFP2=(filtfilt(b,a,LFP2'))';
    LPFreq=300;
end

%% Rereference if we want to
if RefType==1
    LFP1=LFP1-repmat(mean(LFP1(LFP1Clean,:),1),size(LFP1,1),1);
    LFP2=LFP2-repmat(mean(LFP2(LFP2Clean,:),1),size(LFP2,1),1);
    refTxt='_CAR';
elseif RefType==2
    LFP1=LFP1-repmat(mean(LFP1(LFP1Clean(1),:),1),size(LFP1,1),1);
    LFP2=LFP2-repmat(mean(LFP2(LFP2Clean(1),:),1),size(LFP2,1),1);
    refTxt='_Ref1';
else
    refTxt='';
end

%% Calculate Gabor
Amp1=zeros(size(LFP1,1),length(F),ceil(size(LFP1,2)/10));
Amp2=zeros(size(LFP2,1),length(F),ceil(size(LFP2,2)/10));

WindowSamples=[];
for curFreq=1:length(F)
    params.spectra = F(curFreq);
    params.sample_rate = fDS;
    if F(curFreq)<120
        params.W = W;
    else
        params.W = W;
    end
    curGabor=gabor_cov_fitted(LFP1,params,'amp');
    for curch=1:size(curGabor,1)
        TestSignal=[];TestSignal(1,:)=curGabor(curch,1,:);
        TestSignal=smooth(TestSignal,10);
        TestSignal=downsample(TestSignal,10);
        Amp1(curch,curFreq,:)=TestSignal(:);
    end
    curGabor=gabor_cov_fitted(LFP2,params,'amp');
    for curch=1:size(curGabor,1)
        TestSignal=[];TestSignal(1,:)=curGabor(curch,1,:);
        TestSignal=smooth(TestSignal,10);
        TestSignal=downsample(TestSignal,10);
        Amp2(curch,curFreq,:)=TestSignal(:);
    end
end

WindowSamples(1,:)=1:size(Amp1,3);
fGabor=fDS/10;

savestr=[Path '\Spectra\Gabor\' FileName '_Gabor' refTxt '.mat'];
save(savestr,...
    'Amp1','Amp2',...
    'WindowSamples','F','fDS','fGabor','W');