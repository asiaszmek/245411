//genesis 
//HookUp.g
//Can give pattern of current injection and/or pattern of pre-syn stim, allowing STDP, HFS, Theta, etc
//pulse>=1 and numtrains>=1 else there will be NO pre-syn stim (good for evaluating AP alone)
//AND preStimPct>0, else there will be NO pre-syn stim
//inject=0 will give pre-syn stim alone, without triggered AP (e.g. hfs or theta)
//set TooFast = 100 will revert to stimulating just one spine, even for 50 Hz stimulation
//If no synaptic stimulation StimComp is where one specifies which spine output to save
/*Commented out lines allow giving a pulse before and after, to test the plasticity
and also repeating the pairings.  BUT, these will mess up the alignment of the 
pre-synaptic stim and the post-synaptic depol.  So, fix the pulse generators when you uncomment them */

function connect_synapse_spikegen(input,spikegen,stimname,name)
    str input,spikegen,stimname,name
    if ({exists {stimname}/{name}})
        addmsg {input}/{spikegen}  {stimname}/{name} SPIKE 
    else    
        echo could not find {stimname}/{name}
    end
end

function set_timetable(input_name,fname_base,i,maxt,fnam, spikegen,StimComp, spike_history)
    str input_name, fnam,  fname_base, spikegen, StimComp, spike_history
    int i
    float maxt
    str stimname


    pushe /
    create timetable {input_name}[{i}]
    echo {input_name}[{i}] {StimComp}  "max time"  {maxt}
    setfield {input_name}[{i}] maxtime {maxt} \
        method 4 \
        act_val 1.0 \ 
        fname {fname_base}
    
    call {input_name}[{i}] TABFILL
    create spikegen {input_name}[{i}]/{spikegen}
    setfield {input_name}[{i}]/{spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
    addmsg {input_name}[{i}] {input_name}[{i}]/{spikegen} INPUT activation
    
    create spikehistory {spike_history}[{i}].history
    setfield {spike_history}[{i}].history ident_toggle 1 filename {fnam} initialize 1 leave_open 1 flush 1
    addmsg {input_name}/spikes {spike_history}[{i}].history SPIKESAVE
    
end
//pass the name of the paradigm, because it is used in naming spine stimulation files

function HookUp(PreStim, paradigm, timing, StimComp, file,numAP,inj,dur,interval, isi, pulseFreq, pulses, burstFreq, numbursts, trainFreq, numtrains, jitter, ChanString)
    int PreStim
    str StimComp,file, compt, paradigm, timing,ChanString
    //These are parameters related to both pre-and post-synaptic AP (EPSP) pattern
    int numbursts, numtrains
    float trainFreq, burstFreq
    float isi //interval between onset of EPSP and onset of AP
    //These are parameters related to pre-synaptic stimulation - pulses in a burst
    int pulses
	float pulseFreq
    //These parameters describe post-synaptic stimulation - AP in a burst
	int numAP 
    float inj, dur, interval, interpulse=0, bufpos
    str spikegen = "spikes", bufStrTmp, whereStim
    // Determine the interpulse intervals for pre-synaptic stimulation
    if ({pulses}>1)
        interpulse=1./{pulseFreq}
    end
    // Determine the interburst and intertrain intervals for pre- and post- stimulation
    float intertrain=0, interburst=0
    interburst = 1.0/{burstFreq}
    intertrain = 1.0/{trainFreq}
    int pulse, train, burst
    str spines_to_hook_up = "1"
    //delay refers to onset of current injection relative to first pulse, which occurs at initSim
    //float TooFast = 30     //if pre-syn pulses in burst are too fast, distribute them among multiple spines
    if ({pulseYN})
    	float AP_delay= {2*initSim + isi}//+ (pulses-1)*interpulse}
    else
        float AP_delay = {initSim + isi}// + (pulses-1)*interpulse}
    end

    if ({isi} > 0) 
        AP_delay = {AP_delay}
    else
        AP_delay = {AP_delay} - ({numAP}-1)*{interval}
    end

    echo "APdelay" {AP_delay}
		//parameters for post-synaptic spike generators

    if ({interval} == 0 )
        echo "Wrong paradigm chosen. You can choose: P_and_K (Pawlak and Kerr), K_and_P (Kerr and Plenz), Shindou, Shen and IF (IF curves)"
        return
    end

    if ({interval}<{dur})
        echo "please define lower AP frequency"
    end

    //**********set the filenames, and 
    //set up presynaptic element for stimulating
    float maxt = {numtrains/trainFreq+2*initSim}

    str filenam={file}
    if ({GABAYesNo})
        filenam={file}@"_gaba_delay_"@{GABAdelay}@"_"

        if ({GABAstim} == "")
            GABAstim = {StimComp}
        end
        bufStrTmp = {StimComp}

        

        bufpos = 0 
        str gaba_file = {paradigm}@"_"@{timing}@"_gaba" 
        int i = 0
        while ({bufpos} > -1)
            bufpos = {findchar {bufStrTmp} ,}
            if ({bufpos} == -1)
                whereStim = {bufStrTmp}
            else
                whereStim = {substring {bufStrTmp} 0 {bufpos-1}}
                bufStrTmp = {substring {bufStrTmp} {bufpos+1}}
            end
            filenam = {filenam}@"_"@whereStim@"_"@"GABAtau2_"@{GABAtau2}@"_" 

            set_timetable {GABA_input} {gaba_file} {i} {maxt} {filenam} {spikegen} {whereStim} "GABASynTimes"
                    

            str stimname = {neuronname}@"/"@{whereStim}
            connect_synapse_spikegen {GABA_input}[{i}] {spikegen} {stimname} {GABAname} 
            i = i + 1
        end
    else
        if ({GABAtonic}==0)
            filenam={file}@"_no_gaba_"
        end
    end

    if ({jitter} == 1)
        filenam = {filenam}@"jitter_"
    end

    if ({abs {isi}}<{SMALLNUMBER})
        isi=0
    end
    //Used for stimulation during simulation
    filenam={filenam}@"Stim_"@{StimComp}@"_AP_"@{numAP}@"_ISI_"@{isi}@"_PSP_"@{pulses}@"_interpulse_"@{interpulse}
        
    if ({spinesYesNo})       
        if ({PreStim}>0)
            echo "before pulseFreq entry pulseFreq" {pulseFreq} {TooFast} {pulses}
            str fname_base = paradigm@"_"@timing@"_stimulation_spine_"
            int dendPos = 0
            str dendBuf = {StimComp}
            str whichSegment
            str stimname
            
            if ({pulses} == 1)
                int help = {findchar {whichSpines} ,}
                spines_to_hook_up = {substring {whichSpines} 0 {help-1}}
            else
                spines_to_hook_up = {whichSpines}
            end
            int i = 0
            while ({dendPos} >-1)
                dendPos = {findchar {dendBuf} ,}
                if ({dendPos} == -1)
                    whichSegment = {dendBuf}
                else
                    whichSegment = {substring {dendBuf} 0 {dendPos-1}}
                    dendBuf = {substring {dendBuf} {dendPos+1}}
                end

                bufpos =0
                bufStrTmp  = spines_to_hook_up 
                str whichSpine
              
                while ({bufpos} > -1)
                    bufpos = {findchar {bufStrTmp} ,}
                    if ({bufpos} == -1)
                       whichSpine = {bufStrTmp}
                    else
                       whichSpine = {substring {bufStrTmp} 0 {bufpos-1}}
                        bufStrTmp = {substring {bufStrTmp} {bufpos+1}}
                    end
                    str fnam = {filenam}@"_spikes_"@{whichSpine}

                    str spikegen_file = {fname_base}@{whichSpine}


                    set_timetable {input_name} {spikegen_file} {i} {maxt} {fnam} {spikegen} {whichSegment} "SynTimes"
                
                    stimname = {neuronname}@"/"@{whichSegment}@"/spine_"@{whichSpine}@"/"@{spcomp1}
                    
                    connect_synapse_spikegen {input_name}[{i}] {spikegen} {stimname} {NMDAname}
                    connect_synapse_spikegen {input_name}[{i}] {spikegen} {stimname} {AMPAname}
                    i = {i+1}
                end
            end
        end
    end
    /*    //Does not really work, should be rewritten
        str stimname={StimComp}
        create timetable {input_name}
        set_timetable {input_name} {numtrains}/{trainFreq} {filename}
        connect_synapse_spikegen {input_name} {NMDAname} {neuronname} {stimname}
        connect_synapse_spikegen {input_name} {AMPAname} {neuronname} {stimname}

    end
*/       

    echo "################ simulating STDP, " {numAP} "AP, ISI: " {isi} 
 
    //set-up file names, post-synaptic spike generators
    if ({spinesYesNo})
        spinehead={add_output_hook_up {spinefile} {neuronname} {StimComp} {spines_to_hook_up} {ChanString} {PreStim}}
        //echo {spinehead}
    end
    
    setfilename {Vmfile} {filenam} 1 {Vmhead}
    setfilename {Cafile} {filenam} 1 {Cahead}
    setfilename {Gkfile} {filenam} 1 {Gkhead}
    setfilename {spinefile} {filenam} 1 {spinehead}

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
    echo go {go}
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
        createPulseGen {inj} {basal_current} 0 {interval} {dur} {neuronname}/soma {injectName} 2 "INJECT"
        createPulseGen {inj} {basal_current} 0 {interburst} {width_burst} {injectName}  {injectName}/burst_gate 2 "INPUT"
        createPulseGen {inj} {basal_current} 0 {intertrain} {width_train}  {injectName}/burst_gate  {injectName}/train_gate 2 "INPUT"
        createPulseGen {inj} {basal_current} {AP_delay} {very_big_number} {exp_duration}  {injectName}/train_gate  {injectName}/experiment_gate 0 "INPUT"
        if ({somainjout})
            str inj_header
            inj_header = {add_outputPulseGen {somainjfile} {injectName}}
            setfilename {somainjfile} {filenam} 1 {inj_header}
        else
            inj_header = ""
            somainjfile = "X"
        end
    end

   
    
    
 reset
end
