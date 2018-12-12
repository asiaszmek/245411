//genesis
//UpStateSTDP.g

function UpStateSTDP(AP_time,isi,AP_durtime,inj,upstate_time, seedval, file,TDstart,TDsegstart)
    float AP_time,AP_durtime,inj,upstate_time
    int seedval
    str file
    int TDstart,TDsegstart

    randseed {seedval}

    int maxRanSpikes, i
    float initSim=0.05

    float APpre=AP_time-isi
    float third_time = {upstate_time}-{first_time}-{second_time}

    //**********set the filenames
    str filenam={file}@"UpSTDP_"@{Rate1}@"_"@{Rate2}@"_"@{Rate3}@"_AP"@{AP_time}
    echo "################ simulating STDP during Upstate, Rates" {Rate1} {Rate2} {Rate3} "AP: " {AP_time}

    setfilename {Vmfile} {filenam} 1 {Vmhead}
    setfilename {Cafile} {filenam} 1 {Cahead}
    setfilename {Gkfile} {filenam} 1 {Gkhead}
    setfilename {spinefile} {filenam} 1 {spinehead}

    //**********create pulse generator for current injection
    float basal_current = 0
    str injectName="/injectCurr"
    createPulseGen {inj} {basal_current} {AP_time+initSim} {AP_durtime} {neuronname}/soma {injectName} 0 "no message"

    if ({getmsg /output/Vm -in -find /injectCurr SAVE}<0)
        addmsg /injectCurr /output/Vm SAVE output
    end
    reset

    PreSynSync {precell} {neuronname}

    //*********create randomspikes for synaptic input
    //0 goes to GABA, should be higher than GLU basal rate
    //1, and optionally 2 & 3 go to GLU.  2&3 are the higher initial rates for gradient
    makeALLspikes {GabaRate} 0 {neuronname} 1 1
    makeALLspikes {Rate1} 1 {neuronname} {TDstart} {TDsegstart}

    if ({first_time} < {upstate_time})
        makeALLspikes {Rate2} 2 {neuronname} {TDstart} {TDsegstart}
        makeALLspikes {Rate3} 3 {neuronname} {TDstart} {TDsegstart}
        maxRanSpikes=4
    else
        maxRanSpikes=2
    end

    //Now run the simulations
    step {initSim} -time

    ConnectALLInput 0 {neuronname} 1 1
    ConnectALLInput 1 {neuronname}  {TDstart} {TDsegstart}

    if ({APpre}<{first_time})
        echo "*********stimulation at " {APpre} "before first_time"
        step {APpre} -time
		setfield {precell} Vm 10
        step 1 
		setfield {precell} Vm 0
        step {first_time-APpre}
    else
        step {first_time} -time
    end
    DisconnectALLinput 1 {neuronname} {TDstart} {TDsegstart}

    if ({first_time} < {upstate_time})
        ConnectALLInput 2 {neuronname} {TDstart} {TDsegstart}
        if ({APpre}>{first_time})
            echo "*********stimulation at " {APpre} "after first_time"
            step {APpre-first_time} -time
            setfield {precell} Vm 10
            step 1 
            setfield {precell} Vm 0
            step {second_time-(APpre-first_time)} -time
        else
            step {second_time} -time
        end
        DisconnectALLinput 2 {neuronname} {TDstart} {TDsegstart}

        ConnectALLInput 3 {neuronname} {TDstart} {TDsegstart}
        step {third_time}
        DisconnectALLinput 3 {neuronname} {TDstart} {TDsegstart}
    end
    DisconnectALLinput 0 {neuronname} 1 1
    step 0.2 -t
    /*
    for (i=0; i<maxRanSpikes; i=i+1)
        deleteALLspikes {i} {neuronname} {TDstart} {TDsegstart}
    end
    */

    fileFLUSH {Vmfile} 
    fileFLUSH {Cafile} 
    fileFLUSH {Gkfile} 
    fileFLUSH {spinefile}

    setfield {injectName} level1 0

end
