function [ noise_out ] = get_noise( data )

[m,n,~] = size(data);

for i = 1 : m
    for j = 1 : n
        noise_data = data(i,j,:);
        noise_data = noise_data(:);
        data_hist(i,j) = sum(abs(noise_data).^2);
    end
end
[~, I] = min(data_hist(:));

[I_row, I_col] = ind2sub(size(data_hist),I);

noise_out = data(I_row,I_col,:);
noise_out = noise_out(:);

end

