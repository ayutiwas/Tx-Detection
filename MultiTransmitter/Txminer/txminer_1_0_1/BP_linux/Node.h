#pragma once 
#include <vector>
using namespace std;

class Node {
public:
	explicit Node( int nStates );
	explicit Node( const vector<double>& evidence);
	Node(const Node& that);
	Node& operator = (const Node& that);
private:	
	int m_nStates;
	vector<double> m_evidence;
	vector<double> m_logEvidence;
	vector<double> m_marginal;
	double m_mapProbability;
	int m_mapIndex;
	double m_likelihood;
public:
	int GetNumberOfStates() const;
	void AssignSingleEvidence(int stateIndex, double value);
	void AssignSingleMarginal(int stateIndex, double value);
	void AssignEvidence(const vector<double>& evidence);
	void AssignMarginal(const vector<double>& marginal);
	double GetSingleEvidence(int stateIndex) const;
	double GetSingleLogEvidence(int stateIndex) const;
	double GetSingleMarginal(int stateIndex) const;
	const vector<double>& GetEvidence() const;
	const vector<double>& GetLogEvidence() const;
	const vector<double>& GetMarginal() const;
	double NormalizeMarginal();
	double AssignMarginalWithNormalization(vector<double>& marginal);
	void SetMAPProbability(double maxProb);
	double GetMAPProbability() const;
	int GetMAPIndex() const;
	void SetMAPIndex(int index);
	double GetLikelihood() const;
};
