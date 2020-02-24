function T_out = appendGA(T_in,varargin)
%% APPENDGA  General function to append group assignments to a table for tDCS study.
%
%   T_out = APPENDGA(T_in,'NAME',value,...)
%
%   --------
%    INPUTS
%   --------
%      T_in     :   Input table, where each row corresponds to input with
%                   some "TDCS-##" session name.
%
%   --------
%    OUTPUT
%   --------
%     T_out     :   Output table, same as T_in, but with the 'Condition'
%                   and 'Animal' fields appended.
%
% By: Max Murphy  v1.1    11/22/2017  Made more flexible for cell or
%                                     non-cell inputs.
%                 v1.0    08/09/2017  Original version (R2017a)

%% DEFAULTS
ASSIGNMENT_FILE = '2017-06-14_Excluded Metric Subset.mat';
USE_RAT = false;
NAME_IND = 6:7;
MIN_N_SPK = 570;  % Min. of 0.1 Hz

%% PARSE VARARGIN
for iV = 1:2:numel(varargin)
    eval([upper(varargin{iV}) '=varargin{iV+1};']);
end

%% EXTRACT INFO
if ~iscell(T_in)
   T_in = {T_in};
end

load(ASSIGNMENT_FILE,'Assignment');     % Load TDCS group/animal assignment
M = size(T_in{1},1);                       % # of rows (observations)
N = size(T_in{1},2);                       % # of columns (variables)

%% INITIALIZE
Condition = nan(M,1);                   
Animal = nan(M,1);

%% EXTRACT CONDITION AND ANIMAL
Remove_Vec = true(M,1);
VarNames = T_in{1}.Properties.VariableNames;

for iN = 1:M
    if USE_RAT
        Name = T_in{1}.Rat{iN};
    else
        if ischar(T_in{1}.Name)
            Name = T_in{1}.Name(iN,:);
        else
            Name = T_in{1}.Name{iN};
        end
    end
    
    Num = str2double(Name(NAME_IND));
    Index = abs(Assignment.SessionID-Num)<eps;
    if ~isnan(MIN_N_SPK)
        if any(contains(VarNames,'NumSpikes'))
           nspk = 0;
           for iEpoch = 1:numel(T_in)
               nspk = nspk + T_in{iEpoch}.NumSpikes(iN);
           end
           if (isempty(find(Index,1)) || nspk < MIN_N_SPK)
               Remove_Vec(iN) = false;
           else
               Condition(iN) = Assignment.Condition(Index);
               Animal(iN) = Assignment.Animal(Index);    
           end
        else
           nspk = 0;
           for iEpoch = 1:numel(T_in)
               nspk = nspk + numel(find(T_in{iEpoch}.Train{iN}));
           end
           if (isempty(find(Index,1)) || nspk < MIN_N_SPK)
               Remove_Vec(iN) = false;
           else
               Condition(iN) = Assignment.Condition(Index);
               Animal(iN) = Assignment.Animal(Index);    
           end
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

%% APPEND TO TABLES
T_out = cell(1,numel(T_in));
for iEpoch = 1:numel(T_in)
   T_in{iEpoch} = T_in{iEpoch}(Remove_Vec,:);
   T_out{iEpoch} = [T_in{iEpoch}, table(Animal,Condition)];
   T_out{iEpoch}.Properties.VariableNames{N+1} = 'Animal';
   T_out{iEpoch}.Properties.VariableNames{N+2} = 'Condition';
end
if numel(T_out)==1
   T_out = T_out{1};
end


end