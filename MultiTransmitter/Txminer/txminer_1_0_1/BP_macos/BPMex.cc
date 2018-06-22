// matlab include
#include "mex.h"
#include "matrix.h"

// c++ include
#include "Node.h"
#include "Factor.h"
#include "FactorGraph.h"
#include "MyUtility.h"
#include "LoopyBP.h"

#include <stdlib.h>
#include <functional>
#include <numeric>
#include <algorithm>
#include <vector>
#include <math.h>

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[])
// rhs (input): 
// rhs[0]: evidence of each node(1D cell)
// rhs[1]: linkage: a pair of nodes attached to each factor(i.e., link) (1D cell), 
// rhs[2]: potential of each factor (1D cell), 
// rhs[3]: flag of max-sum or sum-product (bool)
// lhs (output):
// in case of max-sum
// lhs[0]: MAP state of each node (1D array),
// lhs[1]: optimal cost (a scalar),
// lhs[2]: convergence (bool)
// in case of sum-product
// lhs[0]: Marginal of each node (1D cell),
// lhs[1]: convergence (bool)
{
	if ( nrhs != 4 ) { 
		return;
	}
	double maxSumFlag = mxGetScalar(prhs[3]);
	bool isMaxSum = maxSumFlag > 0 ? true: false;
	if ( isMaxSum & (nlhs > 3)) {
		return;
	}
	if ( !isMaxSum & (nlhs > 2)) {
		return;
	}
	if ( !mxIsCell(prhs[0]) | 
		 !mxIsCell(prhs[1]) |
		 !mxIsCell(prhs[2]) )
	{
		return;
	}

	size_t n_nodes = mxGetNumberOfElements(prhs[0]);
	size_t n_factors = mxGetNumberOfElements(prhs[1]);
	
	vector<int> nStates(n_nodes);
	vector<pair<int, int> > linkage(0);

	for(unsigned int i=0 ; i < n_nodes ; i++) {
		const mxArray* evidence = mxGetCell(prhs[0], i);
		size_t nstates = mxGetNumberOfElements(evidence);
		//mexPrintf("%d \n", nstates);
		nStates[i] = (int)nstates;
	}
	for(unsigned int i=0 ; i < n_factors ; i++) {
		const mxArray* f2n_link = // f2n denotes factor2node
			mxGetCell(prhs[1], i);
		size_t nlinks = mxGetNumberOfElements(f2n_link);
		double *ptr_f2n_link = mxGetPr(f2n_link);
		for ( unsigned int j=0 ; j < nlinks ; j++) {
			unsigned int node_index = (unsigned int)ptr_f2n_link[j];
			linkage.push_back(pair<int,int>((int)i, (int)node_index));
		}
	}

	// create a graph
	FactorGraph graph((int)n_nodes, (int)n_factors, nStates, linkage);

	// assign evidence to each node
	for (unsigned int i=0 ; i < n_nodes; i++) {
		vector<double> evidence(nStates[i]);
		double *ptr_evidence = mxGetPr(mxGetCell(prhs[0],i));
		for ( unsigned int j=0 ; j < nStates[i] ; j++) {
			evidence[j] = ptr_evidence[j];
		}
		Node& node = graph.GetNode(i);
		node.AssignEvidence(evidence);
	}

	// assign potential to each factor
	for (unsigned int i=0 ; i < n_factors ; i++) {
		size_t n_states = mxGetNumberOfElements(mxGetCell(prhs[2],i));
		double *ptr_potential = mxGetPr(mxGetCell(prhs[2],i));
		vector<double> potential(n_states);
		for (unsigned int j=0 ; j < n_states ; j++) {
			potential[j] = ptr_potential[j];
		}
		Factor& factor = graph.GetFactor(i);		
		factor.AssignPotential(potential);
	}

	// inference
	LoopyBP bp(&graph);		
	if ( isMaxSum ) {
		mxLogical convergence = bp.ComputeMaxSum<false>(200,1e-4);
		//output 
		// MAP state of each node
		plhs[0] = 
			mxCreateNumericMatrix(1, n_nodes, mxUINT32_CLASS, mxREAL);
		unsigned int *ptr_MAPStates = (unsigned int*)mxGetData(plhs[0]);
		for (unsigned int i=0; i < n_nodes ; i++ ) {
			ptr_MAPStates[i] = (unsigned int)bp.GetMAPIndex(i);
		}
		// optimal cost
		double MAP_cost = bp.GetMAPProbability();
		plhs[1] = mxCreateDoubleScalar(MAP_cost);
		// convergence
		plhs[2] = mxCreateLogicalScalar(convergence);
	}
	else {
		mxLogical convergence = bp.ComputeSumProduct(200,1e-4);
		//output
		// Marginal probability of each state of each node
		mwSize ndim[1];
		ndim[0] = n_nodes;
		plhs[0] = mxCreateCellArray(1, ndim);
		for (unsigned int i=0 ; i < n_nodes ; i++) {
			mxArray* marginal =
				mxCreateDoubleMatrix(1, nStates[i], mxREAL);
			double* ptr_marginal = mxGetPr(marginal);
			for (unsigned int j=0 ; j < nStates[i] ; j++) {
				ptr_marginal[j] = bp.GetMarginal(i)[j];
			}
			mxSetCell(plhs[0], i, mxDuplicateArray(marginal));
			mxDestroyArray(marginal);
		}
		// convergence
		plhs[1] = mxCreateLogicalScalar(convergence);
	}
}
