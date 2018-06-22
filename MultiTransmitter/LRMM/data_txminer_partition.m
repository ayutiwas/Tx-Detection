function [ data_out ] = data_txminer_partition( data_in , multiscale )

tf = 2^multiscale;

[m,n] = size(data_in);

for i = 1 : tf
    for j = 1 : tf        
        data_out(i,j,:,:) = data_in(round((m*(i-1)/tf)+1):floor(m*i/tf),((n*(j-1)/tf)+1):(n*j/tf));
    end
end



end

