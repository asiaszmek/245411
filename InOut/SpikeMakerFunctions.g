//genesis
//SpikeMakerFunctions.g

//Note: the *ALL* functions assume 4 primdends, 2 secdends / primdend, and 12 tert sections
//tertstart and tertsegstart = 2 are used to "reserve" some dendrites for synchronous stim, for STDP

function makeSpikeSet(morphName,numstart,numend,ranspikeNum,Hz,cell)
    //0 goes to GABA, 1, and optionally 2 & 3 go to GLU
    str morphName,cell
    int numstart,numend,ranspikeNum
    float Hz

    str path
    int segnum
    for (segnum=numstart;segnum<numend;segnum=segnum+1)
        foreach path({el {cell}/{morphName}{segnum}})
            if (!{exists {path}/randomspike{ranspikeNum}})
                create randomspike {path}/randomspike{ranspikeNum}
            end
            setfield {path}/randomspike{ranspikeNum} min_amp 1.0 max_amp 1.0 rate {Hz} reset 1 reset_value 0
        end
    end
end

function makeALLspikes (rate, ranSpikeNum,cell, tertstart,tertsegstart)
    float rate
    int ranSpikeNum, tertstart, tertsegstart
    str cell

    echo "makeALL"{ranSpikeNum} {rate} "Hz" {tertstart} {tertsegstart}
    int j

    makeSpikeSet primdend 1 5 {ranSpikeNum} {rate} {cell}
    makeSpikeSet secdend 11 13 {ranSpikeNum} {rate} {cell}
    makeSpikeSet secdend 21 23 {ranSpikeNum} {rate} {cell}
    makeSpikeSet secdend 31 33 {ranSpikeNum} {rate} {cell}
    makeSpikeSet secdend 41 43 {ranSpikeNum} {rate} {cell}
	for (j=tertstart;j<17;j=j+1)
        makeSpikeSet tertdend{j}_ {tertsegstart} 12 {ranSpikeNum} {rate} {cell}
    end
    reset
end

function ConnectOneInput(pathspike, path) 
	str pathspike, path
	int msgnum
	addmsg {pathspike} {path} SPIKE
    msgnum = {getfield {path} nsynapses} - 1
   	 setfield {path} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay 0
end

function ConnectInputSet(morphName,numstart,numend,spikeNum, cell)
    str morphName, cell
    int numstart,numend
    int spikeNum

    str path
    int i

    if ({spinesYesNo})
        str glupath="/spine_1/"@{spcomp1}@"/"
    else
        str glupath="/"
    end

    for (i=numstart;i<numend;i=i+1)
        foreach path({el {cell}/{morphName}{i}})
            if ({spikeNum} == 0)
                ConnectOneInput {path}/randomspike0 {path}/GABA
            else
                ConnectOneInput {path}/randomspike{spikeNum} {path}{glupath}AMPA
                ConnectOneInput {path}/randomspike{spikeNum} {path}{glupath}{subunit}
            end
         end
    end
end

function ConnectALLInput (ranSpikeNum, cell, tertstart,tertsegstart)
    int ranSpikeNum
    str cell
    int j, tertstart, tertsegstart

    echo "connect input" {ranSpikeNum}
    ConnectInputSet primdend 1 5 {ranSpikeNum} {cell} 
    ConnectInputSet secdend 11 13 {ranSpikeNum} {cell} 
    ConnectInputSet secdend 21 23 {ranSpikeNum} {cell} 
    ConnectInputSet secdend 31 33 {ranSpikeNum} {cell} 
    ConnectInputSet secdend 41 43 {ranSpikeNum} {cell} 
	for (j=tertstart;j<17;j=j+1)
        ConnectInputSet tertdend{j}_ {tertsegstart} 12 {ranSpikeNum} {cell} 
    end
end

function DisconnectInputSet(morphName,numstart,numend,ranSpikeNum, cell)
    str morphName,cell
    int numstart,numend, ranSpikeNum
    str path
    int segnum

    if ({spinesYesNo})
        str glupath="/spine_1/"@{spcomp1}@"/"
    else
        str glupath="/"
    end
    for (segnum=numstart;segnum<numend;segnum=segnum+1)
        foreach path({el {cell}/{morphName}{segnum}})
            if ({ranSpikeNum}==0)
                deletemsg {path}/GABA 1 -incoming
            else
                deletemsg {path}{glupath}AMPA 1 -incoming
                deletemsg {path}{glupath}{subunit} 1 -incoming
            end
        end
    end
end

function DisconnectALLinput (ranSpikeNum,cell, tertstart,tertsegstart)
    str cell
    int ranSpikeNum
    int j, tertstart, tertsegstart

    echo "disconnect input" {ranSpikeNum} {cell}
    DisconnectInputSet primdend 1 5 {ranSpikeNum} {cell}
    DisconnectInputSet secdend 11 13 {ranSpikeNum} {cell}
    DisconnectInputSet secdend 21 23 {ranSpikeNum} {cell}
    DisconnectInputSet secdend 31 33 {ranSpikeNum} {cell}
    DisconnectInputSet secdend 41 43 {ranSpikeNum} {cell}
	for (j=tertstart;j<17;j=j+1)
        DisconnectInputSet tertdend{j}_ {tertsegstart} 12 {ranSpikeNum} {cell}
    end
end

function deleteSpikeSet(morphName,numstart,numend,ranspikeNum, cell)
    str morphName,cell
    int numstart,numend
    int ranspikeNum
    str path
    int segnum

    for (segnum=numstart;segnum<numend;segnum=segnum+1)
        foreach path({el {cell}/{morphName}{segnum}})
            delete {path}/randomspike{ranspikeNum}
        end
    end
end

function deleteALLspikes (ranSpikeNum, cell, tertstart,tertsegstart)
    int ranSpikeNum
    str cell
    int j, tertstart, tertsegstart

    deleteSpikeSet primdend 1 5 {ranSpikeNum} {cell}
    deleteSpikeSet secdend 11 13 {ranSpikeNum} {cell}
    deleteSpikeSet secdend 21 23 {ranSpikeNum} {cell}
    deleteSpikeSet secdend 31 33 {ranSpikeNum} {cell}
    deleteSpikeSet secdend 41 43 {ranSpikeNum} {cell}
	for (j=tertstart;j<17;j=j+1)
        deleteSpikeSet tertdend{j}_ {tertsegstart} 12 {ranSpikeNum} {cell}
    end
    reset
end
