function acc_ = initAccStruct(n)
%INITACCSTRUCT  Initialize length-`n` struct array of accelerometery data
%
%  acc = initAccStruct(n);
%  >> acc = initAccStruct(0); % Initialize empty (for concatenation)
%  >> acc = initAccStruct(1); % Typical call

if nargin < 1
   n = 0;
end
acc_ = struct(...
   'x',cell(1,n),...
   'x_cal',cell(1,n),...
   'y',cell(1,n),...
   'y_cal',cell(1,n),...
   'z',cell(1,n),...
   'z_cal',cell(1,n),...
   'stim',cell(1,n),...
   't',cell(1,n),...
   'pct_move',cell(1,n),...
   'cal',cell(1,n),...
   'a_gravity_mag',cell(1,n),...
   'a_rest_offset_mag',cell(1,n),...
   'sens_mag',cell(1,n),...
   'sens_mag_cal',cell(1,n),...
   'a_mag_cal',cell(1,n),...
   'idx',cell(1,n),...
   'rat',cell(1,n),...
   'block',cell(1,n),...
   'dataFile',cell(1,n),...
   'epochs',cell(1,n),...
   'epochColors',cell(1,n),...
   'desc',cell(1,n)...
   );
end