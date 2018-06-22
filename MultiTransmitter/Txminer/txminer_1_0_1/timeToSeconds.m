function [ toSeconds ] = timeToSeconds( timeString )
%timeToSeconds takes as an input a string of the format hh:mm:ss and
%outputs that converted to seconds.

cc = strsplit(num2str(cell2mat(timeString)),':');
hh=str2num(cell2mat(cc(1)));
mm=str2num(cell2mat(cc(2)));
ss=str2num(cell2mat(cc(3)));

toSeconds = hh*3600 + mm*60 + ss;

end

