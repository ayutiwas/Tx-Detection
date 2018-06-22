from gnuradio import analog
from gnuradio import blocks
from gnuradio import channels
from gnuradio import digital
from gnuradio import gr
from gnuradio import filter
import numpy
from joblib import Parallel, delayed
import multiprocessing
    




samp_rate_base = int(1e6)
sps = 10
bps = 4
upsamp_rate = int(10e6)
noise_amplitude = 0.01
signal_amp = 1

freq = [0, -2.5e6, 2.5e6]

constellation_variable = digital.constellation_16qam().base();

def processInput1tx(file_num,snr):
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
  file_sink = blocks.file_sink(gr.sizeof_gr_complex*1, 'data_1tx_'+str(snr)+'dB_'+str(file_num)+'.dat', False)
  
  tb = gr.top_block()
  
  tb.connect(source_A,throttle_A, constellation_modulator_A, resampler_A, (multiply_A,0))
  tb.connect(sig_source_A, (multiply_A,1))
  tb.connect(multiply_A, channel_A)
  
  tb.connect(channel_A, channel)
  
  tb.connect(channel, skip_head)
  tb.connect(skip_head,head_block)
  tb.connect(head_block,file_sink)                                          
  
  tb.run()


def processInput2tx(file_num,snr):
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
  file_sink = blocks.file_sink(gr.sizeof_gr_complex*1, 'data_2tx_'+str(snr)+'dB_'+str(file_num)+'.dat', False)
  
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

