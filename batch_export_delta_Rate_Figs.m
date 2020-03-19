function batch_export_delta_Rate_Figs(dFR_table,varargin)
%BATCH_EXPORT_DELTA_RATE_FIGS  Export figures regarding delta-firing rate
%
%  batch_export_delta_Rate_Figs(dFR_table,'NAME',value,...);
%  --> dFR_table : Output by `compute_delta_FR`
%     * Should have 3 cells: 
%        + {1,1} -- 'BASAL' or 'PRE' (10 mins)
%        + {1,2} -- 'STIM'           (20 mins)
%        + {1,3} -- 'POST'           (15 mins)
%
%  --> <'NAME',value> pair syntax for setting optional parameters
%     * Default parameters are loaded from `defs.WholeTrialFigs`

pars = parseParameters('Experiment',varargin{:});


end