function [norm_pdfs_bp] = txminer_apply_bp(data,norm_pdfs)

addpath BP_macos
% addpath BP

C = 0.01; beta = 1e-3; eps = 1e-2;
nComponents = length(norm_pdfs(1,1,:));
[nrows, ncols] = size(data);

% Get the data in the cell format required by SmoothBP
Beliefs = cell(nrows, ncols);
for i = 1:nrows
    for j = 1:ncols
        tmp = zeros(1,nComponents);
        for c=1:nComponents
            tmp(c) = norm_pdfs(i, j, c)*C;
        end
        Beliefs{i, j} = tmp;
    end
end
Beliefs;

% Run BP
[out_beliefs, OutSegment] = SmoothBP(data, Beliefs, nComponents, beta, eps);

% Convert the out_beliefs from cell array to the 3D array required by the
% rest of txminer.
numTimeSamps = nrows;
numFreqSamps = ncols;
tmp = zeros(numTimeSamps, numFreqSamps, nComponents);
for i = 1:nrows
    for j = 1:ncols
        for c=1:nComponents
            tmp(i,j,c) = out_beliefs{i,j}(c)/C;
        end
    end
end

norm_pdfs_bp = tmp;