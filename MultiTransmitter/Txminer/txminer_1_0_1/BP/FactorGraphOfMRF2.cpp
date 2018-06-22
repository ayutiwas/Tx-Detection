#include "FactorGraph.h"
#include "FactorGraphOfMRF2.h"

MRF2::MRF2(int nWidth, int nHeight, const vector<int> nStates) 
: FactorGraph(nWidth*nHeight, 
			  (nWidth-1)*nHeight + nWidth*(nHeight-1), 
			  nStates ),
  m_nWidth(nWidth), 
  m_nHeight(nHeight)
{
	CreateLinkage();
	AllocateFactorAll();
}
MRF2::MRF2(int nWidth, int nHeight, int nStates) 
: FactorGraph(nWidth*nHeight, 
			  (nWidth-1)*nHeight + nWidth*(nHeight-1), 
			  nStates ),
  m_nWidth(nWidth), 
  m_nHeight(nHeight)
{
	CreateLinkage();
	AllocateFactorAll();
}
MRF2::MRF2(const MRF2& that)
: FactorGraph(that), 
m_nWidth(that.m_nWidth), m_nHeight(that.m_nHeight)
{
}
MRF2& MRF2::operator=(const MRF2& that) 
{
	(FactorGraph&)(*this) = that;
	m_nWidth = that.m_nWidth;
	m_nHeight = that.m_nHeight;
	return *this;
}
MRF2::~MRF2()
{
}
void MRF2::SetLinkage(int factorIndex, int nodeIndex)
{
	// Do nothing
}

///////////////////////////////////////
// Index of factors and nodes (example)
// n : node, f : factor
///////////////////////////////////////
// n0-f0-n1-f1-n2
//  |    |     |
// f2    f3    f4
//  |    |     |
// n3-f5-n4-f6-n7
///////////////////////////////////////
void MRF2::CreateLinkage()
{
	//create linkage in the horizontal direction
	for ( int h = 0; h < m_nHeight ; h++) {
		for ( int w = 0; w < m_nWidth-1 ; w++) {
			int factorIndex = w + (2*m_nWidth-1)*h;
			int nodeIndex1 = w + m_nWidth*h;
			int nodeIndex2 = nodeIndex1+1;
			FactorGraph::SetLinkage(factorIndex, nodeIndex1);
			FactorGraph::SetLinkage(factorIndex, nodeIndex2);
		}
	}
	//create linkage in the vertical direction
	for ( int h = 0; h < m_nHeight-1 ; h++) {
		for ( int w =0; w < m_nWidth ; w++) {
			int factorIndex = w + (2*m_nWidth-1)*h + m_nWidth-1;
			int nodeIndex1 = w + m_nWidth*h;
			int nodeIndex2 = w + m_nWidth*(h+1);
			FactorGraph::SetLinkage(factorIndex, nodeIndex1);
			FactorGraph::SetLinkage(factorIndex, nodeIndex2);
		}
	}		
}
int MRF2::GetHorizontalDimension() const
{
	return m_nWidth;
}
int MRF2::GetVerticalDimension() const
{
	return m_nHeight;
}
