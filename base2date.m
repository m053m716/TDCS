function Date = base2date(base)
%BASE2DATE  Convert base recording name to date
%
%  Date = base2date(base);
%  e.g.
%  >> base = 'TDCS-01_2017_06_03_00';
%  >> Date = base2date(base);
%     --> Date : '2017-06-03'

if iscell(base)
   Date = cell(size(base));
   for i = 1:numel(base)
      Date{i} = base2date(base{i});
   end
   return;
end

strInfo = strsplit(base,'_');
Date = strjoin(strInfo(2:4),'-');

end