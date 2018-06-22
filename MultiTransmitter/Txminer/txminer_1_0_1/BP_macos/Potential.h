#pragma once

#include <vector>
using namespace std;

class Potential {
public:
	explicit Potential(const vector<int>& nStatesOfVariables);
	Potential(const Potential& that);
	Potential& operator = (const Potential& that);
private:
	vector<int> m_nStatesOfVariables;
	vector<double> m_data;
	vector<double> m_logData;
	vector<int> m_base;
	vector<vector<int> > m_table;
public:
	void AssignPotentialOfSinglePoint(const vector<int>& coordinate, 
		                              double value);
	void AssignPotentialOfSinglePoint(int index, double value);
	void AssignPotential(const vector<double>& potential);
	const vector<double>& GetPotential() const;
	const vector<double>& GetLogPotential() const;
	double GetPotentialOfSinglePoint(int index) const;
	double GetLogPotentialOfSinglePoint(int index) const;
	double GetPotentialOfSinglePoint(const vector<int>& coordinate) const;
	double GetLogPotentialOfSinglePoint(const vector<int>& coordinate) const;
	int GetDimension() const;
	const vector<int>& GetCoordinate(int index) const;
	int GetIndexFromCoordinate(const vector<int>& coordinate) const;
private:
	void Initialize();
	void CreateBase();
	void CreateData();
	void CreateTable();
};
