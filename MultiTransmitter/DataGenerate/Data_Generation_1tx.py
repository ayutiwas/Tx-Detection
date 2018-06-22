from gnuradio import analog
from gnuradio import blocks
from gnuradio import channels
from gnuradio import digital
from gnuradio import gr
from gnuradio import filter
import numpy



samp_rate_base = int(1e6)
sps = 10
bps = 4
upsamp_rate = int(10e6)
noise_amplitude = 0.01

freq = [0, -2.5e6, 2.5e6]

constellation_variable = digital.constellation_16qam().base();

for snr in [0, 10, 20, 30, 40]:
    
    for file_num in xrange(1,101):
        freq = numpy.random.permutation([0, -2.5e6, 2.5e6])
        source_A =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
        
        throttle_A = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True)
        
        constellation_modulator_A = digital.generic_mod(constellation=constellation_variable,
                                                      differential=False,
                                                      samples_per_symbol=sps,
                                                      pre_diff_code=True,
                                                      excess_bw=0.35,
                                                      verbose=False,
                                                      log=False,
                                                      )
                                                      
        sig_source_A = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[0],(10**(snr/20))*noise_amplitude , 0) 
        
        resampler_A = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)
        
        multiply_A = blocks.multiply_vcc(1)
        
        channel_A = channels.fading_model( 12, 0, False, 4.0, 0 )
        
        add_block = blocks.add_vcc(1)
        
        channel = channels.channel_model(
                	noise_voltage=noise_amplitude,
                	frequency_offset=0.0,
                	epsilon=1.0,
                	taps=(1+1j, ),
                	noise_seed=0,
                	block_tags=False
                )
        
        skip_head = blocks.skiphead(gr.sizeof_gr_complex*1, 1024)
        head_block = blocks.head(gr.sizeof_gr_complex*1, 1000000)
        file_sink = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/keyur/data/data_file_1tx/data_'+str(snr)+'dB_'+str(file_num)+'.dat', False)
        
        tb = gr.top_block()
        
        tb.connect(source_A,throttle_A, constellation_modulator_A, resampler_A, (multiply_A,0))
        tb.connect(sig_source_A, (multiply_A,1))
        tb.connect(multiply_A, channel_A)
        
        tb.connect(channel_A, channel)
        
        tb.connect(channel, skip_head)
        tb.connect(skip_head,head_block)
        tb.connect(head_block,file_sink)                                          
        
        tb.run()
