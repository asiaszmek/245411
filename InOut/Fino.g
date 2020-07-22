//genesis 
//Fino.g 

//Pre-synaptic parameters
str prestim = 2
float pulseFreq = 50
int pulses = 1

//Post-synaptic parameters
float inject=0.47e-9 //1e-9
float burstFreq = 1 
int numbursts = 1
float trainFreq=1
int numtrains=100
AP_durtime=0.030 
float APinterval={1.0/10.0}
int numAP=1
if ({GABAtonic})
    inject=1.e-9//1.3675e-9
    echo {inject}
end

if ({Timing}=="Pre")
    float ISI = -0.010
    if ({GABAYesNo})
        float ISI = 0.04
    end
    if ({GABAtonic})
        float ISI = 0.04
    end
elif ({Timing}=="Post")
    float ISI = -0.040
end
