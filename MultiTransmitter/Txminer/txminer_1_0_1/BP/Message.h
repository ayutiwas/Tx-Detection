#pragma once
#include<vector> 
using namespace std;

class Message
{
private:
	vector<double> out;
	vector<double> in;
public:
	explicit Message(int size, double value);
	Message(const Message& that);
	Message& operator= (const Message &that);
public:
	void SetIncomingMessage(const vector<double>& newMsg);
	void SetIncomingMessage(int index, double value);
	const vector<double>& GetIncomingMessage() const;
	double GetIncomingMessage(int index) const;
	void SetOutgoingMessage(const vector<double>& newMsg);
	void SetOutgoingMessage(int index, double value);
	double GetOutgoingMessage(int index);
	const vector<double>& GetOutgoingMessage() const;
	void AddValueIntoOutgoingMessage(int index, double value);
	void DivideOutgoingMessageByIncomingMessage();	
	void SubtractIncomingMessageFromOutgoingMessage();
	void MultiplyOutgoingMessageByIncomingMessage();
	void SetOutgoingMessageIntoZero();
	void SetOutgoingMessageIntoDBLMIN();	
	void NormalizeOutgoingMessage();
};
