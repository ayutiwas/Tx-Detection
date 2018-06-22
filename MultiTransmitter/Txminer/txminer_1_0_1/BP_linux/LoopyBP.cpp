#include "LoopyBP.h"
#include "FactorGraph.h"
#include "Node.h"
#include "Factor.h"
#include "Message.h"
#include "MyUtility.h"

#include <algorithm>
#include <functional>
#include <numeric>
#include <math.h>

LoopyBP::LoopyBP(FactorGraph* factorGraph)
: m_graph(factorGraph),
m_beliefDifferenceByIteration(m_graph->GetNumberOfNodes()),
//m_mapProbability(m_graph->GetNumberOfNodes()),
m_factorMsgs(0),
m_nodeMsgs(0)
{
//	AllocateMessages();
}
LoopyBP::LoopyBP(const LoopyBP& that)
: m_graph(that.m_graph),
m_beliefDifferenceByIteration(that.m_beliefDifferenceByIteration),
//m_mapProbability(that.m_mapProbability),
m_factorMsgs(that.m_graph->GetNumberOfFactors()),
m_nodeMsgs(that.m_graph->GetNumberOfNodes())
{
	Copy(that);	
}
LoopyBP& LoopyBP::operator =(const LoopyBP& that)
{
	if ( this == & that) return *this;
	m_graph = that.m_graph;
	m_beliefDifferenceByIteration 
		 = that.m_beliefDifferenceByIteration;
//	m_mapProbability
//		= that.m_mapProbability;
	m_factorMsgs.resize(that.m_graph->GetNumberOfFactors());
	m_nodeMsgs.resize(that.m_graph->GetNumberOfNodes() );
	Destroy();
	Copy(that);
	return *this;
}
LoopyBP::~LoopyBP()
{
	Destroy();
}
void LoopyBP::Copy(const LoopyBP& that)
{
	int nNodes = that.m_graph->GetNumberOfNodes();
	int nFactors = that.m_graph->GetNumberOfFactors();
	for ( int i=0 ; i < nFactors; i++) 
	{
		m_factorMsgs[i] = 
			new msg_pair_vec(0);
	}
	for ( int i=0; i < nNodes; i++) 
	{
		m_nodeMsgs[i] = new msg_pair_vec(0);
	}
	for ( int i=0 ; i < nFactors; i++) 
	{
		const vector<int>& neighborNodes = 
			that.m_graph->GetNeighborNodeIndices(i);
		vector<int>::const_iterator it1;
		msg_pair_vec::const_iterator it2;
		for ( it1 = neighborNodes.begin(), 
			it2 = that.m_factorMsgs[i]->begin();
			it1 != neighborNodes.end(); it1++, it2++) 
		{	
			Message *factor_msg = new Message(*(*it2).first);
			Message *node_msg = new Message(*(*it2).second);
			m_factorMsgs[i]->push_back(msg_pair(factor_msg, node_msg));
			m_nodeMsgs[*it1]->push_back(msg_pair(node_msg, factor_msg));
		}
	}	
}

