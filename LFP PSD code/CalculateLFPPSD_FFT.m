function CalculateLFPPSD_FFT(FileName,Path,WindowSize_sec,WindowStep_sec,...
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

%% Calculate FFT

LFP1=LFP1';
LFP2=LFP2';

WindowSize_samp=round(WindowSize_sec*fDS);
WindowStep_samp=round(WindowStep_sec*fDS);
numWindows=floor((size(LFP1,1)-WindowSize_samp)/WindowStep_samp);
WindowSamples=zeros(1,numWindows);

Amp1=zeros(size(LFP1,2),100,numWindows);
Amp2=zeros(size(LFP2,2),100,numWindows);

i=1;j=1;
while i<(size(LFP1,1)-WindowSize_samp)
    % Take the fft of the signal windows and use a hamming window to
    % reduce edge effects
    [curpsd1] = fft(repmat(hamming(WindowSize_samp+1),1,size(LFP1,2)).*LFP1(i:i+WindowSize_samp,:),floor(fDS),1);
    [curpsd2] = fft(repmat(hamming(WindowSize_samp+1),1,size(LFP2,2)).*LFP2(i:i+WindowSize_samp,:),floor(fDS),1);
    % Take the magnitude and square to produce power. We only save the
    % positive frequencies (first half)
    curpsd1=abs(curpsd1(1:floor(size(curpsd1,1)/2)+1,:)).^2;
    curpsd2=abs(curpsd2(1:floor(size(curpsd2,1)/2)+1,:)).^2;
    % Generate frequency vector
    F= fDS/2*linspace(0,1,fDS/2+1);
    freq2remove=unique(horzcat([1:2:200],[201:length(F)]));
    F(freq2remove)=[];
    curpsd1=curpsd1';
    curpsd2=curpsd2';
    curpsd1(:,freq2remove)=[];
    curpsd2(:,freq2remove)=[];
    Amp1(:,:,j) = curpsd1(:,:);
    Amp2(:,:,j) = curpsd2(:,:);
    WindowSamples(j)=round(i+WindowSize_samp/2);
    i = i+WindowStep_samp;
    j = j+1;
end
savestr=[Path '\Spectra\FFT\' FileName '_FFT' refTxt '.mat'];
save(savestr,...
    'Amp1','Amp2',...
    'WindowSamples','F','fDS','WindowSize_samp','WindowStep_samp');