function AppendedSpikeData = AppendGroupAssignments(SpikeData,varargin)
%APPENDGROUPASSIGNMENTS   Append group and animal to Spike Summaries
%
%   AppendedSpikeData = APPENDGROUPASSIGNMENTS(SpikeData,'NAME',value,...)

% DEFAULT CONSTANTS
switch nargin
   case 0
      error('Too few input arguments.');
   case 1
      pars = defs.Spikes();
   case 2
      pars = varargin{1};
   otherwise
      pars = defs.Spikes();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

% INITIALIZE
load(fullfile(pars.DIR,pars.ASSIGNMENT_FILE),'Assignment');
N = size(SpikeData{1,1},1);
Condition = nan(N,1);
Animal = nan(N,1);

% EXTRACT CONDITION AND ANIMAL
Remove_Vec = true(N,1);
for iN = 1:N
    if pars.USE_RAT
        Name = SpikeData{1,1}.Rat{iN};
    else
        Name = SpikeData{1,1}.Name{iN};
    end
    Num = str2double(Name(6:7));
    Index = abs(Assignment.SessionID-Num)<eps;
    if ~isnan(pars.MIN_N_SPK)
        nspk = 0;
        for iEpoch = 1:numel(SpikeData)
            nspk = nspk + SpikeData{1,iEpoch}.NumSpikes(iN);
        end
        if (isempty(find(Index,1)) || nspk < pars.MIN_N_SPK)
            Remove_Vec(iN) = false;
        else
            Condition(iN) = Assignment.Condition(Index);
            Animal(iN) = Assignment.Animal(Index);    
        end
    else
        if isempty(find(Index,1))
            Remove_Vec(iN) = false;
        else
            Condition(iN) = Assignment.Condition(Index);
            Animal(iN) = Assignment.Animal(Index);
        end
    end
end

Animal = Animal(Remove_Vec);
Condition = Condition(Remove_Vec);

% APPEND TO TABLES
for iEpoch = 1:numel(SpikeData)
    SpikeData{1,iEpoch} = SpikeData{1,iEpoch}(Remove_Vec,:);
    SpikeData{1,iEpoch} = [SpikeData{1,iEpoch}, table(Animal,Condition)];
    SpikeData{1,iEpoch}.Properties.VariableNames{pars.ANIMAL_COLUMN} = ...
        'Animal';
    SpikeData{1,iEpoch}.Properties.VariableNames{pars.CONDITION_COLUMN} = ...
        'Condition';
end

AppendedSpikeData = SpikeData;

end