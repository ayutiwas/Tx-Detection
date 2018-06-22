---------------------------------------------------
MATLAB interface for Loopy Belief Propagation
	Written by Jaechul Kim
    jaechul at cs dot utexas dot edu
---------------------------------------------------

---------------------------------------------------
compile

---------------------------------------------------
Extract BP.zip and run mexCompile.m in Matlab
 --> will produce mex file for your operating system: e.g., BPMex.mexa64 for linux 64bits
(This code is tested under Linux 64-bit and 32-bit, using Matlab r2007b and GCC4.2.2, including pre-compiled mex for Linux 32 and 64bits.)

---------------------------------------------------
example use

---------------------------------------------------
% max-sum

[MAPInds MaxVal converge] = BPMex(evidence, linkage, potential, true); 

% sum-product

[Marginals converge] = BPMex(evidence, linkage, potential, false);


%% input

% evidence: n by 1 cell
    
	% n = # of graph nodes
	% each cell = s by 1 vector, s = # of states of a node, s can change
    
	% for each node.
% linkage: m by 1 cell
    
	% m = # of graph edges
    
	% each cell = 1 by 2 vector, e.g., [0 1], which means a node0 and a
 node1 is linked by an edge.

	% node index is zero-based.

% potential: m by 1 cell
    
	% m = # of graph edges
	% each cell = s1 by s2 matrix, s1, s2 = # of states node1 and node2

        % e.g., if linkage{i} = [0 5], and potential{i}(3,2) = 0.04, then, a pair-wise potential value of state 3 of node0 and state 2 of node5 is 0.04.

% alg_flag: true --> max-sum, false --> sum-product



%% output

% in case of max-sum

% MAPInds: MAP state of each node (n by 1 vector)

	% n = # of graph nodes

	% MaxVal: optimal cost (a scalar)
	
% converge: convergence flag(bool)

% in case of sum-product

% Marginals: Marginal of each node: n by 1 cell

	% n = # of graph nodes
	% each cell = s by 1 vector, s = # of states of a node

% converge: convergence flag(bool)

------------------------------------------------------
License
------------------------------------------------------
This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by 
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version. 
For more details, see the GNU General Public License.


-----------------------------------------------------
Citation
-----------------------------------------------------
If you use this code, please cite the following paper:
Jaechul Kim and Kristen Grauman. Observe Locally, Infer Globally: a Space-Time MRF for Detecting Abnormal Activities with Incremental Updates. CVPR 2009.