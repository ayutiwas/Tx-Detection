function [probMat, RayleighMu, noiseMu, noiseSigmaSq, RayleighWt, noiseWt, BIC] = MixModel(Xmat, init_RayleighMu, init_noiseMu, init_noiseSigmaSq, init_RayleighWt, init_noiseWt) 

X = Xmat(:);
Ncomponents = length(init_RayleighMu) + 1;

prob = zeros(length(X), Ncomponents);

wt = [init_RayleighWt init_noiseWt];
Mu = [init_RayleighMu init_noiseMu];
noiseSigmaSq = init_noiseSigmaSq;

converged = 0; old_negllk = 1e9;
while ~converged
    
    for c = 1:Ncomponents - 1
        RayParam = Mu(c)/sqrt(pi/2);
        prob(:, c) = log((X/(RayParam^2))) - (X.^2/(2*RayParam^2));
    end
    prob(:, end) = normpdfln(X', Mu(end), sqrt(noiseSigmaSq))';
    
    numerator = repmat(log(wt), length(X), 1) + prob;
    log_Z = logsumexp(numerator, 2);
    prob = exp(numerator - repmat(log_Z, 1, Ncomponents));

    Mu = sum((repmat(X, 1, Ncomponents).*prob))./sum(prob);
    noiseSigmaSq = sum(((X - Mu(end)).^2).*prob(:, end))./sum(prob(:, end));
    if noiseSigmaSq == 0 noiseSigmaSq = 1e-100; end; %%%NEW LINE ADDED
    wt = mean(prob);

    %Z(Z<0) = 1e-10;
    
    negllk = -sum(log_Z);
    if old_negllk - negllk < 1e-3
        converged = 1;
    end
    
    old_negllk = negllk;
end

probMat = zeros(size(Xmat,1), size(Xmat,2), Ncomponents);
cnt = 1;
for i = 1:size(Xmat, 2)
    for j = 1:size(Xmat, 1)
        probMat(j, i, :) = prob(cnt, :);
        cnt = cnt + 1;
    end
end
    
RayleighWt = wt(1:end-1);
noiseWt = wt(end);
RayleighMu = Mu(1:end-1);
noiseMu = Mu(end);

BIC = 2*negllk + ((length(Mu) + length(wt) + 1)*(log(length(X)) - log(2*pi)));

function p = normpdfln(x, m, S, V)
% NORMPDFLN    log of multivariate normal density.
%   See NORMPDF for argument description.

log2pi = 1.83787706640935;
[d, n] = size(x);
if nargin == 1
  dx = x;
elseif isempty(m)
  dx = x;
else
  % m specified
  sz = size(m);
  if sz(1) ~= d
    error('rows(m) ~= rows(x)')
  end
  nm = sz(2);
  if nm == 1
    dx = x - repmat(m,1,n);
  elseif n == 1
    dx = repmat(x,1,nm) - m;
  elseif nm == n
    dx = x - m;
  else
    error('incompatible number of columns in x and m')
  end
end
if nargin < 3
  % unit variance
  p = -0.5*(d*log2pi + col_sum(dx.*dx));
  return
end
have_inv = 0;
if nargin == 3
  % standard deviation given
  if d == 1
    dx = dx./S;
    p = (-log(S) -0.5*log2pi) - 0.5*(dx.*dx);
    return;
  end
  if S(2,1) ~= 0
    error('S is not upper triangular')
  end
  if any(size(S) ~= [d d])
    error('S is not the right size')
  end
else
  if ischar(V)
    if strcmp(V,'inv')
      % inverse stddev given
      iS = S;
      have_inv = 1;
    else
      error('unknown directive')
    end
  elseif ischar(S)
    if strcmp(S,'inv')
      % inverse variance given
      if d == 1
        iS = sqrt(V);
      else
        iS = chol(V);
      end
      have_inv = 1;
    else
      error('unknown directive')
    end
  else
    % variance given
    if d == 1
      S = sqrt(V);
    else
      S = chol(V);
    end
  end
end
if have_inv
  if d == 1
    dx = iS .* dx;
    logdetiS = log(iS);
  else
    dx = iS*dx;
    logdetiS = sum(log(diag(iS)));
  end
else
  if d == 1
    dx = dx./S;
    logdetiS = -log(S);
  else
    dx = solve_tril(S',dx);
    %dx = S'\dx;
    logdetiS = -sum(log(diag(S)));
  end
end
p = (logdetiS -0.5*d*log2pi) -0.5*col_sum(dx.*dx);

function s = logsumexp(x, dim)
% Compute log(sum(exp(x),dim)) while avoiding numerical underflow.
%   By default dim = 1 (columns).
% Written by Michael Chen (sth4nth@gmail.com).
if nargin == 1, 
    % Determine which dimension sum will use
    dim = find(size(x)~=1,1);
    if isempty(dim), dim = 1; end
end

% subtract the largest in each column
y = max(x,[],dim);
x = bsxfun(@minus,x,y);
s = y + log(sum(exp(x),dim));
i = find(~isfinite(y));
if ~isempty(i)
    s(i) = y(i);
end