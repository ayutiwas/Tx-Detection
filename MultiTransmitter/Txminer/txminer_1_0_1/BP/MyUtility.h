#pragma once

template<typename T>
class SetZero
{
public:
	T operator() (T& elem) const
	{
		return 0;
	}
};
template<typename T>
class SetZeroInPlace
{
public:
	void operator() (T& elem) const
	{
		elem = 0;
	}
};
class SetDBLMIN
{
private:
	double minConst;
public:
	SetDBLMIN(double value) : minConst(value)
	{}
	double operator() (double& elem) const
	{
		return minConst;
	}
};
class SetDBLMINInPlace
{
private:
	double minConst;
public:
	SetDBLMINInPlace(double value) : minConst(value)
	{}
	void operator() (double& elem) const
	{
		elem = minConst;
	}
};
template<typename T>
class DivideByValueInPlace
{
private:
	T divider;
public:
	DivideByValueInPlace(const T& val) : divider(val) {}
	void operator() (T& elem) const 
	{
		elem /= divider;
	}
};
template<typename T>
class DivideByValue
{
private:
	T divider;
public:
	DivideByValue(const T& val) : divider(val) {}
	T operator() (T& elem) const 
	{
		return (elem / divider);
	}
};
template <class T>
class MultiplyByValue
{
private:
	T Factor;
public:
      MultiplyByValue ( const T& _Val ) : Factor ( _Val ) {
      }
	  T operator ( ) ( T& elem ) const 
      {
         return elem * Factor;
      }
};
template <class T>
class MultiplyByValueInPlace
{
private:
	T Factor;
public:
      MultiplyByValueInPlace ( const T& _Val ) : Factor ( _Val ) {
      }
	  void operator ( ) ( T& elem ) const 
      {
         elem *= Factor;
      }
};

template<typename T>
class AbsDifference
{
public:
	T operator()(const T& x, const T& y) 
	{
		T val = x-y < 0 ? y-x : x-y;
		return val;
	}
};
template<typename T>
class LOG
{
public:
	T operator()(const T& x)
	{
		return log(x);
	}
};
template<typename T>
class LOGInPlace
{
public:
	void operator()(T& x)
	{
		x = log(x);
	}
};
template<typename T>
class EXP
{
public:
	T operator()(const T& x)
	{
		return exp(x);
	}
};
template<typename T>
class EXPInPlace
{
public:
	void operator()(T& x)
	{
		x = exp(x);
	}
};
template<typename T>
class DivideWithZeroTest
{
public:
	T operator() (const T& left, const T& right) 
	{
		if ( right == 0 ) return 0;
		else return (left / right);
	}
};
template<typename T>
class DivideByValueWithZeroTestInPlace
{
private:
	T divider;
public:
	DivideByValueWithZeroTestInPlace(const T& val) : divider(val) {}
	void operator() (T& elem) const 
	{
		if ( divider == 0 ) elem = 0;
		else elem /= divider;
	}
};
