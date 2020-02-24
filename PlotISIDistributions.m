function UnitData = PlotISIDistributions(SpikeTrainData,varargin)
%PLOTISIDISTRIBUTIONS pars.PLOT ISI for data collected in tDCS study.
%
%   UnitData = PLOTISIDISTRIBUTIONS(SpikeTrainData,'NAME',value,...)

switch nargin
   case 0
      pars = defs.ISIDistributionFigs();
   case 1
      pars = varargin{1};
   otherwise
      pars = defs.ISIDistributionFigs();
      for iV = 1:2:numel(varargin)
         pars.(upper(varargin{iV})) = varargin{iV+1};
      end
end

if isempty(pars.USE_VEC)
   pars.USE_VEC = true(size(SpikeTrainData{1,1},1),1);
end


% MAKE SAVE DIRECTORY
if exist(pars.ISI_DIR,'dir')==0
    mkdir(pars.ISI_DIR);
end

% LOOP THROUGH EACH ANIMAL AND SESSION AND PLOT ISI
NAME = unique(SpikeTrainData{1,1}.Name);
if nargout > 0
    AvgRateBASAL = nan(sum(pars.USE_VEC),1);
    AvgRateSTIM = nan(sum(pars.USE_VEC),1);
    UnitData = [];
    iCountX = 1;
    iCountY = 1;
end

for iN = 1:numel(NAME)
    X = SpikeTrainData{1,1}(ismember(SpikeTrainData{1,1}.Name,NAME{iN}) ...
                            & pars.USE_VEC,:);
    Y = SpikeTrainData{1,2}(ismember(SpikeTrainData{1,2}.Name,NAME{iN}) ...
                            & pars.USE_VEC,:);
    nX = size(X,1);
    nRow = ceil(sqrt(nX));
    nCol = nRow;
    if pars.PLOT
        figure('Name',[NAME{iN} ' PRE-stim ISI'], ...
           'Units','Normalized', ...
           'Position', [0.2 0.2 0.6 0.6]);
    end
       
    for iX = 1:nX
        x = diff(find(X.Train{iX})/X.FS(iX))*1e3;
        if pars.PLOT
            subplot(nRow,nCol,iX);
            histogram(x,'BinLimits',pars.XLIM,'FaceColor','b', ...
                                         'EdgeColor','none');
            pars.XLIM(pars.XLIM);
            pars.YLIM(pars.YLIM);
        end
        
        if nargout > 0
            AvgRateBASAL(iCountX) = (numel(x)+1)/pars.T_BASAL;
            UnitData = [UnitData; X(iX,[1:3,5])]; %#ok<AGROW>
            iCountX = iCountX + 1;
        end
    end
    if pars.PLOT
        suptitle([NAME{iN} ' PRE-stim ISI']);
        savefig(gcf,[pars.ISI_DIR filesep NAME{iN} '_PRE_ISI.fig']);
        saveas(gcf,[pars.ISI_DIR filesep NAME{iN} '_PRE_ISI.jpeg']);
        delete(gcf);
    end
    
    nY = nX;
    if pars.PLOT
        figure('Name',[NAME{iN} ' STIM ISI'], ...
           'Units','Normalized', ...
           'Position', [0.2 0.2 0.6 0.6]);
    end
    for iY = 1:nY
        
        y = diff(find(Y.Train{iY})/Y.FS(iY))*1e3;
        if pars.PLOT
            subplot(nRow,nCol,iY);
            histogram(y,'BinLimits',pars.XLIM,'FaceColor','r', ...
                                         'EdgeColor','none');
            pars.XLIM(pars.XLIM);
            pars.YLIM(pars.YLIM);
        end
        
        if nargout > 0
            AvgRateSTIM(iCountY) = (numel(y)+1)/pars.T_STIM;
            iCountY = iCountY + 1;
        end
    end
    if pars.PLOT
        suptitle([NAME{iN} ' STIM ISI']);
        savefig(gcf,[pars.ISI_DIR filesep NAME{iN} '_STIM_ISI.fig']);
        saveas(gcf,[pars.ISI_DIR filesep NAME{iN} '_STIM_ISI.jpeg']);
        delete(gcf);
    end
end

% COMPILE OUTPUT, IF REQUESTED
if nargout > 0
    UnitData = [UnitData, table(AvgRateBASAL), table(AvgRateSTIM)];
    UnitData = AppendGroupAssignments({UnitData}, ...
                'MIN_N_SPK',nan, ...
                'ANIMAL_COLUMN',7, ...
                'CONDITION_COLUMN',8, ...
                'USE_RAT',false);
    UnitData = UnitData{1,1};
end

end
