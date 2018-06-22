#pragma once
#include "FactorGraph.h"

class FactorGraph;
class MRF3 : public FactorGraph
{
private:
	int m_nWidth;
	int m_nHeight;
	int m_nLength;
public:
	MRF3(int nWidth, int nHeight, int nLength, int nStates);
	MRF3(int nWidth, int nHeight, int nLength, const vector<int> nStates);
	MRF3(const MRF3& that);
	MRF3& operator=(const MRF3& that);
	virtual ~MRF3();
public:
	virtual void SetLinkage(int factorIndex, int nodeIndex);
	int GetWidth() const;
	int GetHeight() const;
	int GetLength() const;
private:
	void CreateLinkage();
};
