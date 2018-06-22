#include "FactorGraph.h"
#include "FactorGraphOfMRF3.h"

MRF3::MRF3(int nWidth, int nHeight, int nLength, int nStates) 
: FactorGraph(nWidth*nHeight*nLength, 
			  (nWidth-1) * nHeight * nLength + 
			   nWidth * (nHeight-1) * nLength +
			   nWidth * nHeight * (nLength-1), 
			  nStates ),
  m_nWidth(nWidth), 
  m_nHeight(nHeight),
  m_nLength(nLength)
{
	CreateLinkage();
	AllocateFactorAll();
}
MRF3::MRF3(int nWidth, int nHeight, int nLength, const vector<int> nStates) 
: FactorGraph(nWidth*nHeight*nLength, 
			  (nWidth-1) * nHeight * nLength + 
			   nWidth * (nHeight-1) * nLength +
			   nWidth * nHeight * (nLength-1), 
			  nStates ),
  m_nWidth(nWidth), 
  m_nHeight(nHeight),
  m_nLength(nLength)
{
	CreateLinkage();
	AllocateFactorAll();
}
MRF3::MRF3(const MRF3& that)
: FactorGraph(that), 
m_nWidth(that.m_nWidth), 
m_nHeight(that.m_nHeight),
m_nLength(that.m_nLength)
{
}
MRF3& MRF3::operator=(const MRF3& that) 
{
	(FactorGraph&)(*this) = that;
	m_nWidth = that.m_nWidth;
	m_nHeight = that.m_nHeight;
	m_nLength = that.m_nLength;
	return *this;
}
MRF3::~MRF3()
{
}
void MRF3::SetLinkage(int factorIndex, int nodeIndex)
{
	// Do nothing
}

///////////////////////////////////////////////////////////
// Index of factors and nodes 
// node : 
// row-wise indexing in spatial domain. 
// temporal indexing happens after spatial indexing.
// factor : 
// the same indexing as 2D-MRF 
// except temporal indexing happens after spatial indexing
///////////////////////////////////////////////////////////
void MRF3::CreateLinkage()
{
	int nNodesInPlane = m_nWidth * m_nHeight;
	int nFactorsInPlane = (m_nWidth - 1) * m_nHeight + 
		                  m_nWidth * ( m_nHeight - 1) +
						  m_nWidth * m_nHeight;

	for ( int l =0 ; l < m_nLength ; l++)
	{
		int factorIndexOffset = l * nFactorsInPlane;
		int nodeIndexOffset = l * nNodesInPlane;
		//create linkage in the horizontal direction
		for ( int h = 0; h < m_nHeight ; h++) 
		{
			for ( int w = 0; w < m_nWidth-1 ; w++) 
			{
				int factorIndex = w + (2*m_nWidth-1)*h + factorIndexOffset;
				int nodeIndex1 = w + m_nWidth*h + nodeIndexOffset;
				int nodeIndex2 = nodeIndex1 + 1;
				FactorGraph::SetLinkage(factorIndex, nodeIndex1);
				FactorGraph::SetLinkage(factorIndex, nodeIndex2);
			}
		}
		//create linkage in the vertical direction
		for ( int h = 0; h < m_nHeight-1 ; h++)
		{
			for ( int w =0; w < m_nWidth ; w++) 
			{
				int factorIndex = 
					w + (2*m_nWidth-1)*h + m_nWidth-1 + factorIndexOffset;
				int nodeIndex1 = w + m_nWidth*h + nodeIndexOffset;
				int nodeIndex2 = w + m_nWidth*(h+1) + nodeIndexOffset;
				FactorGraph::SetLinkage(factorIndex, nodeIndex1);
				FactorGraph::SetLinkage(factorIndex, nodeIndex2);
			}
		}		
		if ( l < m_nLength - 1 )
		{
			//create linkage in the length direction (i.e. temporal direction)
			int factorIndexInLengthAxis = 
				factorIndexOffset + 
				(m_nWidth - 1) * m_nHeight + 
				m_nWidth * ( m_nHeight - 1);
			for ( int h =0 ; h < m_nHeight ; h++)
			{
				for ( int w = 0; w < m_nWidth ; w++)
				{
					int nodeIndex1 = w + m_nWidth*h + nodeIndexOffset;
					int nodeIndex2 = nodeIndex1 + nNodesInPlane;
					FactorGraph::SetLinkage(factorIndexInLengthAxis, nodeIndex1);
						FactorGraph::SetLinkage(factorIndexInLengthAxis, nodeIndex2);
					factorIndexInLengthAxis++;
				}
			}
		}
	}	
}
int MRF3::GetWidth() const
{
	return m_nWidth;
}
int MRF3::GetHeight() const
{
	return m_nHeight;
}
int MRF3::GetLength() const
{
	return m_nLength;
}
