function [noiseMU, noiseSIGMA, noisePC] = txminer_get_noise_floor(band,data)

if(strcmp(band,'700-900')==1)
    noiseMU = -122.35;
    noiseSIGMA = 5.6;
    noisePC = 0.3;
end
if(strcmp(band,'512-700')==1 || strcmp(band,'adaptrum') == 1 || strcmp(band,'6h')==1 || strcmp(band,'wimax-gt-1.75')==1 || strcmp(band,'wimax-gt-3.5')==1 || strcmp(band,'wimax-gt-7')==1 ||strcmp(band,'controlled')==1 || strcmp(band,'uhf-mobile')==1 || strcmp(band,'a-day')==1 || strcmp(band,'uhf-long')==1 || strcmp(band,'dsa-long') || strcmp(band,'uhf-long-seattle')==1 || strcmp(band,'dsa-long-seattle')==1)
    noiseMU = -117;
    noiseSIGMA = 4.31;
    noisePC = 0.3; 
end
if(strcmp(band,'2350-2500')==1 || strcmp(band,'2350-2500-controlled')==1)
    noiseMU = -104.16;
    noiseSIGMA = 4.7;
    noisePC = 0.3;
end
if(strcmp(band,'510-700-gt')==1)
    noiseMU = -108.9;
    noiseSIGMA = 4.3;
    noisePC = 0.3;
end
if(strcmp(band,'bluetooth-controlled')==1 || strcmp(band,'wifi-controlled')==1)
    noiseMU = -104;
    noiseSIGMA = 4.3;
    noisePC = 0.3;
end
if(strcmp(band,'quantile-all-bands')==1 || strcmp(band,'ntia-1-2')==1 || strcmp(band,'ntia-3')==1 || strcmp(band,'ntia-4-5')==1)
    noiseMU = -92;
    idx=find(data<=noiseMU);
    noiseSIGMA = std(data(idx));
    noisePC = 0.3;
end

