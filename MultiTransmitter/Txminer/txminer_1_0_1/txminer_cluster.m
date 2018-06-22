function clustered_txers = txminer_cluster(unclustered_txers,THRmu)

unclustered = unclustered_txers;
% Merge components
merged_comps=[];
merged_comps_idx = [];
if(length(unclustered) > 1)
    for i=1:length(unclustered)
        for ii=i:length(unclustered)
            if(i~=ii)
%                 string = sprintf('Comparing i = %d and ii = %d',i,ii);
%                 disp(string);
                if(abs(unclustered(i)-unclustered(ii))<THRmu)
                    tmp_mu = (unclustered(i) + unclustered(ii))/2;
                    merged_comps = [merged_comps tmp_mu];
                    merged_comps_idx = [merged_comps_idx i ii];
                end               
            end
        end
    end
    % if no merges occurred, merged_comps = for_merging
    if(isempty(merged_comps_idx))
        merged_comps = unclustered;
    else
        % see if a component had to be merged with more than
        % one other component.
        vals = unique(merged_comps_idx);
        instances = histc(merged_comps_idx, vals);
        idx = find(instances>1);
        if(~isempty(idx)) % There is overlap between the components in merged components (i.e. there is a case such as mu12 and mu23)
            % TODO --> how do we treat mu12 and mu23
            disp('n/a');
        else % No overlap between the components in the merged coms (i.e. there is no case like mu12 and mu23)
            for j=1:length(unclustered)
                if(~any(merged_comps_idx==j)) % if this comp was not in the merged comps, add to merged_comps
                    merged_comps = [merged_comps unclustered(j)];
                end
            end
        end
    end
else
    merged_comps = unclustered;
end
clustered_txers = merged_comps;