void LoopyBP::Destroy()
{
	vector<msg_pair_vec*>::iterator it;
	for ( it = m_factorMsgs.begin(); it != m_factorMsgs.end() ; it++) 
	{
		msg_pair_vec *pvec = *it;
		msg_pair_vec::iterator it2;
		for ( it2 = pvec->begin() ; it2 != pvec->end() ; it2++) 
		{
			delete (*it2).first;
		}
		delete pvec;
	}
	for ( it = m_nodeMsgs.begin(); it != m_nodeMsgs.end() ; it++) 
	{
		msg_pair_vec *pvec = *it;
		msg_pair_vec::iterator it2;
		for ( it2 = pvec->begin() ; it2 != pvec->end() ; it2++) 
		{
			delete (*it2).first;
		}
		delete pvec;
	}
	m_factorMsgs.clear();
	m_nodeMsgs.clear();
}
void LoopyBP::AllocateMessages(double init_value)
{
	Destroy();
	int nNodes = m_graph->GetNumberOfNodes();
	int nFactors = m_graph->GetNumberOfFactors();
	for ( int i=0 ; i < nFactors; i++) 
	{
		m_factorMsgs.push_back(
			new msg_pair_vec(0) );
	}
	for ( int i=0; i < nNodes; i++) 
	{
		m_nodeMsgs.push_back(
			new msg_pair_vec(0) );
	}
	for ( int i=0 ; i < nFactors; i++) 
	{
		const vector<int>& neighborNodes = 
			m_graph->GetNeighborNodeIndices(i);
		vector<int>::const_iterator it;
		for ( it = neighborNodes.begin();it != neighborNodes.end(); it++) 
		{
			int size = m_graph->GetNode(*it).GetNumberOfStates();
			Message *factor_msg = new Message(size, init_value);
			Message *node_msg = new Message(size, init_value);
			m_factorMsgs[i]->push_back(msg_pair(factor_msg, node_msg));
			m_nodeMsgs[*it]->push_back(msg_pair(node_msg, factor_msg));
		}
	}
}
void LoopyBP::UpdateMessageForSumProduct()
{
	//for nodes
	int nNodes = m_nodeMsgs.size();	
	for ( int i=0; i < nNodes; i++ )
	{
		msg_pair_vec* pvec = m_nodeMsgs[i];
		Node& node = m_graph->GetNode(i);
		vector<double> total_product = node.GetEvidence();
		msg_pair_vec::const_iterator it;
		for ( it = pvec->begin(); it != pvec->end(); it++ ) 
		{
			transform( it->first->GetIncomingMessage().begin(),
				      it->first->GetIncomingMessage().end(),
					  total_product.begin(),
					  total_product.begin(),
					  multiplies<double>() );
		}
		m_beliefDifferenceByIteration[i] = 
			node.AssignMarginalWithNormalization(total_product);
		for ( it = pvec->begin() ; it != pvec->end(); it++ )
		{
			it->first->SetOutgoingMessage(total_product);
			it->first->DivideOutgoingMessageByIncomingMessage();
			it->first->NormalizeOutgoingMessage();
		}
	}
	// for factors
	int nFactors = m_factorMsgs.size();
	for ( int i=0; i < nFactors; i++ )
	{
		msg_pair_vec* pvec = m_factorMsgs[i];
		msg_pair_vec::iterator msg_it;
		// intialize outgoing messages
		for ( msg_it = pvec->begin() ; msg_it != pvec->end() ; msg_it++) 
		{
			msg_it->first->SetOutgoingMessageIntoZero();
		}
		Factor& factor = m_graph->GetFactor(i);
		const vector<double>& potential = factor.GetPotential();
		int index(0);
		// compute outgoing messages
		for ( vector<double>::const_iterator potential_it = 
			potential.begin(); 
			potential_it != potential.end(); 
			potential_it++, index++) 
		{
			const vector<int>& coordinate =
				factor.GetCoordinateOfIndex(index);
			vector<int>::const_iterator coordinate_it;
			double value = *potential_it;
			for( msg_it = pvec->begin(), 
				coordinate_it = coordinate.begin(); 
				msg_it != pvec->end() ; msg_it++, coordinate_it++)
			{
				value *= 
					msg_it->first->GetIncomingMessage(*coordinate_it);
			}
			for( msg_it = pvec->begin(), coordinate_it = coordinate.begin(); 
				msg_it != pvec->end() ; msg_it++, coordinate_it++)
			{
				msg_it->first->
					AddValueIntoOutgoingMessage(*coordinate_it, value);
			}
		}
		for ( msg_it = pvec->begin() ; msg_it != pvec->end() ; msg_it++)
		{
			msg_it->first->DivideOutgoingMessageByIncomingMessage();
			msg_it->first->NormalizeOutgoingMessage();
		}
	}
}
void LoopyBP::UpdateMessageForMaxSum()
{
	//for nodes
	int nNodes = m_nodeMsgs.size();	
	for ( int i=0; i < nNodes; i++ )
	{
		msg_pair_vec* pvec = m_nodeMsgs[i];
		Node& node = m_graph->GetNode(i);
		vector<double> total_sum = node.GetLogEvidence();
		msg_pair_vec::const_iterator it;
		for ( it = pvec->begin(); it != pvec->end(); it++ ) 
		{
			transform( it->first->GetIncomingMessage().begin(),
				      it->first->GetIncomingMessage().end(),
					  total_sum.begin(),
					  total_sum.begin(),
					  plus<double>() );
		}
		vector<double>::iterator max_it = 
			max_element(total_sum.begin(), total_sum.end());
//		double value = accumulate(total_sum.begin(),
//			                      total_sum.end(), 0.0);
//		for_each(total_sum.begin(), total_sum.end(),
//			     DivideByValueInPlace<double>(value) );
		m_beliefDifferenceByIteration[i] = 
			fabs(*max_it - node.GetMAPProbability());
		node.SetMAPIndex( (int)(max_it - total_sum.begin()) );
		node.SetMAPProbability(*max_it);
//		m_mapProbability[i] = *max_it;
		for ( it = pvec->begin() ; it != pvec->end(); it++ )
		{
			it->first->SetOutgoingMessage(total_sum);
			it->first->SubtractIncomingMessageFromOutgoingMessage();
//			it->first->NormalizeOutgoingMessage();
		}
	}
	// for factors
	int nFactors = m_factorMsgs.size();
	for ( int i=0; i < nFactors; i++ )
	{
		msg_pair_vec* pvec = m_factorMsgs[i];
		msg_pair_vec::iterator msg_it;
		// intialize outgoing messages
		for ( msg_it = pvec->begin() ; msg_it != pvec->end() ; msg_it++) 
		{
			msg_it->first->SetOutgoingMessageIntoDBLMIN();
		}
		Factor& factor = m_graph->GetFactor(i);
		const vector<double>& potential = factor.GetLogPotential();
		int index(0);
		// compute outgoing messages
		for ( vector<double>::const_iterator potential_it = 
			potential.begin(); 
			potential_it != potential.end(); 
			potential_it++, index++) 
		{
			const vector<int>& coordinate =
				factor.GetCoordinateOfIndex(index);
			vector<int>::const_iterator coordinate_it;
			double value = *potential_it;
			for( msg_it = pvec->begin(), 
				coordinate_it = coordinate.begin(); 
				msg_it != pvec->end() ; msg_it++, coordinate_it++)
			{
				value +=
					msg_it->first->GetIncomingMessage(*coordinate_it);
			}
			for( msg_it = pvec->begin(), coordinate_it = coordinate.begin(); 
				msg_it != pvec->end() ; msg_it++, coordinate_it++)
			{
				double val1 = msg_it->first->GetOutgoingMessage(*coordinate_it);
				double val2 = 
					value - msg_it->first->GetIncomingMessage(*coordinate_it);
				if ( val1 < val2 ) 
					msg_it->first->SetOutgoingMessage(*coordinate_it, val2);
			}
		}
		// normalize outgoing message
		//for ( msg_it = pvec->begin() ; msg_it != pvec->end() ; msg_it++) 
		//{
		//	msg_it->first->NormalizeOutgoingMessage();
		//}
	}
}
void LoopyBP::CommunicateMessage()
{
	int nFactors = m_factorMsgs.size();
	for ( int i=0; i < nFactors; i++ ) 
	{
		msg_pair_vec* pvec = m_factorMsgs[i];
		msg_pair_vec::iterator msg_it;
		for ( msg_it = pvec->begin() ; msg_it != pvec->end() ; msg_it++ )
		{
			msg_it->first->
				SetIncomingMessage(msg_it->second->GetOutgoingMessage());
			msg_it->second->
				SetIncomingMessage(msg_it->first->GetOutgoingMessage());
		}
	}
}
void LoopyBP::ComputeJointMarginal(int factorIndex)
{
	msg_pair_vec* pvec = m_factorMsgs[factorIndex];
	msg_pair_vec::iterator msg_it;
	Factor& factor = m_graph->GetFactor(factorIndex);
	const vector<double>& potential = factor.GetPotential();
	int index(0);
	for ( vector<double>::const_iterator potential_it = potential.begin();
		potential_it != potential.end(); potential_it++, index++) 
	{
		const vector<int>& coordinate =
			factor.GetCoordinateOfIndex(index);
		vector<int>::const_iterator coordinate_it;
		double value = *potential_it;
		for( msg_it = pvec->begin(),coordinate_it = coordinate.begin(); 
			msg_it != pvec->end() ; msg_it++, coordinate_it++)
		{
			value *= 
				(msg_it->first->GetIncomingMessage())[*coordinate_it];
		}
		factor.AssignMarginalOfSinglePoint(index,value);
	}
	factor.NormalizeMarginal();
}

