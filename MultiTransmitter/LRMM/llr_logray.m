function [ l_lr,BIC,AIC ] = llr_logray( x, mu, phi )

    K = length(phi);
    n = length(x);
    l_lr = 0;
    temp = 0;
    for i = 1 : n
        for k = 1 : K
            temp = temp + logray_pdf(x(i),mu(k))*phi(k);
        end
        l_lr = l_lr + log(temp);
        temp = 0;
    end
    p = 2*k -1;
    BIC = log(n)*p - 2 * l_lr;
    AIC = 2*p - 2* l_lr;
end
