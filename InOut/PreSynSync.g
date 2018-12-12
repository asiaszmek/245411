function PreSynStim(othercell)
str othercell

    if (!{exists {othercell}})
        create compartment {othercell}
        create spikegen {othercell}/spikegen
        setfield {othercell}/spikegen thresh 1
        addmsg {othercell} {othercell}/spikegen INPUT Vm

    end
end

function PreSynSync(othercell, cellpath)
str othercell,cellpath

    int j
    str CompName

   PreSynStim {othercell} 
   for (j=1; j<12; j=j+1)
        if ({spinesYesNo})
            CompName={cellpath}@"/tertdend1_"@{j}@"/spine_1/"@{spcomp1}
        else
            CompName={cellpath}@"/tertdend1_"@{j}
        end
        addmsg   {othercell}/spikegen  {CompName}/{NMDAname} SPIKE 
        addmsg   {othercell}/spikegen  {CompName}/{AMPAname} SPIKE 
   end
   for (j=2; j<=16; j=j+1)
        if ({spinesYesNo})
            CompName={cellpath}@"/tertdend"@{j}@"_1/spine_1/"@{spcomp1}
        else
            CompName={cellpath}@"/tertdend"@{j}@"_1"
        end
        addmsg   {othercell}/spikegen  {CompName}/{NMDAname} SPIKE 
        addmsg   {othercell}/spikegen  {CompName}/{AMPAname} SPIKE 
   end
end

function PreSynSyncRandom(othercell, cellpath, ConnProb, targetcomp)
str othercell,cellpath
str targetcomp
float ConnProb

//targetcomp is either a number specifying distance from soma for synaptic input
//or it is the word "any" to allow connecting to any segment of your morphology
//this will have to be modified if using real morphology, or multiple spines per comp

    int anycomp=0
    str CompName
    float rannum
    float position,targetlocation

    if ({targetcomp} == "any")
        targetlocation=somaLen
    else
        targetlocation={targetcomp}
    end

    PreSynStim {othercell} 
    int anystim=0
    foreach CompName ({el {cellpath}/#[TYPE=compartment]}) 
        position={getfield {CompName} position}
        if ({position}>={targetlocation})
            rannum={rand 0 1}
            if ({rannum}<{ConnProb})
                if ({spinesYesNo})
                    str stimname={CompName}@"/spine_1/"@{spcomp1}
                else
                    str stimname={CompName}
                end
                anystim=1
                addmsg   {othercell}/spikegen  {stimname}/{NMDAname} SPIKE 
                addmsg   {othercell}/spikegen  {stimname}/{AMPAname} SPIKE 
		if ({desensYesNo}==1)
			addmsg   {othercell}/spikegen  {facchan} SPIKE
			echo "Stimulating Facsynchan"
		end
            end
        end
    end
    return {anystim}
end

//Functon call, from STDP or PlasStim:
//float GabaProb=0.5
//float MaxDist="100e-6"
//float GabaDelay=30e-3
//PreSynSyncGaba {precell} {neuronname} {GabaProb} {MaxDist} {GabaDelay}

function PreSynSyncGaba(othercell, cellpath, ConnProb, GabaDist, StimDelay)
str othercell,cellpath
float GabaDist, StimDelay
float ConnProb

//targetcomp is either a number specifying max distance from soma for synaptic input
//or it is the word "any" to allow connecting to any segment of your morphology
//StimDelay is the delay between Ctx stimulation and triggering a GABA PSP due to AP in FSI

    int anycomp=0
    str CompName
    float rannum
    float position


    PreSynStim {othercell} 
    int anystim=0
    foreach CompName ({el {cellpath}/#[TYPE=compartment]}) 
        position={getfield {CompName} position}
        if ({position}<={GabaDist})
            rannum={rand 0 1}
            if ({rannum}<{ConnProb})
              str stimname={CompName}
              anystim=1
              addmsg   {othercell}/spikegen  {stimname}/{GABAname} SPIKE 
							int msgnum = {getfield {CompName}/{GABAname} nsynapses} - 1
							setfield {CompName}/{GABAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay StimDelay
            end
        end
    end
    return {anystim}
end

