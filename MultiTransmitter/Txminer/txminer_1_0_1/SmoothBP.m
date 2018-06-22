function [out_beliefs, max_segment] = SmoothBP(PSDmatrix, BeliefCells, Nstates, beta, eps)

[nrows, ncols] = size(PSDmatrix);

N = nrows*ncols;

SamePotential = eps*rand(Nstates, Nstates) + eye(Nstates); 
DifferentPotential = (ones(Nstates) - eye(Nstates)) + eps*eye(Nstates);

Evidence = cell(N, 1);
Linkage = cell(0);
Potential = cell(0);

cnt = 1; cnt_L = 1;
for i = 1:nrows
    for j = 1:ncols
        Evidence{cnt, 1} = BeliefCells{i, j};
         
        if j ~= ncols
            Linkage{cnt_L, 1} = [cnt-1 cnt];
            
            valueDiff = beta*abs(PSDmatrix(i, j) - PSDmatrix(i, j+1));
            Potential{cnt_L, 1} = SamePotential*exp(-valueDiff) + DifferentPotential*(1-exp(-valueDiff));
            cnt_L = cnt_L + 1;
        end
        
         if i~=nrows
             Linkage{cnt_L, 1} = [cnt-1 cnt+ncols-1];

             valueDiff = beta*abs(PSDmatrix(i, j) - PSDmatrix(i+1, j));
             Potential{cnt_L, 1} = SamePotential*exp(-valueDiff) + DifferentPotential*(1-exp(-valueDiff));
             cnt_L = cnt_L + 1;
         end
         
        cnt = cnt + 1;
    end
end

[out_belief_list, SPconverge] = BPMex(Evidence, Linkage, Potential, false);
[max_val, ~, MPconverge] = BPMex(Evidence, Linkage, Potential, true);

fprintf(1, 'Convergence of Sum-Product = %d, Max-Product = %d\n', SPconverge, MPconverge);

out_beliefs = cell(nrows, ncols);
cnt = 1;
for i = 1:nrows
    for j = 1:ncols
        out_beliefs(i, j) = out_belief_list(cnt);
        cnt = cnt + 1;
    end
end

max_segment = reshape(max_val, ncols, nrows)';