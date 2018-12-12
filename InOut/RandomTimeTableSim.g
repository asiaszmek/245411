
function createRandTimeTables(path,name,nTables,meanFreq,duration)
    int i,nTables
    float meanFreq,duration
    str path
    str name
    if(!{exists {path}})
        create neutral {path}
    end
// Loop to setup time table objects
    for (i = 1;i<nTables+1;i=i+1)
        create timetable {path}/{name}[{i}]
        setfield {path}/{name}[{i}] maxtime {duration} act_val 1.0 method 1 meth_desc1 {meanFreq}
        call {path}/{name}[{i}] TABFILL
        // Note: Time Table can connect directly to synapse with
        //       activation message, but not SPIKE message; Spike message
        //       is handled differently by SYNCHAN, allowing creating of synapse with weights/delays
        create spikegen {path}/{name}[{i}]/spikes

        setfield {path}/{name}[{i}]/spikes \
                 output_amp 1 thresh 0.5 abs_refract 0.0001

        addmsg {path}/{name}[{i}] {path}/{name}[{i}]/spikes \
               INPUT activation
    end
end

// Connect time tables to synapses

function countSynapses(synTypeSearchString, return_synpath,synindex)
    str synTypeSearchString
    str synpath
    int return_synpath
    int synindex
    int syncount = 0
    str compt
    str searchstr
    foreach compt ({el {neuronname}/##/{synTypeSearchString}})
            
        syncount = syncount+1
        if (syncount == synindex)
            //echo {compt} {syncount}
            synpath = compt
        end
    end
    //echo {"syncount= "@{syncount}}
    if (return_synpath==1)
        return synpath
    else
        return syncount
    end
end

