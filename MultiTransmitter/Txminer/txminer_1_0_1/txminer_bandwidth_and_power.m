function [transmitters] = txminer_bandwidth_and_power(grouped_components,signature,model,comp_occupies,noiseTHR)

numGroups = length(grouped_components)
numFreqBins = length(signature(1,:));
transmittercntr = 0;
bandwidths = [];
for g = 1:numGroups
    comps = grouped_components{g}.components;
    model.mu(comps);
    sumpower = 0;
    for f=1:numFreqBins
        for c = 1:length(comps)
            sumpower = sumpower + (signature(comps(c),f)/100)*model.mu(comps(c));
        end
    end
    power = sumpower/numFreqBins;
    if(max(model.mu(comps))>noiseTHR) % if we have an actual transmission
        % Find bandwidth
        tmp_bandwidths = [];
        for i=1:length(comps)
            bw = comp_occupies{comps(i)}.bandwidth
            if(length(bw) == 1) % consider only components that have one occupancy chunk
                tmp_bandwidths = [tmp_bandwidths bw];
            end
        end
        if(~isempty(tmp_bandwidths))
            [val idx] = max(tmp_bandwidths);
            transmittercntr = transmittercntr + 1;
            bandwidths = [bandwidths val];
            transmitter = struct('power',power,'bandwidth',val,'components',comps);
            transmitters{transmittercntr} = transmitter;
        end
    end
end

if(transmittercntr == 0)
    transmitters = cell(0);
end


