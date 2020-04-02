function extract_STIM_epoch(stimFile,board_dig_in_data,board_dig_in_channels,t)
%EXTRACT_STIM_EPOCH  Extract STIM epoch start,stop times etc.
%
%  extract_STIM_epoch(stimFile,board_dig_in_data,board_dig_in_channels,t);
%
%  -- inputs --
%  stimFile  :  Name of output file to save stim epoch start/stop in
%  board_dig_in_data   :  Matrix of stream data; rows are channels
%  board_dig_in_channels : Struct or struct array corresponding to matrix
%  t : Time vector, where columns correspond to columns of data matrix
%
%  -- output --
%  Saves a file (hopefully to the corresponding block; but entirely depends
%  on name of `stimFile`; no error-checking in this function). File
%  contains the following variables:
%
%     * 't'                         :  Time (seconds) of all data columns
%     * 't_stim'                    :  All times (minutes) of STIM - HIGH
%     * 't_stim_start'              :  Time (minutes) of STIM epoch START
%     * 't_stim_stop'               :  Time (minutes) of STIM epoch STOP
%     * 'board_dig_in_data'         :  Data used to parse START/STOP times
%     * 'board_dig_in_channels'     :  Channels struct array (rows of data)
%     * 'has_dig_epoch_saved'       :  True if parsing succeeded 

pars = struct;
[pars.DEF_START_TIME,pars.DEF_STOP_TIME,pars.DIG_SIG_NAME] = ...
   defs.Experiment('DEF_STIM_EPOCH_START','DEF_STIM_EPOCH_STOP',...
      'STIM_DIG_INDICATOR_NAME');

fprintf(1,'Saving <strong>STIM</strong> epoch start/stop times...');
if size(board_dig_in_data,1) > 1
   ch_names = {board_dig_in_channels.custom_channel_name};
   idx = find(strcmpi(ch_names,pars.DIG_SIG_NAME));
   if isempty(idx)
      idx = 0;
      has_dig_epoch_saved = false;
      while ~has_dig_epoch_saved
         idx = idx + 1;
         t_stim = t(1,board_dig_in_data(idx,:)>0)/60;
         t_stim_start = min(tmp);
         t_stim_stop = max(tmp);
         checkNextBoardChannel = ...
            (t_stim_start > 5) && ...
            (t_stim_stop < 60) && ...
            (idx<=size(board_dig_in_data,1));
         has_dig_epoch_saved = ~checkNextBoardChannel;
      end
      
      if checkNextBoardChannel % If still haven't found it
         t_stim_start = pars.DEF_START_TIME; % Assign default times
         t_stim_stop  = pars.DEF_STOP_TIME;
      end
      
   else
      t_stim = t(1,board_dig_in_data(idx,:)>0)/60;
      if isempty(t_stim) % If no stim switch data
         has_dig_epoch_saved = false;
         t_stim_start = pars.DEF_START_TIME; % Assign default times
         t_stim_stop = pars.DEF_STOP_TIME;
      else
         has_dig_epoch_saved = true;
         t_stim_start = min(t_stim);
         t_stim_stop = max(t_stim);
      end
   end
else
   t_stim = t(1,board_dig_in_data>0)/60;
   if isempty(t_stim) % If no stim switch data
      has_dig_epoch_saved = false;
      t_stim_start = pars.DEF_START_TIME; % Assign default times
      t_stim_stop = pars.DEF_STOP_TIME;
   else
      has_dig_epoch_saved = true;
      t_stim_start = min(t_stim);
      t_stim_stop = max(t_stim);
   end
end
save(stimFile,...
   't',...
   't_stim',...
   't_stim_start',...
   't_stim_stop',...
   'board_dig_in_data',...
   'board_dig_in_channels',...
   'has_dig_epoch_saved',...
   '-v7.3');
fprintf(1,'complete!\n');

end