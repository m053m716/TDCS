function LFP_Table = organizeLFPData(F,Assignment,varargin)
%% ORGANIZELFPDATA  Assign name and treatment to each MEM estimate file.
%
%   LFP_Table = ORGANIZELFPDATA(F,Assignment,'NAME',value,...)
%
%   --------
%    INPUTS
%   --------
%      F        :       File structure containing general block layout and
%                       info for tDCS study.
%
%   Assignment  :       Assignment table for recordings, animals, and
%                       treatment condition numbers.
%
%   varargin    :       (Optional) 'NAME',value input argument pairs.
%
%   --------
%    OUTPUT
%   --------
%   LFP_Table   :       Table containing file names on each row, but also
%                       variables to sort those file names by animal or
%                       by treatment.
%
% By: Max Murphy    v1.0    08/15/2017  Original version (R2017a)

%% DEFAULTS
F_ID = '*MEM*.mat';

%% PARSE VARARGIN
for iV = 1:2:numel(varargin)
    eval([upper(varargin{iV}) '=varargin{iV+1};']);
end

%% GET INPUT
FileName = [];
Rec = [];
Animal = [];
Condition = [];

for iF = 1:numel(F)
    temp = dir(fullfile(F(iF).mem{1},F_ID));
    r = str2double(F(iF).name(6:7));
    ind = abs(Assignment.SessionID-r)<eps;
    if sum(ind)<1
        continue;
    end
    for iT = 1:numel(temp)
        FileName = [FileName; {fullfile(temp(iT).folder,temp(iT).name)}]; %#ok<AGROW>
        Rec = [Rec; r];
        Animal = [Animal; Assignment.Animal(ind)];
        Condition = [Condition; Assignment.Condition(ind)];
    end
end

LFP_Table = table(Rec,FileName,Animal,Condition);

end