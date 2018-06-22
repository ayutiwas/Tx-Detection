function [init_RayleighMu] = txminer_helper_cluster(models_res,res,fsplits,tsplits,data)

THRmu = 8;
[nt,nf] = size(models_res);
for tt = 1:nt
    for ff = 1:nf
        idx = find(models_res{tt,ff}.mu > -100);
        txers{tt,ff} = models_res{tt,ff}.mu(idx)';
    end
end

for r = res:-1:1
    if(r~=1)
        nf = fsplits^(r-1);
        nt = tsplits^(r-1);
        disp(['============ Resolution ',num2str(r),': nf = ',num2str(nf),' nt = ',num2str(nt),'===========']);
        cf = 0;
        for f=1:fsplits:nf
            cf = cf + 1;
            ct = 0;
            for t=1:tsplits:nt
                ct = ct + 1;
                disp(['+++++++ subspace between f = ',num2str(f),' and ',num2str(f+fsplits-1),' and t = ',num2str(t),' and ',num2str(t+tsplits-1)]);
                txers_chunk = [];
                for ff = f:f+fsplits-1
                    for tt = t:t+tsplits-1
                        string = sprintf('tt %d ff %d',tt,ff);
                        disp(string);
                        txers_chunk = [txers_chunk txers{tt,ff}];
                    end
                end
                clustered_txers = txminer_cluster_res(txers_chunk,THRmu);
                txers_next{ct,cf} = clustered_txers;
            end
        end
        txers_next
        txers = txers_next;
        txers_next = {};
    else
        clustered_txers = txminer_cluster_res(txers{1,1},THRmu);
        disp('Producing the final clusters');
        init_RayleighMu = clustered_txers
    end
end