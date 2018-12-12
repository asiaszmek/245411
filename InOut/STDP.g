//genesis 
//STDP.g
//Can give pattern of current injection and/or pattern of pre-syn stim, allowing STDP, HFS, Theta, etc
//pulse>=1 and numtrains>=1 else there will be NO pre-syn stim (good for evaluating AP alone)
//AND preStimPct>0, else there will be NO pre-syn stim
//inject=0 will give pre-syn stim alone, without triggered AP (e.g. hfs or theta)
//set TooFast = 100 will revert to stimulating just one spine, even for 50 Hz stimulation
//If no synaptic stimulation StimComp is where one specifies which spine output to save
/*Commented out lines allow giving a pulse before and after, to test the plasticity
and also repeating the pairings.  BUT, these will mess up the alignment of the 
pre-synaptic stim and the post-synaptic depol.  So, fix the pulse generators when you uncomment them */
function connect_synapse_with_delay(precell,name,stimname,StimDelay)
    str precell, name, stimname ,neuronname
    float StimDelay
    int msgnum
    if ({exists {stimname}/{name}})
        addmsg {precell}/spikegen  {stimname}/{name} SPIKE 
        msgnum = {getfield {stimname}/{name} nsynapses} - 1
        echo {msgnum}
        setfield {stimname}/{name} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay StimDelay
    else
        echo  could not connect to {stimname}/{name}
    end
end
function connect_synapse(precell,name,neuronname,stimname)
    str neuronname, stimname, name, precell
    if ({exists {neuronname}/{stimname}/{name}})
        addmsg {precell}/spikegen  {neuronname}/{stimname}/{name} SPIKE 
    else
        echo could not connect to {neuronname}/{stimname}/{name}
    end
end

function STDP(PreStim, StimComp, file,numAP,inj,dur,interval, isi, pulseFreq, pulses, burstFreq, numbursts, trainFreq, numtrains, jitter,ChanString)
    int PreStim
    str StimComp,file, compt,ChanString
//These are parameters related to both pre-and post-synaptic AP (EPSP) pattern
    int numbursts, numtrains
    float trainFreq, burstFreq
    float isi //interval between onset of EPSP and onset of AP
//These are parameters related to pre-synaptic stimulation - pulses in a burst
    int pulses
	float pulseFreq
//These parameters describe post-synaptic stimulation - AP in a burst
	int numAP 
    float inj, dur, interval, interpulse=0

// Determine the interpulse intervals for pre-synaptic stimulation
    if ({pulses}>1)
        interpulse=1/{pulseFreq}
    end
