------------------------------------------
MATLAB implementation of TxMiner. 
Written by Mariya Zheleva, mzheleva@albany.edu
To cite this code:
@inproceedings{zheleva2015txminer,
  title={Txminer: Identifying transmitters in real-world spectrum measurements},
  author={Zheleva, Mariya and Chandra, Ranveer and Chowdhery, Aakanksha and Kapoor, Ashish and Garnett, Paul},
  booktitle={2015 IEEE International Symposium on Dynamic Spectrum Access Networks (DySPAN)},
  pages={94--105},
  year={2015},
  organization={IEEE},
  url={http://www.cs.albany.edu/~mariya/lab/papers/p99-zheleva_proceedings.pdf}
}
------------------------------------------
Directory description
------------------------------------------
BP contains an implementation of Loopy Belief Propapgation by Jaechul Kim (http://userweb.cs.utexas.edu/~jaechul/)
BP_linux adn BP_macos are the compiled versions of BP for linus and macos.
infiles contains a sample file with PSD measurements
outfiles contains the output files produced by running TxMiner

------------------------------------------
Running TxMiner
------------------------------------------
From MATLAB terminal run 
>> txminer_wrapper

------------------------------------------
MATLAB version requirements
------------------------------------------
No specific requirements in terms of MATLAB version. At the moment of posting this code, 
TxMiner works with all MATLAB versions between R2012a and  R2017b.
