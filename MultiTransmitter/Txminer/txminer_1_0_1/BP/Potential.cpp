#include "Potential.h"
#include "MyUtility.h"
#include <algorithm>
#include <math.h>

Potential::Potential(const vector<int>& nStatesOfVariables)
: m_nStatesOfVariables(nStatesOfVariables)
{
	Initialize();
}
Potential::Potential(const Potential& that)
: m_nStatesOfVariables(that.m_nStatesOfVariables),
  m_data(that.m_data), m_logData(that.m_logData),
  m_base(that.m_base), m_table(that.m_table)
{}
Potential& Potential::operator = (const Potential& that)
{
	if ( this == &that ) return *this;
	m_nStatesOfVariables = that.m_nStatesOfVariables;
	m_data = that.m_data;
	m_logData = that.m_logData;
	m_base = that.m_base;
	m_table = that.m_table;
	return *this;
}
const vector<double>& Potential::GetPotential() const
{
	return m_data;
}
const vector<double>& Potential::GetLogPotential() const
{
	return m_logData;
}
double Potential::GetPotentialOfSinglePoint(int index) const
{
	return m_data[index];

}
double Potential::GetLogPotentialOfSinglePoint(int index) const
{
	return m_logData[index];

}
double Potential::GetPotentialOfSinglePoint(const vector<int>& coordinate) const
{
	int index(0);
	vector<int>::const_iterator it1, it2;
	for ( it1 = coordinate.begin(), it2 = m_base.begin();
		it1 != coordinate.end();
		++it1, ++it2)
	{
		index += (*it1)*(*it2);
	}
	return m_data[index];
}
double Potential::GetLogPotentialOfSinglePoint(const vector<int>& coordinate) const
{
	int index(0);
	vector<int>::const_iterator it1, it2;
	for ( it1 = coordinate.begin(), it2 = m_base.begin();
		it1 != coordinate.end();
		++it1, ++it2)
	{
		index += (*it1)*(*it2);
	}
	return m_logData[index];
}
int Potential::GetDimension() const
{
	return m_nStatesOfVariables.size();
}
void Potential::AssignPotentialOfSinglePoint(const vector<int>& coordinate, 
											 double value)
{
	int index(0);
	vector<int>::const_iterator it1, it2;
	for ( it1 = coordinate.begin(), it2 = m_base.begin();
		it1 != coordinate.end();
		++it1, ++it2)
	{
		index += (*it1)*(*it2);
	}
	m_data[index] = value;
	m_logData[index] = log(value);
}
int Potential::GetIndexFromCoordinate(const vector<int>& coordinate) const
{
	int index(0);
	vector<int>::const_iterator it1, it2;
	for ( it1 = coordinate.begin(), it2 = m_base.begin();
		it1 != coordinate.end();
		++it1, ++it2)
	{
		index += (*it1)*(*it2);
	}
	return index;
}
void Potential::AssignPotentialOfSinglePoint(int index, double value)
{
	m_data[index] = value;
	m_logData[index] = log(value);
}
void Potential::AssignPotential(const vector<double>& potential)
{
	copy(potential.begin(), potential.end(), m_data.begin() );
	transform(potential.begin(), potential.end(), 
		      m_logData.begin(),
			  LOG<double>() );		    
}
	
void Potential::Initialize()
{
	CreateBase();
	CreateData();
	CreateTable();
}
void Potential::CreateBase()
{
	int multiplier(1);
	vector<int>::iterator it;
	for ( it = m_nStatesOfVariables.begin();
		it != m_nStatesOfVariables.end(); it++ )
	{
		m_base.push_back(multiplier);
		multiplier *= (*it);
	}
}
void Potential::CreateData()
{
	int dataSize = m_nStatesOfVariables.empty() ? 0 : 1;
	vector<int>::iterator it;
	for ( it = m_nStatesOfVariables.begin();
		  it != m_nStatesOfVariables.end();
		  ++it )
	{
		dataSize *= (*it);
	}
	m_data.reserve(dataSize);
	m_logData.reserve(dataSize);
	for ( int i =0 ; i < dataSize ; i++) {
		m_data.push_back(0);
		m_logData.push_back(0);
	}
}

//////////////////////////////////
// example of index of potential
// state    0 1 2
// nStates  2 2 2
//////////////////////////////////
// table index   |    coordinate
//     0                0 0 0
//     1                1 0 0
//     2                0 1 0
//     3                1 1 0
//     4                0 0 1
//     5                1 0 1
//     6                0 1 1
//     7                1 1 1   
/////////////////////////////////
void Potential::CreateTable()
{
	int tableSize = m_data.size();
	m_table.reserve(tableSize);
	int nStates = m_nStatesOfVariables.size();
	vector<int> coordinate(nStates);
	for ( int i=0 ; i < tableSize ; i++) {
		int remainder(i);
		for ( int j=nStates-1; j >= 0 ; j--) {
			coordinate[j] = remainder / m_base[j];
			remainder %= m_base[j];
		}
		m_table.push_back(coordinate);
	}
}
const vector<int>& Potential::GetCoordinate(int index) const
{
	return m_table[index];
}

		


