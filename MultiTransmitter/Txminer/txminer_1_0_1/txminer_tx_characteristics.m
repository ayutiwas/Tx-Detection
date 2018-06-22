function [tx_char] = txminer_tx_characteristics(comp_occupies_freq,comp_occupies_time,freqrange,signature_freq,timerange,signature_time,model,noiseTHR)

% This function takes as an input the comp_occupies chunks and returns the
% transmitter characteristics.

% The characteristics we are looking for are bandwidth, active time,
% transmitter type (broadcast, TDMA, FDMA), operation frequency, power.
% bandwidth and active time are implemented in txminer_bandwidth_and_power
% type can be determined based on the variance of the signatures of the
% components. We have two types of components: (i) such that occupy a
% single contiguous chunk and such that occupy multiple fragmented chunks.
% In order to find the entire operation band of fragmented signatures we
% take the span from the beginning of the first chunk to the end of the
% last chunk. We fill 0 in between chunks to complete the signature and
% find the variance of the completed signature.

% Set time and frequency variance threshold for the type detection
tvar = 20;
fvar = 20;

%% Transmitter type
numComps = length(comp_occupies_freq); % same number of components in time and freq.
% txers = zeros(1,numComps);
txers = {};
for c=1:numComps
    if(model.mu(comp_occupies_freq{c}.compID)>noiseTHR && length(comp_occupies_freq{c}.fStart)>0)
        % transmitter begin time and frequency
        model.mu(comp_occupies_freq{c}.compID);
        comp_occupies_time{c}.bandwidth;
        comp_occupies_time{c}.fStart;
        comp_occupies_freq{c}.fEnd;
        begin_time = min(comp_occupies_time{c}.fStart);
        if(isempty(comp_occupies_freq{c}.fStart))
            begin_freq = comp_occupies_freq{c}.fEnd;
        else
            begin_freq = min(comp_occupies_freq{c}.fStart);
        end
        % transmitter end time and frequency
        end_time = max(comp_occupies_time{c}.fEnd);
        end_freq = max(comp_occupies_freq{c}.fEnd);
        
        % Get the begin/end time/frequency indices
        btime_idx = find(timerange==begin_time);
        bfreq_idx = find(freqrange==begin_freq);
        etime_idx = find(timerange==end_time);
        efreq_idx = find(freqrange==end_freq);
        
        % Find the parts of the time/freq signature between begin_time and
        % end_time and between begin_freq and end_freq. We will use these to
        % determine the transmitter type. Do not consider small sign
        % values, since those can be some unrelated activity.
        t_tmp = signature_time(c,btime_idx:etime_idx);
        f_tmp = signature_freq(c,bfreq_idx:efreq_idx);
        unrelated_t_thr = 0.2*max(t_tmp);
        unrelated_f_thr = 0.2*max(f_tmp);
        idx_t = find(t_tmp>unrelated_t_thr);
        idx_f = find(f_tmp>unrelated_f_thr);
        time_sign = t_tmp(idx_t);
        freq_sign = f_tmp(idx_f);
        
        timevarTHR = (tvar/100)*max(time_sign)
        freqvarTHR = (fvar/100)*max(freq_sign)
        
        % Find the means of these signatures. This is what we will use to
        % select the values for which to calculate the variance of the
        % signature. This approach mitigates the effects of gradually
        % rising/falling edges on the increased variance.
        
        mtime = quantile(time_sign,0.5)
        mfreq = quantile(freq_sign,0.5)
        
        
        % Find the variance of the time and freq signatures
        if(length(comp_occupies_time{c}.bandwidth)>1)
            timevar = std(time_sign)
            freqvar = std(freq_sign)
        else
            idx = find(time_sign>mtime);
            timevar = std(time_sign(idx))
            idx = find(freq_sign>mfreq);
            freqvar = std(freq_sign(idx))
        end
        
        if(isnan(timevar))
            timevar = 0;
        end
        if(isnan(freqvar))
            freqvar = 0;
        end
        
        if(timevar<timevarTHR && freqvar<freqvarTHR)
            % the transmitter is broadcast
            disp(['Component ',num2str(c),' with start freq ',num2str(begin_freq),' and end frequency ',num2str(end_freq),' is broadcast'])
            type = 'broadcast';
        end
        if(timevar<timevarTHR && freqvar>freqvarTHR)
            % the transmitter is FDMA
            disp(['Component ',num2str(c),' with start freq ',num2str(begin_freq),' and end frequency ',num2str(end_freq),' is FDMA'])
            type = 'FDMA';
        end
        if(timevar>timevarTHR && freqvar<freqvarTHR)
            % the transmitter is TDMA
            disp(['Component ',num2str(c),' with start freq ',num2str(begin_freq),' and end frequency ',num2str(end_freq),' is TDMA'])
            type = 'TDMA';
        end
        if(timevar>timevarTHR && freqvar>freqvarTHR)
            % the transmitter is frequency hopping
            disp(['Component ',num2str(c),' with start freq ',num2str(begin_freq),' and end frequency ',num2str(end_freq),' is hopping'])
            type = 'fhop';
        end
        bw = comp_occupies_freq{c}.bandwidth;
        startF = comp_occupies_freq{c}.fStart;
        endF = comp_occupies_freq{c}.fEnd;
        dur = comp_occupies_time{c}.bandwidth;
        startT = comp_occupies_time{c}.fStart;
        endT = comp_occupies_time{c}.fEnd;
        power = model.mu(comp_occupies_freq{c}.compID);

        txers{c} = struct('compID',comp_occupies_freq{c}.compID,'bandwidth',bw,'fStart',startF,'fEnd',endF,...
                   'duration',dur,'tStart',startT,'tEnd',endT,'type',type,'power',power,'freqrange',freqrange,'timerange',timerange);
    end
end
if(isempty(txers))
    tx_char = 0;
else
    tx_char = txers;
end
