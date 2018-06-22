#pragma once
#include "FactorGraph.h"

class FactorGraph;
class MRF2 : public FactorGraph
{
private:
	int m_nWidth;
	int m_nHeight;
public:
	MRF2(int nWidth, int nHeight, const vector<int> nStates);
	MRF2(int nWidth, int nHeight, int nStates);
	MRF2(const MRF2& that);
	MRF2& operator=(const MRF2& that);
	virtual ~MRF2();
public:
	virtual void SetLinkage(int factorIndex, int nodeIndex);
	int GetHorizontalDimension() const;
	int GetVerticalDimension() const;
private:
	void CreateLinkage();
};
