function [comp_occupies] = txminer_transmitters1(signature,freqrange,model)

numFreqBins = length(freqrange);
% THR = 1.0;
for c=1:model.NComponents
    string = ['------------ TxMiner_transmitters1 component ',num2str(c),' mu ',num2str(model.mu(c)),'-------------'];
    disp(string);
    THR = mean([min(signature(c,:)) max(signature(c,:))])
    sflag = false;
    startF = [];
    endF = [];
    for f=1:numFreqBins
        if(f==1)
            if(signature(c,f) > THR)
                startF = [startF freqrange(f)];
                prev_sign = signature(c,f);
                sflag = true;
            else
                prev_sign = signature(c,f);
            end
        end
        if(signature(c,f) > THR && prev_sign > THR)
            % Continuing occupancy stretch
            prev_sign = signature(c,f);
        end
        if(signature(c,f) > THR && prev_sign <= THR)
            % Start a new occupancy stretch
            startF = [startF freqrange(f)];
            prev_sign = signature(c,f);
            sflag = true;
        end
        if(signature(c,f) <= THR && prev_sign > THR)
            % End occupancy stretch 
            endF = [endF freqrange(f)];
            prev_sign = signature(c,f);
            sflag = false;
        end
        if(signature(c,f) <= THR && prev_sign <= THR)
            % Continuing idle stretch
            prev_sign = signature(c,f);
        end
        if(f==numFreqBins && sflag == true)
            endF = [endF freqrange(f)];
        end
    end
%     c
%     endF
%     startF
    bw = zeros(1,length(startF));
    if(~isempty(bw))
        for i=1:length(startF)
            bw(i) = endF(i) - startF(i);
        end
    end
    co = struct('compID',c,'mu',model.mu(c),'bandwidth',bw,'fStart',startF,'fEnd',endF);
    comp_occupies{c} = co;
end