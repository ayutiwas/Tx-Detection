#pragma once
#include <vector>
#include <utility>
#include <algorithm>
using namespace std;
class FactorGraph;
class Message;

class LoopyBP
{
	typedef pair<Message*, Message*> msg_pair;
	typedef vector<msg_pair> msg_pair_vec; 
public:
	LoopyBP(FactorGraph* factorGraph);
	LoopyBP(const LoopyBP& that);
	~LoopyBP();
	LoopyBP& operator=(const LoopyBP& that);
private:
	FactorGraph* m_graph;
	vector<double> m_beliefDifferenceByIteration;
	vector<double> m_mapProbability;
	vector<msg_pair_vec*> m_factorMsgs;
	vector<msg_pair_vec*> m_nodeMsgs;	
private:
	void AllocateMessages(double init_value);
	void Destroy();
	void Copy(const LoopyBP& that);
	void UpdateMessageForSumProduct();
	void UpdateMessageForMaxSum();
	void CommunicateMessage();
	void ComputeMarginalOfAllNodes();
public:
	bool ComputeSumProduct(int nIter, double eps);
	template<bool UseTheSameConvergenceTestAsSumProduct> 
	bool ComputeMaxSum(int nIter, double eps, int nMaxNoChanges = 5);
	void ComputeJointMarginal(int factorIndex);
	double GetMAPProbability() const;
	double GetMAPProbability(int nodeIndex) const;
	int GetMAPIndex(int nodeIndex) const;
	const vector<double>& GetMarginal(int nodeIndex) const;
	const vector<double>& GetJointMarginal(int factorIndex) const;
//	double GetAvgMAPProbability() const;
};

template<bool UseTheSameConvergenceTestAsSumProduct> 
bool LoopyBP::ComputeMaxSum(int nIter, double eps, int nMaxNoChanges)
{
	AllocateMessages(0.0);
	int iter(0);
	int nNodes = m_nodeMsgs.size();
	int nNoChanges(0);
//	const int nMaxNoChanges = 5;
	vector<int> mapIndex(nNodes, -1);
	while ( iter < nIter ) 
	{
		UpdateMessageForMaxSum();
		if ( UseTheSameConvergenceTestAsSumProduct ) 
		{
			vector<double>::iterator it = 
				max_element(m_beliefDifferenceByIteration.begin(),
							m_beliefDifferenceByIteration.end());
			if ( *it < eps ) 
			{
//				cout << "Number of iterations: " << iter << endl;
				return true;
			}
		}
		else {
			int count(0);
			for ( int i=0 ; i < nNodes ; i++)
			{
				if ( mapIndex[i] == GetMAPIndex(i) )
				{
					count++;
				}
				mapIndex[i] = GetMAPIndex(i);
			}
			if ( count == nNodes ) 
			{
				nNoChanges++;
				if ( nNoChanges == nMaxNoChanges )
				{
					//cout << "Number of iterations: " << iter << endl;
					return true;
				}
			}
		}
		CommunicateMessage();
		++iter;
	}
	return false;
}
