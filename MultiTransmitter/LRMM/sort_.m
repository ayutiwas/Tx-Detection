function [ mu_new, phi_new ] = sort_( mu, phi )

mu_new = single.empty;
phi_new = single.empty;
for i = 1 : length(phi)
    if phi(i) > 0.1 && not(isnan(phi(i)))
        mu_new = [mu_new mu(i)];
        phi_new = [phi_new phi(i)];
    end
end



end

