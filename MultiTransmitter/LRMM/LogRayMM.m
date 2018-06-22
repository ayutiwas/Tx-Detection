function [ mu, phi ] = LogRayMM( X, k, mu )

rng;
phi = 1/k * ones(1,k);
m = length(X);
inde = randperm(m);

if nargin==2
    mu = zeros(1,k);
    if k == 1
        mu = mean(X);
    elseif k == 2
        mu(1) = mean(X) - max(X)/2;
        mu(2) = mean(X) + min(X)/2;
    else    
        for i = 1:k
            mu(i) = X(inde(i));
        end
    end
end

for iter = 1 : 300
    
    pdf = zeros(m,k);
    for j = 1 : k
        pdf(:,j) = logray_pdf(X,mu(j));
    end
    pdf_w = bsxfun(@times, pdf, phi);
    W = bsxfun(@rdivide, pdf_w, sum(pdf_w, 2));
    
    prevMu = mu;
    
    for j = 1 : k
        phi(j) = mean(W(:, j));
         mu(j) = weightedAverage(W(:, j), X);
    end
    if sum((mu-prevMu).^2) < 1e-5
        break;
    end
end
%fprintf('Number of Mixtures: %d \t\t Number of Iteration : %d \n',k,iter);
end

