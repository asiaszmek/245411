//genesis
//UpState.g
//Figure out how these different random spikes were used.  May be possible to create them one at a time, or only use one, and change its rate

function UpState(AP_time,AP_durtime,inj,upstate_time, seedval, file)
    float AP_time,AP_durtime,inj,upstate_time
    int seedval
    str file

    int TDstart=1
    int TDsegstart=1
    randseed {seedval}
    int maxRanSpikes, i

    float third_time = {upstate_time}-{first_time}-{second_time}
    //**********set the filenames
    if ({inj}==0)
         str filenam={file}@"Up_"@{Rate1}@"_"@{Rate2}@"_"@{Rate3}@"_noAP"
    else
        str filenam={file}@"Up_"@{Rate1}@"_"@{Rate2}@"_"@{Rate3}@"_AP"@{AP_time}
    end
    echo "################ simulating Upstate, Rates" {Rate1} {Rate2} {Rate3} "AP: " {AP_time} "Inj: " {inj*1e-9}

    setfilename {Vmfile} {filenam} 1 {Vmhead}
    setfilename {Cafile} {filenam} 1 {Cahead}
    setfilename {Gkfile} {filenam} 1 {Gkhead}
    setfilename {spinefile} {filenam} 1 {spinehead}
    //**********create pulse generator for current injection
    float basal_current = 0
    str injectName="/injectCurr"
    createPulseGen {inj} {basal_current} {AP_time+0.05} {AP_durtime} {neuronname}/soma {injectName} 0 "no message"


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
    step 0.05 -time

    ConnectALLInput 0 {neuronname} 1 1
    ConnectALLInput 1 {neuronname}  {TDstart} {TDsegstart}
    step {first_time} -time
    DisconnectALLinput 1 {neuronname} {TDstart} {TDsegstart}

    if ({first_time} < {upstate_time})
        ConnectALLInput 2 {neuronname} {TDstart} {TDsegstart}
        step {second_time} -time
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
