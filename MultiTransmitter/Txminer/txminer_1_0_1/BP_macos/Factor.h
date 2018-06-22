#pragma once 
#include <vector>

using namespace std;
#include "Potential.h"

class Factor {
public:
	explicit Factor(const vector<int>& nStatesOfVariables);
	Factor(const Factor& that);
	Factor& operator = (const Factor& that);
private:
	vector<int> m_nStatesOfVariables;
	Potential m_potential;
	vector<double> m_marginal;
	double m_likelihood;
public:
	int GetNumberOfVariables() const;
	const vector<int>& GetStatesOfVariables() const;
	void AssignPotentialOfSinglePoint(const vector<int>& coordinate, double value);
	void AssignPotentialOfSinglePoint(int index, double value);
	void AssignPotential(const vector<double>& potential);
	void AssignMarginalOfSinglePoint(const vector<int>& coordinate, double value);
	void AssignMarginalOfSinglePoint(int index, double value);
	void AssignMarginal(const vector<double>& marginal);
	const vector<double>& GetPotential() const;
	const vector<double>& GetLogPotential() const;
	const vector<double>& GetMarginal() const;
	const vector<int>& GetCoordinateOfIndex(int index) const;
	double GetPotentialOfSinglePoint(int index) const;
	double GetLogPotentialOfSinglePoint(int index) const;
	double GetPotentialOfSinglePoint(const vector<int>& coordinate) const;
	double GetLogPotentialOfSinglePoint(const vector<int>& coordinate) const;
	double GetMarginalOfSinglePoint(int index) const;
	double GetMarginalOfSinglePoint(const vector<int>& coordinate) const;
	int GetDimension() const;
	double NormalizeMarginal();
	double GetLikelihood() const;
};