def processInput5tx(file_num, snr):
    freq = numpy.random.permutation([0, -2.5e6, 2.5e6])
    snr_new = numpy.random.permutation([snr-5, snr+5, snr-10, snr+10, snr])
    
    source_A =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
    source_B =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
    source_C =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
    source_D =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
    source_E =  blocks.vector_source_b(map(int, numpy.random.randint(0, 255, 1000000)), True)
   
    throttle_A = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True)
    throttle_B = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True)   
    throttle_C = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True)
    throttle_D = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True) 
    throttle_E = blocks.throttle(gr.sizeof_char*1, samp_rate_base,True) 
    
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
    constellation_modulator_C = digital.generic_mod(constellation=constellation_variable,
                                                  differential=False,
                                                  samples_per_symbol=sps,
                                                  pre_diff_code=True,
                                                  excess_bw=0.35,
                                                  verbose=False,
                                                  log=False,
                                                  )
    constellation_modulator_D = digital.generic_mod(constellation=constellation_variable,
                                                  differential=False,
                                                  samples_per_symbol=sps,
                                                  pre_diff_code=True,
                                                  excess_bw=0.35,
                                                  verbose=False,
                                                  log=False,
                                                  )                                                      

    constellation_modulator_E = digital.generic_mod(constellation=constellation_variable,
                                                  differential=False,
                                                  samples_per_symbol=sps,
                                                  pre_diff_code=True,
                                                  excess_bw=0.35,
                                                  verbose=False,
                                                  log=False,
                                                  )        
    sig_source_A = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[1],(10**(float(snr_new[0])/20))*noise_amplitude , 0) 
    sig_source_B = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[1],(10**(float(snr_new[1])/20))*noise_amplitude , 0)
    sig_source_C = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[0],(10**(float(snr_new[2])/20))*noise_amplitude , 0)
    sig_source_D = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[2],(10**(float(snr_new[3])/20))*noise_amplitude , 0)
    sig_source_E = analog.sig_source_c(upsamp_rate, analog.GR_COS_WAVE, freq[2],(10**(float(snr_new[4])/20))*noise_amplitude , 0)
    
    
    const_A = analog.sig_source_f(0, analog.GR_CONST_WAVE,0,0,0)
    const_D = analog.sig_source_f(0, analog.GR_CONST_WAVE,0,0,0)
    
    
    resampler_A = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)
    resampler_B = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)  
    resampler_C = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)
    resampler_D = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)
    resampler_E = filter.rational_resampler_ccc(10,2,taps = None, fractional_bw = None)
    multiply_A = blocks.multiply_vcc(1)
    multiply_B = blocks.multiply_vcc(1)
    multiply_C = blocks.multiply_vcc(1)
    multiply_D = blocks.multiply_vcc(1)
    multiply_E = blocks.multiply_vcc(1)
    float_to_complex_A = blocks.float_to_complex(1)
    float_to_complex_D = blocks.float_to_complex(1)
    
    delay_B = blocks.delay(gr.sizeof_gr_complex*1,500000)
    delay_E = blocks.delay(gr.sizeof_gr_complex*1,500000)
    sqr_source_A = analog.sig_source_f(samp_rate_base, analog.GR_SQR_WAVE, -1 , signal_amp , 0)
    sqr_source_D = analog.sig_source_f(samp_rate_base, analog.GR_SQR_WAVE, -1 , signal_amp , 0)
    
    channel_A = channels.fading_model( 12, 0, False, 4.0, 0 )
    channel_B = channels.fading_model( 12, 0, False, 4.0, 0 )  
    channel_C = channels.fading_model( 12, 0, False, 4.0, 0 )
    channel_D = channels.fading_model( 12, 0, False, 4.0, 0 )
    channel_E = channels.fading_model( 12, 0, False, 4.0, 0 )
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
    file_sink = blocks.file_sink(gr.sizeof_gr_complex*1, 'data_5tx_'+str(snr)+'dB_'+str(file_num)+'.dat', False)
    
    tb = gr.top_block()
    
    tb.connect(source_A,throttle_A, constellation_modulator_A, resampler_A, (multiply_A,0))
    tb.connect(sig_source_A, (multiply_A,1))
    tb.connect(sqr_source_A, (float_to_complex_A,0))
    tb.connect(const_A,(float_to_complex_A,1))
    tb.connect(float_to_complex_A,(multiply_A,2))
    tb.connect(multiply_A, channel_A,(add_block,0))
    
    tb.connect(source_B,throttle_B, constellation_modulator_B, resampler_B, (multiply_B,0))
    tb.connect(sig_source_B, (multiply_B,1))
    tb.connect(multiply_B, channel_B,delay_B, (add_block,1))
    
    tb.connect(source_C,throttle_C, constellation_modulator_C, resampler_C, (multiply_C,0))
    tb.connect(sig_source_C, (multiply_C,1))
    tb.connect(multiply_C, channel_C,(add_block,2))        
    
    
    
    tb.connect(source_D,throttle_D, constellation_modulator_D, resampler_D, (multiply_D,0))
    tb.connect(sig_source_D, (multiply_D,1))
    tb.connect(sqr_source_D, (float_to_complex_D,0))
    tb.connect(const_D,(float_to_complex_D,1))
    tb.connect(float_to_complex_D,(multiply_D,2))
    tb.connect(multiply_D, channel_D,(add_block,3))
    
    tb.connect(source_E,throttle_E, constellation_modulator_E, resampler_E, (multiply_E,0))
    tb.connect(sig_source_E, (multiply_E,1))
    tb.connect(multiply_E, channel_E,delay_E, (add_block,4))
    tb.connect(add_block,channel, skip_head)
    tb.connect(skip_head,head_block)
    tb.connect(head_block,file_sink) 
    
    tb.run()

# what are your inputs, and what operation do you want to 
# perform on each input. For example...

num_cores = multiprocessing.cpu_count()

inputs = xrange(1,101)

for snr in [0, 10, 20, 30, 40]:
  Parallel(n_jobs=num_cores)(delayed(processInput1tx)(i,snr) for i in inputs)
  Parallel(n_jobs=num_cores)(delayed(processInput2tx)(i,snr) for i in inputs)
  Parallel(n_jobs=num_cores)(delayed(processInput5tx)(i,snr) for i in inputs)

    