// Determine the interburst and intertrain intervals for pre- and post- stimulation
    float intertrain=0, interburst=0
    interburst = 1.0/{burstFreq}
    intertrain = 1.0/{trainFreq}
    int pulse, train, burst

    float initSim=0.1      //delay refers to onset of current injection relative to first pulse, which occurs at initSim
    float TooFast = 30     //if pre-syn pulses in burst are too fast, distribute them among multiple spines
    if ({pulseYN})
    	float AP_delay= {2*initSim + isi}//+ (pulses-1)*interpulse}
    else
        float AP_delay = {initSim + isi}// + (pulses-1)*interpulse}
    end
    if ({isi} > 0) 
        AP_delay = {AP_delay} + ({pulses}-1)*{interpulse}
    else
        AP_delay = {AP_delay} - ({numAP}-1)*{interval}
    end
    echo {AP_delay}
		//parameters for post-synaptic spike generators

    if ({interval} == 0 )
        echo "Wrong paradigm chosen. You can choose: P_and_K (Pawlak and Kerr), K_and_P (Kerr and Plenz), Shindou, Shen and IF (IF curves)"
        return
    end
    if ({interval}<{dur})
        echo "please define lower AP frequency"
    end
    int anystim
    float PreStimPct
    //**********set the filenames, and 
    //set up presynaptic element for stimulating

    str filenam={file}@"_STDP_"
    if ({jitter} == 1)
        filenam = {filenam}@"jitter_"
    end
    if ({abs {isi}}<{SMALLNUMBER})
        isi=0
    end
    if ({PreStim}==2)
        PreStimPct=2          //Used for stimulation during simulation
        filenam={filenam}@"Stim_"@{StimComp}@"_AP_"@{numAP}@"_ISI_"@{isi}
        PreSynStim {precell}
        if ({spinesYesNo})
            str stimname        
            echo "before pulseFreq entry pulseFreq" {pulseFreq} {TooFast} {pulses}
            if ({pulseFreq}>{TooFast} && {pulses}>1)
                int stim=0, msgnum
                      
                float StimDelay
                echo "in pulseFreq"
                //Connect up to the number of pulses in the burst
                echo "Stim Comp" {StimComp}
                foreach compt ({el {neuronname}/{StimComp}/##[TYPE=compartment]})
                    echo "compt" {compt}
                    if ({strcmp {getpath {compt} -tail} "head"} == 0)
                        echo "this should be a head compartment in our StimComp:" {compt}
                        //Double check whether compt includes StimComp as part of name
                        if ({stim} < {pulses})
                            //This won't work if number of spines is fewer than number of pulses in burst
                            StimDelay = {stim}*{interpulse}		

                            str stimname={compt}
                            
                            if ({exists {stimname}/{NMDAname}})
                                addmsg {precell}/spikegen  {stimname}/{NMDAname} SPIKE 

                                msgnum = {getfield {stimname}/{NMDAname} nsynapses} - 1
                                setfield {stimname}/{NMDAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay StimDelay
                            end
                            if ({exists {stimname}/{AMPAname}})
                                addmsg {precell}/spikegen  {stimname}/{AMPAname} SPIKE
                                msgnum = {getfield {stimname}/{AMPAname} nsynapses} - 1
                                setfield {stimname}/{AMPAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay StimDelay
                            end

                            stim = {stim+1}
                        end
                    end
                end
                /*Above results in stimulating all pulses in burst with single stim,
                  so need to NOT loop over pulses below during simulation, e.g. set pulses = 1  */
                pulses=1
            else
                str stimname={StimComp}@"/spine_1/"@{spcomp1}
                echo "1 pulse" {stimname}
                echo {StimComp}"/spine_1/"{spcomp1}
                connect_synapse {precell} {NMDAname} {neuronname} {stimname}
                connect_synapse {precell} {AMPAname} {neuronname} {stimname}
            end 
        else
            str stimname={StimComp}
            connect_synapse {precell} {NMDAname} {neuronname} {stimname}
            connect_synapse {precell} {AMPAname} {neuronname} {stimname}

        end
        showmsg {precell}/spikegen
            
        //add_outputSpikeHistory {precell} {presynfile} {filenam}
    else
        PreStimPct= {PreStim}
        if ({PreStimPct}>0 && {PreStimPct}<=1)
            filenam={filenam}@"Pct_"@{StimComp}@"_AP_"@{numAP}@"_ISI_"@{isi}
            PreSynStim {precell} 
            anystim={PreSynSyncRandom {precell} {neuronname} {PreStimPct} {StimComp}}
            if ({anystim}==0)
                echo "ERROR in STDP/PreSynSync: no successful connections"
            else
               // add_outputSpikeHistory {precell} {presynfile} {filenam}
            end
        elif ({PreStimPct}<=0)
            filenam={filenam}@"NoStim"
        else
            echo "ERROR in STDP: PreStim," {PreStim} ", must be string <=1"
        end
    end

    echo "################ simulating STDP, " {numAP} "AP, ISI: " {isi} 

    
   
  

    int go = 1

    float width_burst = {numAP}*{interval}
    float width_train = {numbursts}/{burstFreq}

    float very_big_number = {1e9}
    float exp_duration = {numtrains}/{trainFreq}
    if ({dur} > {interval})
        go = 0
        echo "The AP is wider than the inter AP interval"
    else
        if ({width_burst} > {interburst})
            if (({numbursts} == 1) && ({numtrains} == 1))
                interburst = 2*{width_burst}
                width_train = {interburst}
                if ({width_train} > {intertrain})
                    echo "Train frequency smaller than duration of all bursts"
                    intertrain = 2*{width_train}
                    exp_duration = 2*{width_train}
                end
            else
                go = 0
            end
        else
            if ({width_train} > {intertrain})
                if ({numtrains} == 1)
                    intertrain = 2*{width_train}
                    exp_duration = 1.2*{width_train}
                    echo "Train frequency smaller than duration of all bursts"
                else
                    go = 0
                    echo "The train is wider than the intertrain interval"
                end
            end
        end
    end
    if ({go} == 1)
        //onset of the injections jitter (shift lower than 1 ms):
        if ({jitter} == 1)
            AP_delay = {AP_delay} + {rand 0 0.0005}
            //amplitude jitter
            inj = {inj} + {rand 0 {inj}/20.}
            //width jitter
            dur = {dur} + {rand 0 0.0005}
        end

        echo AP_delay {AP_delay} inj {inj} AP_duration {dur}
        createPulseGen {inj} {basal_current_inj} 0 {interval} {dur} {neuronname}/soma {injectName} 2 "INJECT"
        createPulseGen {inj} {basal_current} 0 {interburst} {width_burst} {injectName}  {injectName}/burst_gate 2 "INPUT"
        createPulseGen {inj} {basal_current} 0 {intertrain} {width_train}  {injectName}/burst_gate  {injectName}/train_gate 2 "INPUT"
        createPulseGen {inj} {basal_current} {AP_delay} {very_big_number} {exp_duration}  {injectName}/train_gate  {injectName}/experiment_gate 0 "INPUT"
        str inj_header
       // inj_header = {add_outputPulseGen {somainjfile} {injectName}}
     end

    //if ({getmsg /output/Vm -in -find /injectCurr SAVE}<0)
    //    addmsg /injectCurr /output/Vm SAVE output
    //end

    reset

    // H-Solve Here
    if (hsolveYesNo==1)
        call {neuronname}/solve SETUP
    end
    reset
    //setfilename {Vmfile} {Cafile} {Gkfile} {spinefile} {filenam} 1 {Vmhead} {Cahead} {Gkhead} {spinehead}    
 //set-up file names, post-synaptic spike generators
    if ({spinesYesNo}) 
       // if ({PreStim}>0)
    	 //   spinehead={add_outputMultiSpines {spinefile} {PreStim} {ChanString}}
       // else
            spinehead={add_outputMultiSpines {spinefile} {0.1}}
            spinehead={add_outputMultiSpines {spinefile} {2} {chans}}
            str saveComps= "secdend11,tertdend1_1,tertdend1_2,tertdend1_3,tertdend1_4,tertdend1_5,tertdend1_6,tertdend1_7,tertdend1_8,tertdend1_9,tertdend1_10,tertdend1_11,tertdend2_1,tertdend2_2,tertdend2_3,tertdend2_4,tertdend2_5,tertdend2_6,tertdend2_7,tertdend2_8,tertdend3_1,tertdend3_2,tertdend3_3,tertdend3_4,tertdend3_5,tertdend3_6,tertdend3_7,tertdend3_8,tertdend3_9,tertdend3_10,tertdend3_11" 

            multispinehead={add_outputOneSpinePerComp {multispinefile} {neuronname} {saveComps} {chans}} // to look at spines in non stim compartments

       // end
    end
   
 setfilename {somainjfile} {filenam} 1 {inj_header}
    setfilename {Vmfile} {filenam} 1 {Vmhead}
    setfilename {Cafile} {filenam} 1 {Cahead}
    setfilename {Gkfile} {filenam} 1 {Gkhead}
    setfilename {spinefile} {filenam} 1 {spinehead}
    setfilename {multispinefile} {filenam} 1 {multispinehead}
    setfilename {Ikfile} {filenam} 1 {Ikhead}
    reset
//step through the simulation
    step {initSim} -time

    if ({pulseYN})
        setfield {precell} Vm 10
        step 1 
        setfield {precell} Vm 0
        step {initSim} -time
    end

    for (train=0; train<{numtrains}; train={train+1})
    	for (burst=0;burst<{numbursts}; burst=burst+1)
            if ({PreStim}!="0")
                for (pulse=0; pulse<{pulses}; pulse={pulse+1})
                    setfield {precell} Vm 10
                    step 1 
                    setfield {precell} Vm 0
                    step {interpulse} -time
       			end
            end
            step {interburst-(pulses*interpulse)} -time
        end
        if ({train<numtrains-1})
         	step {intertrain -(numbursts*interburst)} -time
        end	
    end
    step {initSim} -time 
    if({pulseYN})
        setfield {precell} Vm 10
        step 1 
        setfield {precell} Vm 0
        step {initSim} -time
    end

    fileFLUSH {Vmfile} 
    fileFLUSH {Cafile} 
    fileFLUSH {Gkfile} 
    fileFLUSH {spinefile}
    fileFLUSH {somainjfile}
    //eliminate both current injection input and spikegenerator input in preparation for another stimulation paradigm
    //setfield {injectName} level1 0
    
    if ({PreStim}>0)   
    	int nummsg={getmsg {precell}/spikegen -out -count}
    	int i
    	for (i=0; i<nummsg; i=i+1)
            deletemsg {precell}/spikegen 0 -outgoing 
    	end
    end
end
