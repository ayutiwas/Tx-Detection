#include "Node.h"
#include "MyUtility.h"
#include <algorithm>
#include <numeric>
#include <math.h>

Node::Node( int nStates ) 
: m_nStates(nStates), 
m_evidence(nStates), m_logEvidence(nStates),
m_marginal(nStates,0.0),
m_mapProbability(0.0),
m_mapIndex(-1),
m_likelihood(0.0)
{}
Node::Node(const vector<double>& evidence)
: m_nStates(evidence.size()), 
m_evidence(evidence),m_logEvidence(evidence.size()),
m_marginal(evidence.size(),0.0),
m_mapProbability(0.0),
m_mapIndex(-1),
m_likelihood(0.0)
{
	transform(evidence.begin(), evidence.end(),
		m_logEvidence.begin(), 
		LOG<double>() );		      
}
Node::Node(const Node &that)
: m_nStates(that.m_nStates), 
m_evidence(that.m_evidence), 
m_logEvidence(that.m_logEvidence),
m_marginal(that.m_marginal),
m_mapProbability(that.m_mapProbability),
m_mapIndex(that.m_mapIndex),
m_likelihood(that.m_likelihood)
{}
Node& Node::operator =(const Node& that)
{
	if ( this == &that ) return *this;
	m_nStates = that.m_nStates;
	m_evidence = that.m_evidence;
	m_logEvidence = that.m_logEvidence;
	m_marginal = that.m_marginal;
	m_mapProbability = that.m_mapProbability;
	m_mapIndex = that.m_mapIndex;
	m_likelihood = that.m_likelihood;
	return *this;
}
int Node::GetNumberOfStates() const
{
	return m_nStates;
}
void Node::AssignSingleEvidence(int stateIndex, double value)
{
	m_evidence[stateIndex] = value;
	m_logEvidence[stateIndex] = log(value);
}
double Node::GetSingleEvidence(int stateIndex) const
{
	return m_evidence[stateIndex];
}
double Node::GetSingleLogEvidence(int stateIndex) const
{
	return m_logEvidence[stateIndex];
}
void Node::AssignSingleMarginal(int stateIndex, double value)
{
	m_marginal[stateIndex] = value;
}
double Node::GetSingleMarginal(int stateIndex) const
{
	return m_marginal[stateIndex];
}
void Node::AssignEvidence(const vector<double>& evidence)
{
	copy(evidence.begin(), evidence.end(), m_evidence.begin());
	transform(evidence.begin(), evidence.end(),
		m_logEvidence.begin(), 
		LOG<double>() );		 
}
void Node::AssignMarginal(const vector<double>& marginal)
{
	copy(marginal.begin(), marginal.end(), m_marginal.begin());
}
const vector<double>& Node::GetEvidence() const
{
	return m_evidence;
}
const vector<double>& Node::GetLogEvidence() const
{
	return m_logEvidence;
}
const vector<double>& Node::GetMarginal() const
{
	return m_marginal;
}
double Node::NormalizeMarginal() 
{
	double value = 
		accumulate(m_marginal.begin(), m_marginal.end(), 0.0);
	for_each( m_marginal.begin(), m_marginal.end(), 
		      DivideByValueInPlace<double>(value) );
	m_likelihood = value;
	return value;
}
double Node::AssignMarginalWithNormalization(vector<double>& marginal)
{
	// normalize
	double value = 
		accumulate(marginal.begin(), marginal.end(), 0.0);
	for_each( marginal.begin(), marginal.end(), 
		      DivideByValueInPlace<double>(value) );	
	m_likelihood = value;
	// compute max-difference between previous marginal
	// and current one
	transform( marginal.begin(), marginal.end(), 
			   m_marginal.begin(),
			   m_marginal.begin(),
			   AbsDifference<double>() );
	vector<double>::iterator it = 
		max_element(m_marginal.begin(), m_marginal.end());
	double difference = *it;
	// update marginal
	copy(marginal.begin(), marginal.end(), m_marginal.begin());
	return difference;
}
void Node::SetMAPProbability(double maxProb)
{
	m_mapProbability = maxProb;
}
void Node::SetMAPIndex(int index)
{
	m_mapIndex = index;
}
double Node::GetMAPProbability() const
{
	return m_mapProbability;
}
int Node::GetMAPIndex() const
{
	return m_mapIndex;
}
double Node::GetLikelihood() const
{
	return m_likelihood;
}
