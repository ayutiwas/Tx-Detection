function [infile] = txminer_load_infile(freqRange)

if(strcmp(freqRange,'sample_run') == 1)
    infile = './infiles/Redmond99_130401_122821_512-700.tsv';
end