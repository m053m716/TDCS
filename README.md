# TDCS #

Code here pertains to analyses conducted on the paper *Effects of tDCS on Spontaneous Spike Activity in a Healthy Ambulatory Rat Model*.

## Organization ##

The bulk of analyses (as run for the paper) are integrated as sub-sections of the file `Main.m`

* In order to run these analyses, you need access to the KUMC `P:/` network drive.
* Relevant default parameters are in the package `+defs`, where by convention the parameter files are each named after the associated function (e.g. `ISIDistributionFigs`, `FlatThreshRateFigs`, etc.) or generic purpose (e.g. `FileNames`, `Spikes`, and `Experiment`).
* The code in `Main.m` can take a while to run so you may want to advance through it section-by-section.

## Extraction from Binary Data ##

Neurophysiological data was extracted from binary data files using the batch processing for Intan RHD or RHS (depending on acquisition system used for the individual recording) available in  **[`CPLTools`](https://github.com/m053m716/CPLtools/tree/master/MoveData_Isilon)**. 

## Data Processing ##

1. Data is filtered

   * For Spikes, a Multi-unit Bandpass Filter was applied, followed by a common-average re-reference wherein the mean of all channels at each sample was subtracted from all probes at each sample.

   * For LFP, decimation was implemented to reduce all sampled data to 1 kHz, using a series of Chebyshev anti-aliasing lowpass filters.

2. Traces of the processed data were inspected visually to ensure that data was free of recording artifacts due to non-biological sources. This sort of artifact is very large and typically evident by visual inspection.

   * For consistency, an RMS filter was applied to 1-second-long "chunks" of non-overlapping samples, allowing us to set an automated RMS exclusion threshold based on the distribution of raw data magnitudes that automatically rejects artifacts. **See [`make_RMS_mask`](https://github.com/m053m716/TDCS/blob/master/make_RMS_mask.m) for details. **

3. For Spikes, units were detected and sorted using a preliminary automated sorting procedure followed by a secondary manual curation step.

After these steps, initial data processing was considered complete. 

## Initial Data Analyses ##

### Spikes ###

See **[`Simple_Spike_Analysis.m`](https://github.com/m053m716/TDCS/blob/master/Simple_Spike_Analysis.m)**

### Local Field Potential (LFP) ###

* Band power for LFP bands (defined in **[`defaults.LFP()`](https://github.com/m053m716/TDCS/blob/master/%2Bdefs/LFP.m)**) was obtained using the Matlab `spectrogram` method to compute the short-time Fourier transform. 
* Within each band, frequency bins bounded by band ranges were used to compute the average RMS band power.
  * 10 frequency bins were used per band, which were log-spaced throughout the band range.
  * We then applied a log-transform to the RMS value in order to account for right-skew in the RMS distribution.
* After the RMS computation, we computed the covariance matrix of band power samples through time to determine if samples could be treated as independent, random variables.