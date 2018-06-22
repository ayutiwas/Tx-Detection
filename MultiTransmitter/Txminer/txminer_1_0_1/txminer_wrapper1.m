clear all
close all
tic % begin timer

% INPUT parameters
RUNS = 1;
% TV settings
fStep = 8;
sFreq = 536;
eFreq = 536;
numBins = length(sFreq:fStep:eFreq);

runSpec = struct;
runSpec.('dataType') = 'real'; % controlled or real
runSpec.('freqRange') = 'sample_run'; % a string specifying the frequency range; or in other words the input file.
[filecontent,rangeST] = txminer_load_filecontent(runSpec.freqRange);
runSpec.('noise') = 'quantile-all-bands'; % uhf or empirical or wimax or bluetooth or wifi
runSpec.('res') = 1; % resolution for the hierarchical initialization
runSpec.('fsplits') = 2; % number of frequency splits per resolution
runSpec.('tsplits') = 2; % number of time splits per resolution
runSpec.('startTime') = rangeST; % in seconds
runSpec.('timeWindow') = 100; % in seconds
runSpec.('scaling') = 100; % this is a factor that scales the original data. Necessary for RGMM.
runSpec.('scaling_init') = 100; % this is a factor that scales the initialization values for RGMM.
% end INPUT parameters

% OUTPUT: Result arrays
models = cell(RUNS,numBins);
transmitters = cell(RUNS,numBins);
% end results arrays

cntrb = 0;

for b = sFreq:fStep:eFreq
    cntrb = cntrb + 1;
    for run = 1:RUNS
        % Set some more run-dependent input parameters
        runSpec.('startFreq') = b; % in MHz
        runSpec.('endFreq') = b+fStep; % in MHz
        
        
        [signature_freq,signature_time,model,TXers,data] = txminer_main(runSpec,filecontent);
        signatures_time{run,cntrb} = signature_time;
        signatures_freq{run,cntrb} = signature_freq;
        models{run,cntrb} = model;
        transmitters{run,cntrb} = TXers;
    end
end

outfile = ['./outfiles/sampRun',runSpec.freqRange,'.mat'];
save(outfile,'signatures_time','signatures_freq','models','transmitters','data');

toc % end timer