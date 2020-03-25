function AppendedSpikeTrainData = genTransientRateFigs(SpikeTrainData,AppendedSpikeData,SpikeSeries,varargin)
%% GENTRANSIENTRATEFIGS  Make figures for transient rate changes after stimulation for tDCS study.
%
%   AppendedSpikeTrainData = GENTRANSIENTRATEFIGS(SpikeTrainData,AppendedSpikeData,SpikeSeries,'NAME',value,...)
%
% By: Max Murphy    v1.0    07/19/2017

%% DEFAULTS
PERIOD = 2;         % SpikeTrainData Period to use:
                    %   1 : BASAL
                    %   2 : STIM
                    %   3 : POST-1
                    %   4 : POST-2
                    %   5 : POST-3
                    %   6 : POST-4

T_MIN       = 1;            % Minimum for considering stationarity (sec)
T_STEP      = 1;            % Time-step (sec)
T_MAX       = 5 * 60;       % Maximum for considering stationarity (sec)
MIN_N_SPK   = T_MAX * 4;    % Minimum number of spikes for this period
NS_THRESH   = 30;           % Flat threshold for NS consideration
NS_FOLDER   = 'NS_TEST';    % Save folder
MAKE_FIGS   = true;         % Option to make figures

YLIM = [0 50];

%% PARSE VARARGIN
for iV = 1:2:numel(varargin)
    eval([upper(varargin{iV}) '=varargin{iV+1};']);
end

%% GET APPENDEDSPIKETRAINDATA
N = numel(SpikeTrainData);
if abs(N-numel(AppendedSpikeData)) > eps
    error('Invalid inputs. Both should be cell arrays of the same length.');
end

AppendedSpikeTrainData = cell(1,N);
for iN = 1:N
    vec = false(size(SpikeTrainData{1,iN},1),1);
    for iUnit = 1:size(SpikeTrainData{1,iN},1)
        vec(iUnit) = any( ismember(AppendedSpikeData{1,iN}.Rat,             ...
                                   SpikeTrainData{1,iN}.Name{iUnit}) &      ...
                          ismember(AppendedSpikeData{1,iN}.Channel,         ...
                                   SpikeTrainData{1,iN}.Channel(iUnit)) &   ...
                          ismember(AppendedSpikeData{1,iN}.Cluster,         ...
                                   SpikeTrainData{1,iN}.Cluster(iUnit)));
    end
    Animal = AppendedSpikeData{1,iN}.Animal;
    Condition = AppendedSpikeData{1,iN}.Condition;
    AppendedSpikeTrainData{1,iN} = [SpikeTrainData{1,iN}(vec,:), ...
                                    table(Animal), ...
                                    table(Condition)];
    Y = SpikeSeries{1,PERIOD}(vec,:);
end

%% ASSESS STATIONARY DURATION FROM BEGINNING OF TRIAL, BY TRAIN
X = AppendedSpikeTrainData{1,PERIOD};
vec = true(size(X,1),1);
t_NS = T_MIN:T_STEP:T_MAX;
NS = nan(size(X,1),numel(t_NS));


for iX = 1:size(X,1)
    fs = X.FS(iX);          % Sampling rate
    ts = find(X.Train{iX})/fs;  % Spike times (sec)
    
    ts = ts(ts < T_MAX);
    
    if numel(ts) < MIN_N_SPK
        vec(iX) = false;    % Exclude
        continue;
    end
    
    iP = 1;
    for T = t_NS
        tn = ts(ts < T);
        if numel(tn) < 4
            NS(iX,iP) = nan;
        else
            NS(iX,iP) = ns_detect(tn,T);
        end
        iP = iP + 1;
    end

end
NS(isinf(NS)) = 50;
t_NS = repmat(t_NS,size(X,1),1);
AppendedSpikeTrainData{1,PERIOD}=[AppendedSpikeTrainData{1,PERIOD},...
                                  table(NS), ...
                                  table(t_NS)];

%% ASSIGN OUTPUT WITH EXCLUSIONS
for iN = 1:N
    AppendedSpikeTrainData{1,iN} = AppendedSpikeTrainData{1,iN}(vec,:);
end

%% MAKE FIGURES
if MAKE_FIGS
    if exist(NS_FOLDER,'dir')==0
        mkdir(NS_FOLDER);
    end
    tt = t_NS(1,:);
    Y = Y(vec,:);
    NS = NS(vec,:);
    NS(isnan(NS)) = 0;
%     figure('Name','Stationary Rates',...
%            'Units','Normalized', ...
%            'Position',[0.2 0.2 0.6 0.6]);
    for iY = 1:size(Y,1)
        y = Y.Y{iY}(ismembertol(Y.T{iY},tt,0.1,'DataScale',1));
        fname = [Y.Name{iY} ' Ch' num2str(Y.Channel(iY)) '-' ...
                              num2str(Y.Cluster(iY)) 'Stationarity'];
        figure('Name',fname);
        for iNS = 2:(numel(NS(iY,:))-1)
            hold on;
            % Three consecutive values must be > NS_THRESH
            if (NS(iY,iNS) > NS_THRESH && ...
                NS(iY,iNS-1) > NS_THRESH && ...
                NS(iY,iNS+1) > NS_THRESH)
                line([tt(iNS-1) tt(iNS)], ...
                     [y(iNS-1) y(iNS)],'Color','m','LineWidth',2);
            else
                line([tt(iNS-1) tt(iNS)], ...
                     [y(iNS-1) y(iNS)],'Color','k','LineWidth',2);
            end
        end
        
%         if any(NS(iY,:) > NS_THRESH)
%             yNS = find(NS(iY,:) > NS_THRESH,1,'first');
%             yNS = max([yNS,2]);
%             plot(tt(1:(yNS-1)),y(1:(yNS-1)),'LineWidth',2, ...
%                                             'Color', 'k');
%             hold on;
%             plot(tt((yNS-1):end),y((yNS-1):end),'LineWidth',2,...
%                                                 'Color','m');
%         else
%             if abs(numel(tt)-numel(y))<eps
%                 plot(tt,y,'LineWidth',2,'Color','k');
%             else
%                 delete(gcf);
%                 continue
%             end
%         end
%         hold on;
%         plot3(tt,y,NS(iY,:),'LineWidth', 2);
        title(fname)
        xlim([min(tt) max(tt)]);
        ylim(YLIM);
        savefig(gcf,[NS_FOLDER filesep fname '.fig']);
        saveas(gcf,[NS_FOLDER filesep fname '.jpeg']);
        delete(gcf);
    end
%     title('Stationary Rates')
%     xlim([min(tt) max(tt)]);
%     ylim(YLIM);
%     savefig(gcf,[NS_FOLDER filesep 'StationaryRates.fig']);
%     saveas(gcf,[NS_FOLDER filesep 'StationaryRates.jpeg']);
%     delete(gcf);

end


end