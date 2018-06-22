#include "FactorGraph.h"
#include "Node.h"
#include "Factor.h"
#include <algorithm>

FactorGraph::FactorGraph( int nNodes, int nFactors,
						  const vector<int>& nStates)
{
	for ( int i = 0 ; i < nNodes ; i++ ) 
	{
		m_nodes.push_back( new Node(nStates[i]) );
		m_node2factorLinkage.push_back(new vector<int>(0));
	}
	for ( int i = 0 ; i < nFactors ; i++) 
	{
		m_factors.push_back(NULL);
		m_factor2nodeLinkage.push_back(new vector<int>(0));
	}
}
FactorGraph::FactorGraph( int nNodes, int nFactors,
						  int nStates)
{
	for ( int i = 0 ; i < nNodes ; i++ ) 
	{
		m_nodes.push_back( new Node(nStates) );
		m_node2factorLinkage.push_back(new vector<int>(0));
	}
	for ( int i = 0 ; i < nFactors ; i++) 
	{
		m_factors.push_back(NULL);
		m_factor2nodeLinkage.push_back(new vector<int>(0));
	}
}
FactorGraph::FactorGraph( int nNodes, int nFactors,
						  const vector<int>& nStates,
						  const vector<pair<int,int> >& linkage )
{
	for ( int i = 0 ; i < nNodes ; i++ ) 
	{
		m_nodes.push_back( new Node(nStates[i]) );
		m_node2factorLinkage.push_back(new vector<int>(0));
	}
	for ( int i = 0 ; i < nFactors ; i++) 
	{
		m_factors.push_back(NULL);
		m_factor2nodeLinkage.push_back(new vector<int>(0));
	}
	vector<pair<int,int> >::const_iterator it;
	for ( it = linkage.begin() ; it != linkage.end() ; it++ )
	{
		SetLinkage( it->first, it->second );
	}
	AllocateFactorAll();
}
void FactorGraph::Copy(const FactorGraph& that)
{
	vector<Node*>::const_iterator nit;
	for (nit = that.m_nodes.begin(); nit != that.m_nodes.end(); nit++) 
	{
		m_nodes.push_back(new Node(**nit));
	}
	vector<Factor*>::const_iterator fit = that.m_factors.begin();
	for (fit = that.m_factors.begin(); fit != that.m_factors.end(); fit++)
	{
		m_factors.push_back(new Factor(**fit));
	}
	vector<vector<int>*>::const_iterator fnit;
	for (fnit = that.m_factor2nodeLinkage.begin();
		fnit != that.m_factor2nodeLinkage.end();
		fnit++) 
	{
		m_factor2nodeLinkage.push_back(new vector<int>(**fnit));
	}
	vector<vector<int>*>::const_iterator nfit;
	for (nfit = that.m_node2factorLinkage.begin();
		nfit != that.m_node2factorLinkage.end();
		nfit++) 
	{
		m_node2factorLinkage.push_back(new vector<int>(**nfit));
	}
}

FactorGraph::FactorGraph(const FactorGraph& that)
{
	Copy(that);
}
FactorGraph& FactorGraph::operator =(const FactorGraph& that)
{
	if ( this == &that) return *this;
	Destroy();
	Copy(that);
	return *this;
}
FactorGraph::~FactorGraph()
{
	Destroy();	
}
void FactorGraph::ReplaceNode(int nodeIndex, const Node& newNode, 
							 bool factorUpdate)
{
	Node *oldNode = m_nodes[nodeIndex];
	delete oldNode;
	Node *_newNode = new Node(newNode);
	m_nodes[nodeIndex] = _newNode;
	if ( factorUpdate ) 
	{
		vector<int>* n2f = m_node2factorLinkage[nodeIndex];
		vector<int>::iterator it;
		for ( it = n2f->begin() ; it != n2f->end() ; it++) {
			int factorIndex = *it;
			AllocateFactor(factorIndex);
		}
	}
}
void FactorGraph::AllocateFactor(int factorIndex)
{
	vector<int> *f2n = m_factor2nodeLinkage[factorIndex];
	sort(f2n->begin(), f2n->end());
	vector<int>::iterator it1, it2;
	vector<int> nStatesOfNodes(f2n->size());
	for ( it1 = f2n->begin(), it2 = nStatesOfNodes.begin(); 
		it1 != f2n->end() ; it1++, it2++) 
	{
		*it2 = m_nodes[*it1]->GetNumberOfStates();
	}
	Factor* oldFactor = m_factors[factorIndex];
	delete oldFactor;
	Factor *newFactor = new Factor(nStatesOfNodes);
	m_factors[factorIndex] = newFactor;
}
void FactorGraph::AllocateFactorAll()
{
	int nFactors = m_factors.size();
	for ( int i=0; i < nFactors; i++)
	{
		AllocateFactor(i);
	}
}
void FactorGraph::SetLinkage(int factorIndex, int nodeIndex)
{
	vector<int>* f2n = m_factor2nodeLinkage[factorIndex];
	vector<int>::iterator it = 
		find( f2n->begin(), f2n->end(), nodeIndex);
	if ( it == f2n->end() ) 
	{
		f2n->push_back(nodeIndex);
	}
	vector<int>* n2f = m_node2factorLinkage[nodeIndex];
	it = find( n2f->begin(), n2f->end(), factorIndex);
	if ( it == n2f->end() )
	{
		n2f->push_back(factorIndex);
	}
}
const Node& FactorGraph::GetNode(int nodeIndex) const 
{
	return *(m_nodes[nodeIndex]);
}
Node& FactorGraph::GetNode(int nodeIndex) 
{
	return *(m_nodes[nodeIndex]);
}
const Factor& FactorGraph::GetFactor(int factorIndex) const
{
	return *(m_factors[factorIndex]);
}
Factor& FactorGraph::GetFactor(int factorIndex)
{
	return *(m_factors[factorIndex]);
}
void FactorGraph::Destroy()
{
	vector<Node*>::iterator nit;
	for ( nit = m_nodes.begin(); nit != m_nodes.end(); nit++) 
	{
		delete *nit;
	}
	m_nodes.clear();
	vector<Factor*>::iterator fit;
	for ( fit = m_factors.begin(); fit != m_factors.end(); fit++) 
	{
		delete *fit;
	}
	m_factors.clear();
	vector<vector<int>* >::iterator lit;
	for ( lit = m_factor2nodeLinkage.begin();
		lit != m_factor2nodeLinkage.end(); lit++) 
	{
		(*lit)->clear();
		delete *lit;
	}
	m_factor2nodeLinkage.clear();
	for ( lit = m_node2factorLinkage.begin();
		lit != m_node2factorLinkage.end(); lit++) 
	{
		(*lit)->clear();
		delete *lit;
	}
	m_node2factorLinkage.clear();	
}
int FactorGraph::GetNumberOfNodes() const
{
	return m_nodes.size();
}
int FactorGraph::GetNumberOfFactors() const
{
	return m_factors.size();
}
const vector<int>& 
FactorGraph::GetNeighborFactorIndices(int nodeIndex) const
{
	return *(m_node2factorLinkage[nodeIndex]);
}
const vector<int>& 
FactorGraph::GetNeighborNodeIndices(int factorIndex) const
{
	return *(m_factor2nodeLinkage[factorIndex]);
}
