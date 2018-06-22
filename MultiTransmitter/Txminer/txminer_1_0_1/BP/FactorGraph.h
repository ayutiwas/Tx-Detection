#pragma once
#include<vector>
#include <utility>
using namespace std;

class Node;
class Factor;

class FactorGraph {
public:
	FactorGraph( int nNodes, int nFactors, 
		         const vector<int>& nStates,
				 const vector<pair<int,int> >& linkage );
	FactorGraph( const FactorGraph& that);
	virtual ~FactorGraph();
	FactorGraph& operator = ( const FactorGraph& that);
protected:
	FactorGraph( int nNodes, int nFactors, 
		         const vector<int>& nStates );
	FactorGraph( int nNodes, int nFactors, 
		         int nStates );
protected:
	vector<Node*> m_nodes;
	vector<Factor*> m_factors;
	vector<vector<int>* > m_factor2nodeLinkage;
	vector<vector<int>* > m_node2factorLinkage;
public:
	const Node& GetNode(int nodeIndex) const;
	Node& GetNode(int nodeIndex);
	const Factor& GetFactor(int factorIndex) const;
	Factor& GetFactor(int factorIndex);
	void ReplaceNode(int nodeIndex, const Node& newNode, bool factorUpdate);
	int GetNumberOfNodes() const;
	int GetNumberOfFactors() const;
	const vector<int>& GetNeighborFactorIndices(int nodeIndex) const;
	const vector<int>& GetNeighborNodeIndices(int factorIndex) const;
protected:
	void AllocateFactorAll();	
	virtual void SetLinkage(int factorIndex, int nodeIndex);	
	void AllocateFactor(int factorIndex);
private:
	void Destroy();
	void Copy(const FactorGraph& that);
};

