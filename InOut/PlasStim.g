//genesis 
//PlasStim.g
//PlasStim can do hfs or theta (train of pre-syn stim), no current injection

function PlasStim (PreStim, StimComp, file, pulseFreq, pulses, trainFreq, numtrains )
    str PreStim
    str StimComp, file
    float pulseFreq, trainFreq
    int pulses, numtrains

    float initSim=0.1
    float interpulse, intertrain,PreStimPct
    int pulse, train, anystim

    //**********set the filenames, and 
    //set up presynaptic element for stimulating
    str filenam={file}@"Stim"@{pulseFreq}@"Hz_"@{trainFreq}@"Hz"
    if ({PreStim}==2)
        filenam={filenam}@"_Stim"@{StimComp}
        PreSynStim {precell} 
        if ({spinesYesNo})
            str stimname={StimComp}@"/spine_1/"@{spcomp1}
	    echo {StimComp}@"/spine_1/"@{spcomp1}	
        else
            str stimname={StimComp}
        end
        addmsg {precell}/spikegen  {neuronname}/{stimname}/{NMDAname} SPIKE 
        addmsg {precell}/spikegen  {neuronname}/{stimname}/{AMPAname} SPIKE 
    else
        PreStimPct= {PreStim}
        if ({PreStimPct}>0 && {PreStimPct}<=1)
            filenam={filenam}@"_Pct"@{PreStimPct}
            PreSynStim {precell} 
            anystim={PreSynSyncRandom {precell} {neuronname} {PreStimPct} {StimComp}}
            if ({anystim}==0)
                echo "ERROR in PlasStim/PreSynSync: no successful connections"
            end
        elif ({PreStimPct}<=0)
            filenam={filenam}@"NoStim"
        else
            echo "ERROR in PlasStim: PreStim," {PreStim} ", must be string between 0 and 1"
        end
    end

    echo "################ simulating Synchronous Stim, Freqs:" {pulseFreq} {trainFreq} 
  
    //setfilename {Vmfile} {filenam} 1 {Vmhead}
    //setfilename {Cafile} {filenam} 1 {Cahead}
    //setfilename {Gkfile} {filenam} 1 {Gkhead}
    //setfilename {spinefile} {filenam} 1 {spinehead}

// Determine the interpulse and intertrain intervals
    if ({pulses}>1)
        interpulse=1/{pulseFreq}
    end
    if ({numtrains}>1)
        intertrain = (1/{trainFreq})-(pulses)*{interpulse}
    end

/*
    create asc_file /output/Tertweight
    setfield /output/Tertweight   flush 1  leave_open 1 append 1 float_format %0.6g
    useclock /output/Tertweight 5e-4
    addmsg /cell/tertdend1_3/spine_1/head/AMPA /output/Tertweight  SAVE synapse[0].weight	
    setfield /output/Tertweight filename /output/"weight_tert.txt"
*/

//step through the simulation
    step {initSim} -time
    if ({pulseYN})
        setfield {precell} Vm 10
        step 1 
        setfield {precell} Vm 0
        step {initSim} -time
    end
    for (train=0; train<numtrains; train=train+1)
        for (pulse=0; pulse<pulses; pulse=pulse+1)
            setfield {precell} Vm 10
            step 1 
            setfield {precell} Vm 0
            step {interpulse} -time
        end
        step {intertrain} -time

    end
    if ({pulseYN})
        step {initSim} -time
        setfield {precell} Vm 10
        step 1 
        setfield {precell} Vm 0
    end
    step {initSim} -time

    fileFLUSH {Vmfile} {Cafile} {Gkfile} {spinefile}
		int nummsg={getmsg {precell}/spikegen -out -count}
		int i
		for (i=0; i<nummsg; i=i+1)
			deletemsg {precell}/spikegen 0 -outgoing 
		end
end

