function CalculateLFPPSD_MEM(FileName,Path,WindowSize_sec,WindowStep_sec,...
    MEMorder,FirstCtr,LastCtr,BW,EvalsperBin,Detrend,...
    LFP1Ch,LFP2Ch,LFP1Noisy,LFP2Noisy,...
    NotchON,RefType)

%% Function to calculate the FFT of an LFP signal
% Inputs:
%   Filename: downsampled data file to use
%   Path: Path to directory containing data and results
%   Windowsize: The time window to calculate the MEM on
%   WIndowStep: The time in seconds to shift between windows
%   params: MEM params to use. Format is:
%[modelorder firstctr lastctr bandwidth evalperbin trend samplingrate]
%   LFP1Ch/LFP2Ch: List of LFP1/LFP2 Channels
%   LFP1Noisy/LFP2Noisy: List of noisy channels in LFP1/LFP2
%   NotchON: 0 no 60Hz harmonics filtered, 1 filter 60 Hz harmonics
%   RefType: 0 no additional rereferencing, 1 remove Common Avg., 2 remove
%               channel 1 signal

%% Loading Data

if ispc==1
    load([Path '\ProcessedData\' FileName '_DS.mat'],'LFP1','LFP2','fDS',...
        'HPFreq','LPFreq',...
        'PelletBreaks','BeamBreaks','ButtonPress',...
        'PelletBreaks_Success','BeamBreaks_Success','ButtonPress_Success');
else
    load([Path '/ProcessedData/' FileName '_DS.mat'],'LFP1','LFP2','fDS',...
        'HPFreq','LPFreq',...
        'PelletBreaks','BeamBreaks','ButtonPress',...
        'PelletBreaks_Success','BeamBreaks_Success','ButtonPress_Success');
end

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

%% Calculate MEM

LFP1=LFP1';
LFP2=LFP2';

WindowSize_samp=round(WindowSize_sec*fDS);
WindowStep_samp=round(WindowStep_sec*fDS);
numWindows=floor((size(LFP1,1)-WindowSize_samp)/WindowStep_samp);
WindowSamples=zeros(1,numWindows);

params=[MEMorder,FirstCtr,LastCtr,BW,EvalsperBin,Detrend,fDS];

[test,fqs]=mem(double(LFP1(1:1+WindowSize_samp,:)),params);

Amp1=zeros(size(LFP1,2),length(fqs),numWindows);
Amp2=zeros(size(LFP2,2),length(fqs),numWindows);

for i=1:numWindows
    if rem(i,25)==0
        disp(['Window ' num2str(i) ' of ' num2str(numWindows) '\n']);
    end
    
    xStart=1+(i-1)*WindowStep_samp;
    xEnd=xStart+WindowSize_samp-1;
    [curAmp1,F]=mem(double(LFP1(xStart:xEnd,:)),params);
    [curAmp2,F]=mem(double(LFP2(xStart:xEnd,:)),params);
    
    Amp1(:,:,i)=curAmp1';
    Amp2(:,:,i)=curAmp2';
    
    WindowSamples(i)=round(xStart+WindowSize_samp/2);
end
if ispc==1
    savestr=[Path '\Spectra\MEM\' FileName '_MEM' refTxt '.mat'];
else
    savestr=[Path '/Spectra/MEM\' FileName '_MEM' refTxt '.mat'];
end
save(savestr,...
    'Amp1','Amp2',...
    'WindowSamples','F','fDS','WindowSize_samp','WindowStep_samp');