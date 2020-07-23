//SimParams.g

//*************** Parameters to control model (p file, spinesYesNo) and simulations
str 	neuronname = "/cell"
str     pfile="MScell/MScelltaperspines.p"     //"MScell/MScellTest.p"       //
float   outputclock=1e-4  //output time step (Sec)
float   simdt=5e-6        // Simulation time step (Second) 
int     spinesYesNo=1
int     synYesNo=1
str 	DA="UI"
str     whichSpines = "1,2,3"
float   initSim = 0.9
int TooFast = 30 //what is the frequency that results in depletion of synaptic vesicles

//Parameters for learning rule

int     plastYesNo = 1
float   post_thresh_hi = .46e-3 //0.5 
float   post_thresh_lo = 0.2e-3  //0.2
float   dur_hi = 2.e-3 //
float   dur_lo = .032  //0.2

//whether to elicit and single pulses before and after plasticity protocol
int pulseYN=0
int desensYesNo=0
str facchan="/cell/desens"

int GABAYesNo = 0
// phasic GABA switch
int GABAtonic =  0//tonic GABA switch
str GABAstim = "tertdend1_1"

//Parameters for current injection for IV/IF curves
str input_name = "spine_stim"
str GABA_input = "GABA_stim"
float SMALLNUMBER=1e-15
str precell="/othercell"

//Parameters for current injection for IV/IF curves
str injectName="/injectCurr"
float injectstart=-300e-12 //1e-9
float inc=100e-12          //20e-12
float delay=0.1
float duration=0.25       //0.005
int numcurr=7
float basal_current=0
float basal_current_inj = 0
//parameters for current injection to produce AP during upstate or STDP
float upstate_time = 0.3
float AP_durtime = 0.005 //duration of AP depolarization at soma, 5 ms

//parameters for synaptic stimulation
int tertdendstart=1
int tertdendsegstart=1
str stimcomp
str multispinefile
str multispinehead

//output files.  Xfile is name of ascii object and suffix for filename
//Xhead is the header written to the file
//Vm output is required, Gk and Ca are optional
str Vmfile="Vm"
str Vmhead
int CaOut=1
str Cafile
str Cahead
int GkOut=1
str Gkfile
str Gkhead
str Ikfile
str Ikhead
str multispinefile
str multispinehead
str spinefile
str spinehead
str presynfile
int somainjout = 0
str somainjfile = "somaInj"

//list of compartments, channels and calcium objects for output, comma separated
str comps="soma,primdend1,secdend11,tertdend1_1,tertdend1_2,tertdend1_3,tertdend1_4,tertdend1_5,tertdend1_6,tertdend1_7" //These should include comps of stim spines to see NMDA
str chans="CaL13_channel,CaL12_channel,CaR_channel,CaT32_channel,CaT33_channel" //"X" if no channels.  
//these must match the calcium type, i.e. pools for type 1 and CaMN, etc for type 0

str CaBufs="CaMN,CaMC,calbindin,FixedBuffer"//"Ca_pool_LT,Ca_pool_NR,Ca_pool_all,Ca_pool_nmda" // X = just calcium, no buffers


    //***********input rates for Glutamate, and durations when doing a gradient.
    //most of these values should be passed in as parameters or declared in SimParams
    //make the secondRate and thirdRate = first rate when second_time and third_time = 0
//*rates used for gradient and flat inputs, multiply by 10
//18: high=*50, med=*3, low=*1, gaba=*7
//19: high=*40, med=*5, low=*2, gaba=*7
//flat: rate=*4 gaba=*7
float first_time = 0.01
float second_time  = 0.2

int Rate1
int Rate2
int Rate3
int GabaRate=70

create table APtime
int  xmax=7
call  APtime  TABCREATE 7 0 7
setfield APtime table->table[0] 0.005 \
                table->table[1] 0.010 \
                table->table[2] 0.020 \
                table->table[3] 0.030 \
                table->table[4] 0.050 \
                table->table[5] 0.100 \
                table->table[6] 0.175 \
                table->table[7] 0.290 

//From STDP files:
//1: high=*50, med =*1, low =/1.5, gaba = *2
//2: high=*40, med =*1, low =/1.5, gaba = *2
//3: high=*40, med =*1, low =/1.5, gaba = *3
//*****4: high=*40, med =*1, low =/1.5, gaba = *4
//5: high=*60, med =/2, low =/5, gaba = *4
//6: high=*30, med =*1, low =/1.5, gaba = *4

/* Three variations for stimulation in PlasStim
a. PreStim=0 indicates stimulate a single compartment,
    second parameter must be name of compartment
b. PreStim between 0 and 1.0 indicates stimulate a percentage
    of glutamate synapses.  The PreStim value is treated as percent.
    in this case, StimComp should be either
    b1. "any", meaning stimulate a percentage of _any_ compartments, or
    b2. a value indicating minimum distance from soma for stimulation.
        of course, setting a value = 0 is the same as "any"
Same variations plus one more for stimulation in STDP
If PreStim <= 0, no stim, only AP*/

