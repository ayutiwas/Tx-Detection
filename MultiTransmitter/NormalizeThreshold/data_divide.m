function [ data_div ] = data_divide( data, multiscale,n_fft )

n = length(data);
tf = 2^multiscale;

for i = 1 : tf
    data_pre(i,:) = data(((n*(i-1)/tf)+1):((n*i)/tf));
end

data_fft = fftshift(fft(data_pre,n_fft,2));

for i = 1 : tf
    data_ = data_fft(i,:);
    for j = 1 : tf
        data_div(i,j,:) = data_(((n_fft*(j-1)/tf)+1):((n_fft*j)/tf));
    end
end
        

end

