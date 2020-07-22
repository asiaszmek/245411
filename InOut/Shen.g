//genesis 
//Shen.g

//Pre-synaptic parameters
str prestim = 2
float pulseFreq =50//gugu

//Post-synaptic parameters
float inject=1e-9 //1e-9
float burstFreq = 5 
int numbursts = 5
float trainFreq=0.1
int numtrains=10

AP_durtime=0.005 
float APinterval={1.0/50.0}
int numAP=3

if ({Timing}=="Pre")
	float ISI = 0.005
	int pulses = 3 
elif ({Timing}=="Post")
	float ISI = -0.010
	int pulses = 1
end

