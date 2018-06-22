function [ filecontent, rangeST ] = txminer_load_filecontent( freqRange )
% This function loads the PSD values from the input file in filecontent and
% also gets the first timestamp in the file (in seconds), which is needed
% for time window calculation.

infile = txminer_load_infile(freqRange)
filecontent = importdata(infile,'\t');

if(isempty(strfind(freqRange,'compress')))
    rangeST=timeToSeconds(filecontent.textdata(1,1))
    numTsamps=length(filecontent.textdata(:,1));
    rangeET=timeToSeconds(filecontent.textdata(numTsamps,1));
else
    rangeST=filecontent(1,1);
    numTsamps=length(filecontent(:,1));
    rangeET=filecontent(end,1);
end


end