bool LoopyBP::ComputeSumProduct(int nIter, double eps)
{
	AllocateMessages(1.0);
	int iter(0);
	int nNodes = m_nodeMsgs.size();
	while ( iter < nIter ) 
	{
		UpdateMessageForSumProduct();
		vector<double>::iterator it =
			max_element(m_beliefDifferenceByIteration.begin(),
			            m_beliefDifferenceByIteration.end());
		if ( *it < eps ) 
		{
			//cout << "Number of iterations: " << iter << endl;
			ComputeMarginalOfAllNodes(); 
			return true;
		}
		CommunicateMessage();
		++iter;
	}
	ComputeMarginalOfAllNodes(); 
	return false;
}
double LoopyBP::GetMAPProbability() const
{
	int nFactors = m_graph->GetNumberOfFactors();
	int nNodes = m_graph->GetNumberOfNodes();
	double map_prob(0.0);
	for ( int i=0; i < nNodes ; i++) 
	{
		map_prob += 
			(m_graph->GetNode(i).GetLogEvidence())[GetMAPIndex(i)];
	}
	for ( int i=0; i < nFactors ; i++) 
	{
		const vector<int> neighbor = 
			m_graph->GetNeighborNodeIndices(i);
		vector<int> coordinate;
		for ( vector<int>::const_iterator it = neighbor.begin();
			  it != neighbor.end(); it++)
		{
			coordinate.push_back(GetMAPIndex(*it));
		}
		map_prob += 
			log(
			m_graph->GetFactor(i).GetPotentialOfSinglePoint(coordinate) );
	}
	return map_prob;
}
double LoopyBP::GetMAPProbability(int nodeIndex) const
{
	msg_pair_vec* pvec = m_nodeMsgs[nodeIndex];
	Node& node = m_graph->GetNode(nodeIndex);
	vector<double> total_sum = node.GetLogEvidence();
	msg_pair_vec::const_iterator it;
	for ( it = pvec->begin(); it != pvec->end(); it++ ) 
	{
		transform( it->first->GetIncomingMessage().begin(),
			      it->first->GetIncomingMessage().end(),
				  total_sum.begin(),
				  total_sum.begin(),
				  plus<double>() );
	}
	for_each(total_sum.begin(), total_sum.end(),
		     EXPInPlace<double>() );
	double value = 
		accumulate(total_sum.begin(), total_sum.end(), 0.0);
	for_each(total_sum.begin(), total_sum.end(),
			 DivideByValueInPlace<double>(value) );
	vector<double>::iterator max_it = 
		max_element(total_sum.begin(), total_sum.end());
	return *max_it;
}
int LoopyBP::GetMAPIndex(int nodeIndex) const
{
	return
		m_graph->GetNode(nodeIndex).GetMAPIndex();
}
//double LoopyBP::GetAvgMAPProbability() const
//{
//	double total = 
//		accumulate(m_mapProbability.begin(),
//				   m_mapProbability.end(),
//				   0.0 );
//	return total / m_mapProbability.size() ;
//}
void LoopyBP::ComputeMarginalOfAllNodes() 
{
	int nNodes = m_nodeMsgs.size();	
	for ( int i=0; i < nNodes; i++ )
	{
		msg_pair_vec* pvec = m_nodeMsgs[i];
		Node& node = m_graph->GetNode(i);
		vector<double> total_product = node.GetEvidence();
		msg_pair_vec::const_iterator it;
		for ( it = pvec->begin(); it != pvec->end(); it++ ) 
		{
			transform( it->first->GetIncomingMessage().begin(),
				      it->first->GetIncomingMessage().end(),
					  total_product.begin(),
					  total_product.begin(),
					  multiplies<double>() );
		}
		node.AssignMarginal(total_product);
		node.NormalizeMarginal();
	}
}
const vector<double>& LoopyBP::GetMarginal(int nodeIndex) const
{
	return m_graph->GetNode(nodeIndex).GetMarginal();
}
const vector<double>& LoopyBP::GetJointMarginal(int factorIndex) const
{
	return m_graph->GetFactor(factorIndex).GetMarginal();
}

