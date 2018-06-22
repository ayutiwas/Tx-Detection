function [ val ] = logray_pdf( Z , M )

    Y = exp(Z);
    B = exp(M - (0.05796));
    
    val = (Y.^2/B^2).*exp(-0.5 * Y.^2/B^2);

end

