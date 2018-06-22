# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 15:08:23 2018

@author: keyur
"""

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
signal_amp = 1

freq = [0, -2.5e6, 2.5e6]

constellation_variable = digital.constellation_16qam().base();

for snr in [0, 10, 20, 30, 40]:
    
    for file_num in xrange(1,101):
         
        freq = numpy.random.permutation([0, -2.5e6, 2.5e6])
        snr_new = numpy.random.permutation([snr-5, snr+5])
        
        source_A =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
        source_B =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
        #source_C =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
        #source_D =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
        #source_E =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
        throttle_A = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True)
        throttle_B = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True)        
        constellation_modulator_A = digital.generic_mod(constellation=constellation_variable,
                                                      differential=False,
                                                      samples_per_symbol=sps,
                                                      pre_diff_code=True,
                                                      excess_bw=0.35,
                                                      verbose=False,
                                                      log=False,
                                                      )
        constellation_modulator_B = digital.generic_mod(constellation=constellation_variable,
                                                      differential=False,
                                                      samples_per_symbol=sps,
                                                      pre_diff_code=True,
                                                      excess_bw=0.35,
                                                      verbose=False,
                                                      log=False,
                                                      )
                                                      
        sig_source_A = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[1],(10**(float(snr_new[0])/20))*noise_amplitude , 0) 
        sig_source_B = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[2],(10**(float(snr_new[1])/20))*noise_amplitude , 0)
        const_A = analog.sig_source_f(0, analog.GR_CONST_WAVE,0,0,0)
        
        resampler_A = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)
        resampler_B = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)        
        multiply_A = blocks.multiply_vcc(1)
        multiply_A1 = blocks.multiply_vcc(1)
        multiply_B = blocks.multiply_vcc(1)
        float_to_complex_A = blocks.float_to_complex(1)
        
        delay_B = blocks.delay(gr.sizeof_gr_complex*1,500000)
        sqr_source_A = analog.sig_source_f(samp_rate_base, analog.GR_SQR_WAVE, -1 , signal_amp , 0)
        
        channel_A = channels.fading_model( 12, 0, False, 4.0, 0 )
        channel_B = channels.fading_model( 12, 0, False, 4.0, 0 )        
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
        file_sink = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/keyur/data/data_file_2tx/data_'+str(snr)+'dB_'+str(file_num)+'.dat', False)
        
        tb = gr.top_block()
        
        tb.connect(source_A,throttle_A, constellation_modulator_A, resampler_A, (multiply_A,0))
        tb.connect(sig_source_A, (multiply_A,1))
        tb.connect(multiply_A,(multiply_A1,0))
        tb.connect(sqr_source_A, (float_to_complex_A,0))
        tb.connect(const_A,(float_to_complex_A,1))
        tb.connect(float_to_complex_A,(multiply_A1,1))
        tb.connect(multiply_A1, channel_A,(add_block,0))
        
        tb.connect(source_B,throttle_B, constellation_modulator_B, resampler_B, (multiply_B,0))
        tb.connect(sig_source_B, (multiply_B,1))
        tb.connect(multiply_B, channel_B,delay_B, (add_block,1))
        
        tb.connect(add_block,channel, skip_head)
        tb.connect(skip_head,head_block)
        tb.connect(head_block,file_sink)                                          
        
        tb.run()