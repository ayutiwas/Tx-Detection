#include "Factor.h"
#include "MyUtility.h"
#include <algorithm>
#include <numeric>

Factor::Factor(const vector<int>& nStatesOfVariables)
: m_nStatesOfVariables(nStatesOfVariables),
m_potential(nStatesOfVariables),
m_marginal(m_potential.GetPotential().size(),
		   1.0/m_potential.GetPotential().size()),
m_likelihood(0.0)
{}
Factor::Factor(const Factor& that)
: m_nStatesOfVariables(that.m_nStatesOfVariables),
m_potential(that.m_nStatesOfVariables),
m_marginal(that.m_marginal),
m_likelihood(that.m_likelihood)
{}

Factor& Factor::operator =(const Factor& that)
{
	if ( this == &that ) return *this;
	m_nStatesOfVariables = that.m_nStatesOfVariables;
	m_potential = that.m_potential;
	m_marginal = that.m_marginal;
	m_likelihood = that.m_likelihood;
	return *this;
}
int Factor::GetNumberOfVariables() const 
{
	return m_nStatesOfVariables.size();
}
const vector<int>& Factor::GetStatesOfVariables() const
{
	return m_nStatesOfVariables;
}

void Factor::AssignPotentialOfSinglePoint(const vector<int>& coordinate, 
										  double value)
{
	m_potential.AssignPotentialOfSinglePoint(coordinate, value);
}
void Factor::AssignMarginalOfSinglePoint(const vector<int>& coordinate, 
										  double value)
{
	int index = m_potential.GetIndexFromCoordinate(coordinate);
	m_marginal[index] = value;
}
void Factor::AssignPotentialOfSinglePoint(int index, double value)
{
	m_potential.AssignPotentialOfSinglePoint(index, value);
}
void Factor::AssignMarginalOfSinglePoint(int index, double value)
{
	m_marginal[index] = value;
}
void Factor::AssignPotential(const vector<double>& potential)
{
	m_potential.AssignPotential(potential);
}
void Factor::AssignMarginal(const vector<double>& marginal)
{
	copy(marginal.begin(), marginal.end(), m_marginal.begin() );
}
const vector<double>& Factor::GetPotential() const
{
	return m_potential.GetPotential();
}
const vector<double>& Factor::GetLogPotential() const
{
	return m_potential.GetLogPotential();
}
const vector<double>& Factor::GetMarginal() const
{
	return m_marginal;
}
const vector<int>& Factor::GetCoordinateOfIndex(int index) const
{
	return m_potential.GetCoordinate(index);
}
int Factor::GetDimension() const
{
	return m_potential.GetDimension();
}
double Factor::GetPotentialOfSinglePoint(int index) const
{
	return m_potential.GetPotentialOfSinglePoint(index);
}
double Factor::GetLogPotentialOfSinglePoint(int index) const
{
	return m_potential.GetLogPotentialOfSinglePoint(index);
}
double Factor::GetMarginalOfSinglePoint(int index) const
{
	return m_marginal[index];
}
double Factor::GetPotentialOfSinglePoint(const vector<int>& coordinate) const
{
	return m_potential.GetPotentialOfSinglePoint(coordinate);
}
double Factor::GetLogPotentialOfSinglePoint(const vector<int>& coordinate) const
{
	return m_potential.GetLogPotentialOfSinglePoint(coordinate);
}
double Factor::GetMarginalOfSinglePoint(const vector<int>& coordinate) const
{
	int index = m_potential.GetIndexFromCoordinate(coordinate);
	return m_marginal[index];
}
double Factor::NormalizeMarginal()
{
	double value = 
		accumulate(m_marginal.begin(), m_marginal.end(), 0.0);
	for_each( m_marginal.begin(), m_marginal.end(), 
		DivideByValueInPlace<double>(value) );
	m_likelihood = value;
	return value;
}
double Factor::GetLikelihood() const
{
	return m_likelihood;
}
