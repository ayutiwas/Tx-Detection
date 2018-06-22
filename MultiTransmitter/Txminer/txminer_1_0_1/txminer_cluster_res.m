function [clustered_txers] = txminer_cluster_res(unclustered_txers,THR)

unclustered = unclustered_txers
compid = 1;
if(isempty(unclustered_txers))
    ctx = [];
else
    while(~isempty(unclustered))
        % Pick a value for the first connected component
        ref = unclustered(1);
        conn_comp = ref;
        % Find all values in unclustered that are not more than THR away from
        % the reference value
        for i=1:length(unclustered)
            if(i~=1)
                if(abs(unclustered(i)-ref)<THR)
                    conn_comp = [conn_comp unclustered(i)];
                end
            end
        end
        % Remove all the values from unclustered that ended up in the current
        % conn_comp (connected component).
        unclustered_new = [];
        for i = 1:length(unclustered)
            if(~ismember(unclustered(i),conn_comp))
                unclustered_new = [unclustered_new unclustered(i)];
            end
        end
        
        % Find all the values in unclustered_new that are not more than THR
        % away for any value in conn_comp. Add these values to conn_comp.
        conn_comp_add = [];
        for i=1:length(unclustered_new)
            for j = 1:length(conn_comp)
                if(abs(unclustered_new(i)-conn_comp(j))<THR)
                    conn_comp_add = [conn_comp_add unclustered_new(i)];
                end
            end
        end
        
        % Remove all the values from unclustered_new that ended up in
        % conn_comp_add.
        unclustered_new_new = [];
        for i = 1:length(unclustered_new)
            if(~ismember(unclustered_new(i),conn_comp_add))
                unclustered_new_new = [unclustered_new_new unclustered_new(i)];
            end
        end
        
        conn_comp = [conn_comp conn_comp_add];
        component = struct('compid',compid,'values',conn_comp);
        components{compid} = component;
        unclustered = unclustered_new_new;
        compid = compid + 1;
    end
    
    % Find the new clustered transmitters
    ctx = zeros(1,length(components)); % clustered transmitters
    for i=1:length(components)
        ctx(i) = mean(components{i}.values);
    end
end
clustered_txers = ctx;
