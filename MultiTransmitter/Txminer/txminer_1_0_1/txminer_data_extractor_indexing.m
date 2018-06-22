function [dataSnippet,freqrange,timerange,freqStep,timeStep] = txminer_data_extractor_indexing(filecontent, wT, offsetT, sF, eF);
%data_extractor gets an array over time and frequency and feeds it to the
%MM. The format of the input file filenanme is date '\t' startTime '\t' endTime '\t'
%startFreq '\t' endFreq '\t' n*[PSD]. wT is the time window we are 
%interested in, sF is start frequency and eF is the end frequency.

startFreq=filecontent.data(1,1);
endFreq=filecontent.data(1,2);

size(filecontent.data);

freqSamples = length(filecontent.data(1,:))-2; % remember that the first two values are start and end freq, not PSD.
freqStep = (endFreq - startFreq)/(freqSamples-2);

timeSamples = length(filecontent.textdata(:,1));
timeStep = timeToSeconds(filecontent.textdata(2,2)) - timeToSeconds(filecontent.textdata(1,2));

dataArray = [];

file_startTime = timeToSeconds(filecontent.textdata(1,1));

timeStartIdx = round(1 + ((offsetT - file_startTime)/timeStep));
timeEndIdx = timeStartIdx + round(wT/timeStep);

freqStartIdx = round(3 + (sF-startFreq)/freqStep); % 3 instead of 1 because the first two values in filecontent.data are start and end frequencies, not PSD.
freqEndIdx = freqStartIdx + round((eF-sF)/freqStep);

frequencies = [];
times = [];

dataSnippet = filecontent.data(timeStartIdx:timeEndIdx,freqStartIdx:freqEndIdx);
[numTimeSamps,numFreqSamps] = size(dataSnippet);
for i=1:numFreqSamps
    frequencies = [frequencies sF+(i-1)*freqStep];
end
freqrange = frequencies;
for i=1:numTimeSamps
	times = [times timeStartIdx+(i-1)*timeStep];
end

timerange = times;
end
