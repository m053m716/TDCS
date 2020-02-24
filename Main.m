%% SIMPLE SPIKE DATA
% Load in all the simple spike data
[SpikeData,F] = LoadSpikeSummaries;

% Get all the random assignments and rate-based exclusion
AppendedSpikeData = AppendGroupAssignments(SpikeData);

%% INCLUSION EXCLUSION DATA: 0.1 Hz MIN RATE
C = GetExclusionCounts(F);
load('2017-08-09_Exclusion Counts.mat','C');
[C,E] = generateExclusionTable(C);
% writetable(E.animal,'TDCS Unit counts by Animal.xlsx');
% writetable(E.treatment, 'TDCS Unit counts by Treatment.xlsx');
% writetable(E.both, 'TDCS Unit counts by Animal and Treatment.xlsx');

%% FIG 2: AVERAGE RATE BY ANIMAL // BY TREATMENT // BOTH
genWholeTrialFigs(C);

%% FIG 3: SIMPLE SPIKE OUTPUT
% Generate the basic spike figures from the data
generateBasicSpikeFigures(AppendedSpikeData);

%% SPIKE TRAIN DATA
% Load in all the spike train data
[SpikeTrainData,F] = LoadSpikeTrains;

% Get comparison sets of binned time-series spike data
% SpikeSeries = SpikeTrain2Series(SpikeTrainData); % LONG!
% load('2017-07-15_Spike Series Data.mat','SpikeSeries');

%% FIG 4: SPIKE TRAIN - RATE CHANGES > 1 SPIKE/SEC
f = defs.FileNames(); % Get file names
load(fullfile(f.DIR,f.RATE_CHANGES),'RateChange','Animal','Condition');
load(fullfile(f.DIR,f.WORKSPACE),'Rates');
genFlatThreshRateFigs(Rates,Condition);

%% FIG 5: SPIKE TRAIN - ISI DISTRIBUTION CHANGES FROM GAMMA PARAMETERS
% Identify units with significant rate change vs. baseline
SigUnits = FindSigUnits(SpikeTrainData);

% Plot the ISI of those units
UnitData = PlotISIDistributions(SpikeTrainData,...
            'ISI_DIR', ['ISI' filesep 'Significant'], ...
            'USE_VEC', SigUnits);

% Plot boxplots of those changes
generateSigRateChangeSpikeFigures(UnitData);

% Plot time series for significant units
generateSigRateSeriesFigs(SpikeSeries,UnitData);

% Get the significant responders per ISI gamma dist. changes
ISI_Response_Data = getISIresponders(SpikeTrainData,SigUnits);
genGammaThreshFigs(ISI_Response_Data.Rate,ISI_Response_Data.Condition);

%% FIG 6: PROPORTIONS OF SIGNIFICANT SPIKE CHANGES
% Get proportions that increase or decrease by Animal, Condition, Both
[cAnimal,cCondition,cTotal] = getRateChanges(UnitData,AppendedSpikeData);

%% TRANSIENT SPIKE CHANGES
% Get first 5-minutes of STIM at 1 Hz checking for non-stationarity
% AppendedSpikeTrainData = genTransientRateFigs(SpikeTrainData, ...
%                                               AppendedSpikeData, ...
%                                               SpikeSeries);
 
% SpikeTrainData = appendGA(SpikeTrainData,'MIN_N_SPK',0); % add labels
% AppendedSpikeTrainData = appendGA(SpikeTrainData);
% SpikeSeries = SpikeTrain2Series(AppendedSpikeTrainData);
[RateStats,Comparisons] = SpikeSeries2Stats(SpikeSeries);

f = defs.FileNames();
load(fullfile(f.DIR,f.SPIKE_SERIES));
UnitCounts = getExclusionSpikeTrains(SpikeTrainData,SpikeSeries,C);

% writetable(UnitCounts.animal,'TDCS IFR Unit counts by Animal.xlsx');
% writetable(UnitCounts.treatment, 'TDCS IFR Unit counts by Treatment.xlsx');
% writetable(UnitCounts.both, 'TDCS IFR Unit counts by Animal and Treatment.xlsx');

% % Generate statistics: Time to NS onset; Total NS duration
% NSData = getNSstatistics(AppendedSpikeTrainData);
% 
% % Plot nonstationarity statistics
% genNSFigs(NSData,AppendedSpikeData);

%% LFP DATA
% Load pre-extracted LFP data (extraction takes a long time)
f = defs.FileNames();
load(fullfile(f.DIR,f.LFP),'LFPData');

%% SIMPLE LFP OUTPUT
% Generate basic LFP figures from the data
SimpleLFPData = generateBasicLFPFigures(LFPData);

% Generate LFP change figure ONLY
genLFPChangeFig(SimpleLFPData);

%% GET MEM LFP SPECTRAL AVERAGES
if exist('F','var')==0
   f = defs.FileNames();
   load(fullfile(f.DIR,f.DATA_STRUCTURE),'F');
end

% F = getDSData(F); % Moderate - approx. 4 hours
% F = getMEMLFPEstimates(F); % Long! takes most of a day

% save('P:\Rat\tDCS\2017 TDCS Data Structure Organization.mat','F','-v7.3');

%% FIG 7: MEM LFP SPECTRAL ESTIMATES
if exist('F','var')==0 || exist('Assignment','var')==0
   LFP_Table = parseLFP_Table();
else
   LFP_Table = parseLFP_Table(F,Assignment);
end
gen_Avg_LFP_Figs(LFP_Table);





