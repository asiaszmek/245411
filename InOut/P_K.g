//genesis 
//P_K.g

//Pre-synaptic parameters
str prestim = 2
float pulseFreq = 50
int pulses = 1

//Post-synaptic parameters
float inject=1e-9 //1e-9
float burstFreq = 1 
int numbursts = 1
float trainFreq= 0.1
int numtrains = 10

AP_durtime=0.005 
float APinterval={1.0/50.0}
int numAP=3
if ({Timing}=="Pre")
	float ISI = 0.010
elif ({Timing}=="Post")
	float ISI =-0.030
end

