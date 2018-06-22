#include "Message.h"
#include "MyUtility.h"
#include <algorithm>
#include <numeric>
#include <functional>
#include <float.h>

Message::Message(int size, double value)
: out(size,value), in(size,value)
{}
Message::Message(const Message& that)
: out(that.out), in(that.in)
{}
Message& Message::operator= (const Message& that)
{
	if ( this == &that) return *this;
	out = that.out;
	in = that.in;
	return *this;
}
void Message::SetIncomingMessage(const vector<double>& newMsg)
{
	copy(newMsg.begin(), newMsg.begin() + in.size(), in.begin() );
}
void Message::SetIncomingMessage(int index, double value)
{
	in[index] = value;
}
const vector<double>& Message::GetIncomingMessage() const
{
	return in;
}
double Message::GetIncomingMessage(int index) const
{
	return in[index];
}
void Message::SetOutgoingMessage(const vector<double>& newMsg)
{
	copy(newMsg.begin(), newMsg.begin() + out.size(), out.begin() );
}
void Message::SetOutgoingMessage(int index, double value)
{
	out[index] = value;
}
double Message::GetOutgoingMessage(int index)
{
	return out[index];
}
const vector<double>& Message::GetOutgoingMessage() const
{
	return out;
}
void Message::AddValueIntoOutgoingMessage(int index, double value)
{
	out[index] += value;
}
void Message::SetOutgoingMessageIntoZero()
{
	for_each(out.begin(), out.end(), SetZeroInPlace<double>() );
}
void Message::SetOutgoingMessageIntoDBLMIN()
{
	for_each(out.begin(), out.end(), SetDBLMINInPlace(-1e10) );
}
void Message::DivideOutgoingMessageByIncomingMessage()
{
	//transform(out.begin(),out.end(),
	//	      in.begin(), 
	//		  out.begin(),
	//	      divides<double>() );
	transform(out.begin(),out.end(),
		      in.begin(), 
			  out.begin(),
			  DivideWithZeroTest<double>() );
}
void Message::SubtractIncomingMessageFromOutgoingMessage()
{
	transform(out.begin(),out.end(),
		      in.begin(), 
			  out.begin(),
		      minus<double>() );
}

void Message::MultiplyOutgoingMessageByIncomingMessage()
{
	transform(in.begin(),in.end(),
		      out.begin(),
			  out.begin(),
			  multiplies<double>() );
}
void Message::NormalizeOutgoingMessage()
{
	double value = 
		accumulate(out.begin(), out.end(), 0.0);
	for_each( out.begin(), out.end(), DivideByValueInPlace<double>(value) );
}
