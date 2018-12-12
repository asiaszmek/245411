//genesis
//ConstrainUp.g
/*Functions used to connect a set of spines that are constrained by
 *pathlength from soma
 *sharing a common parent branch, either soma, primary, secondary, or tertiary
*/

function ConnectWithDelay (totalDelay,meanDelay,othercell,compt,branchoffset,randDelayYesNo,mirrorBranch)
	str othercell, compt
	float meanDelay,branchoffset, mirrorBranch
    float totalDelay
    int i
    int randDelayYesNo
    //echo "minDelay: " {minDelay} " maxDelay: " {maxDelay} " StimDelay: " {StimDelay}
	addmsg   {othercell}/spikegen  {compt}/{NMDAname} SPIKE 
	addmsg   {othercell}/spikegen  {compt}/{AMPAname} SPIKE 
	int msgnum = {getfield {compt}/{NMDAname} nsynapses} - 1
    if ({randDelayYesNo}==0)
        setfield {compt}/{NMDAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay {totalDelay+meanDelay+branchoffset}
            
        msgnum = {getfield {compt}/{AMPAname} nsynapses} - 1
        setfield {compt}/{AMPAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay {totalDelay+meanDelay+branchoffset}
        
        totalDelay = totalDelay+meanDelay
    else
        float randDelay = {{-1.0*{meanDelay}}*{log {rand 0 1}}} // Transform from uniform dist to exp dist: -mean_expdist*ln(uniform(0,1))
        float randBound = {10.0*{meanDelay}}
        if ({randDelay}>{randBound})
            randDelay={randBound}
        end
        echo "random exponential for ISI= " {randDelay}
        setfield {compt}/{NMDAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay {totalDelay+randDelay+branchoffset}
        msgnum = {getfield {compt}/{AMPAname} nsynapses} - 1
        setfield {compt}/{AMPAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay {totalDelay+randDelay+branchoffset}
        totalDelay = totalDelay+randDelay
    end
    
	return {totalDelay}

end


// This function loops through all spines, determines if each is valid (e.g. meets parent branch, distance requirements,
// and appends valid spine names to a space-separated list (as a single string) which can then be manipulated with arglist, getarg routines
function countSpines(startcomp,parenttype,maxpath)
    int parenttype
    str startcomp
    float maxpath
    
    str spinelist="",compt,compParent,commonBranch
    float compPathLen,rannum,minpath
    int numsp=0

    //extract minpath from starting compartment; maxpath is total distance between start comp and most distant spine
	minpath={getfield {neuronname}/{startcomp} pathlen}-{getfield {neuronname}/{startcomp} len}/2
    maxpath={minpath}+{maxpath}

	//parenttype is either 0:soma, 1:parentprim, 2:parentsec, 3:parenttert
	if ({parenttype}==0)
		commonBranch="soma"
	elif ({parenttype}==1)
		commonBranch={getfield {neuronname}/{startcomp} parentprim}
	elif ({parenttype}==2)
		commonBranch={getfield {neuronname}/{startcomp} parentsec}
	elif ({parenttype}==3)
		commonBranch={getfield {neuronname}/{startcomp} parenttert}
	end

	foreach compt ({el {neuronname}/##[TYPE=compartment]}) 
		//is this a spine head, if so, determine pathlength
		if ({strcmp {getpath {compt} -tail} "head"} == 0)
			compPathLen={getfield {compt} pathlen}
			//is pathlength within min and max?  If so, determine parent branch
			if ((compPathLen > minpath) && (compPathLen < maxpath))
               // echo "within path length" {compt}
				if ({parenttype} == 1)
					compParent={getfield {compt} parentprim}
				elif ({parenttype} == 2)
					compParent={getfield {compt} parentsec}
				elif ({parenttype} == 3)
					compParent={getfield {compt} parenttert}
				else
					compParent="soma"
				end
				//is parent branch correct?  if so count it and append to valid spine list
				if ({strcmp {compParent} {commonBranch}}==0)
					//count valid spines
					echo "valid sp" {compt} {compPathLen} "bt" {minpath} "&" {maxpath} "par:" {compParent} "numsp" {numsp+1}
					numsp=numsp+1
                    //append spinecompartment to spinelist followed by a space for a space-separated list
                    spinelist = spinelist @ {compt} @ " "
                    //echo {spinelist}
				end
			end
		end
	end
	return {spinelist}
end

//This function reads in a list of valid spines and the total number to connect, and connects the total number randomly by passing to connect w/delay 
//Note: this enables user to provide explicit list and option to connect to all in list in order or to use a list of spines generated by countSpines
function connectSpines(spinelist,numstim,meanDelay,randDelayYesNo,branchoffset,mirrorBranch) //will need to add delay terms for when passing to connectwdelay
    str spinelist
    int numstim, randDelayYesNo, mirrorBranch
    float meanDelay, branchoffset
    float totalDelay = 0.0
    
    int numconnected = 0
    while (numconnected < numstim) //randomly select spine to connect until desired number (numstim) are connected
        int listlen= {getarg {arglist {spinelist}} -count} //how many left in list?
        int prob = {rand 1 {listlen+0.99999999}} //randomly select 1 integer within length of list. Note: 0.99... because int(rand b/t 1,1.999...) returns 1, etc., so i want the last item in list (for example, if listlen = 20, item 20) to have same probablility of being selected. Any rand b/t 20-20.999... returns 20 as int
        str connectwhich = {getarg {arglist {spinelist}} -arg {prob}} //which spine (based on index from prob)?
        totalDelay={ConnectWithDelay {totalDelay} {meanDelay} {precell} {connectwhich} {branchoffset} {randDelayYesNo} {mirrorBranch}}
        if ({mirrorBranch}==1)
            str mirrorcompt = {strsub {connectwhich} "tertdend1_" "tertdend2_"}
            ConnectWithDelay {totalDelay} 0.0 {precell} {mirrorcompt} {branchoffset} 0 1 //ConnectwithDelay but don't return new total Delay and pass mean 0, not rando, to match delay on original branch
        end
        echo "connect" {connectwhich} " delay" {totalDelay}
        numconnected = numconnected+1
        // Generate new spinelist that takes the last entry and moves it to the entry just selected and reduces list by 1
        str newlist = ""
        int i
        for (i=1;i<listlen;i=i+1)
            if (i==prob)
                str append = {getarg {arglist {spinelist}} -arg {listlen}}
            else
                str append = {getarg {arglist {spinelist}} -arg {i}}
            end
            newlist = newlist @ append @ " "
        end
        //echo {newlist}
        //echo {listlen}
        spinelist = newlist
    end
end

/* This function loops through all spines to either count the number filling criteria
   or to connect one of those spines */
function spineLoop(startcomp,parenttype,maxpath,connectProb,maxdelay,mindelay,mirrorbranch,branchoffset)
  int parenttype,mirrorbranch
	str startcomp, connectProb
	float maxpath,maxdelay,mindelay,branchoffset

	float compPathLen,ConnProb, rannum,StimDelay,meanDelay=0
	str compt,compParent,commonBranch
	int numsp=0,connect=0
    //echo "spineLoop function minDelay= " {mindelay}
	//extract minpath from the starting compartment
	//maxpath is the total distance between start comp and most distance spine
	float minpath={getfield {neuronname}/{startcomp} pathlen}-{getfield {neuronname}/{startcomp} len}/2
	maxpath={minpath}+{maxpath}

	//strcmp returns 0 if connectProb = 0, so we do this only if NE 0
	if ({strcmp {connectProb} "0"})
		connect=1
		ConnProb={connectProb}
	end
		
	//parenttype is either 0:soma, 1:parentprim, 2:parentsec, 3:parenttert
	if ({parenttype}==0)
		commonBranch="soma"
	elif ({parenttype}==1)
		commonBranch={getfield {neuronname}/{startcomp} parentprim}
	elif ({parenttype}==2)
		commonBranch={getfield {neuronname}/{startcomp} parentsec}
	elif ({parenttype}==3)
		commonBranch={getfield {neuronname}/{startcomp} parenttert}
	end

	foreach compt ({el {neuronname}/##[TYPE=compartment]}) 
		//is this a spine head, if so, determine pathlength
		if ({strcmp {getpath {compt} -tail} "head"} == 0)
			compPathLen={getfield {compt} pathlen}
			//is pathlength within min and max?  If so, determine parent branch
			if ((compPathLen > minpath) && (compPathLen < maxpath))
               // echo "within path length" {compt}
				if ({parenttype} == 1)
					compParent={getfield {compt} parentprim}
				elif ({parenttype} == 2)
					compParent={getfield {compt} parentsec}
				elif ({parenttype} == 3)
					compParent={getfield {compt} parenttert}
				else
					compParent="soma"
				end
				//is parent branch correct?  if so either count it (first time through loop) or connect with probability
				if ({strcmp {compParent} {commonBranch}}==0)
					if (connect)
						//if parenttert of this compartment is parenttert of start comp then connect for the mirrorbranch case
                        //if ((mirrorbranch) && ({strcmp {getfield {compt} parenttert} {getfield {neuronname}/{startcomp} parentter}}}==0))
                        rannum={rand 0 1}
						if ({rannum}<{ConnProb})
							StimDelay={ConnectWithDelay {mindelay} {maxdelay} {precell} {compt} {meanDelay} {branchoffset}}
							//count connected spines
							numsp=numsp+1
							meanDelay=meanDelay+StimDelay
							echo "connect" {compt} "ranum" {rannum} "stimdelay" {StimDelay} 
                            if (mirrorbranch)
                                str mirrorcompt = {strsub {compt} "tertdend1_" "tertdend2_"}
						 	    StimDelay={ConnectWithDelay {mindelay} {maxdelay} {precell} {mirrorcompt} {meanDelay} {branchoffset}}
                                echo "connect" {compt} "ranum" {rannum} "stimdelay" {StimDelay}
                                numsp=numsp+1
                            end
						else
							echo "no connect" {compt} {rannum} "gt" {ConnProb}
						end
					else
						//count valid spines
						echo "valid sp" {compt} {compPathLen} "bt" {minpath} "&" {maxpath} "par:" {compParent} "numsp" {numsp+1}
						numsp=numsp+1
					end
				end
			end
		end
	end
	if (connect)
		echo "meanDelay=" {meanDelay/numsp} "num connect=" {numsp}
	end
	return {numsp}
end

function ConstrainUp(numstim,startcomp,parenttype,maxpath,meanDelay,file,mirrorbranch,branchoffset,randDelayYesNo)
    int numstim,parenttype,mirrorbranch,randDelayYesNo
	str startcomp,file
	float maxpath,meanDelay,branchoffset
    
    // note: if mirrorbranch=1, the connected spines (location, and relative temporal order) should be equivalent for the case of multiple branches
	str noConnect="0"
	int nummsg=0
	float initSim=0.1,postSim=0.62

    //*********set up presynaptic element for stimulating
	PreSynStim {precell}
	//addmsg {precell}/spikegen /output/{Vmfile} SAVE state
    if ({mirrorbranch==1})
        numstim = numstim/2 //Only works for if mirroring on 2 total branches, need to make more extensible in future
        // meanDelay/2 as well??
    end
	//call spineloop to count number of valid spines
    str spinelist = {countSpines {startcomp} {parenttype} {maxpath}}
    //echo {spinelist}
    connectSpines {spinelist} {numstim} {meanDelay} {randDelayYesNo} {branchoffset} {mirrorbranch}

end

function connectGABA(totalDelay,compt,othercell,delay,offset)
    str compt, othercell
    float delay,offset, totalDelay
    addmsg {othercell}/spikegen {compt}/{GABAname} SPIKE
    int msgnum = {getfield {compt}/{GABAname} nsynapses} - 1
    setfield {compt}/{GABAname} synapse[{msgnum}].weight 1 synapse[{msgnum}].delay {offset+delay}
    echo "connecting " {compt} "/" {GABAname} " with delay " {offset + delay}
end


function runConstrainUp(numstim,startcomp,parenttype,maxpath,meanDelay,file,mirrorbranch,branchoffset,randDelayYesNo)
    int numstim,parenttype,mirrorbranch,randDelayYesNo
	str startcomp,file
	float maxpath,meanDelay,branchoffset

    int run
  // Set up Hsolve if Using that Method
    if (hsolveYesNo==1)
        call {neuronname}/solve SETUP
    end
    reset
    reset


	//if ({numsp}<{numstim})
      //  echo "PROBLEM in SpineLoop:" {numsp} "spines < " {numstim} ": not enough spines fill criteria" 
//	else
		//calculate connection prob, then call spineloop to connect spines
        //If mirroring branches, need to divide total spines by number of branches
        // also, if mirroring, change parent type to p3 HERE (after counting) so that only 1st branch is connected with spineloop
        // Then, if mirroring, connect with delay will perform the mirrored connection on the 2nd branch
		//float nstim=numstim
        //if (mirrorbranch)
          //  nstim = numstim/2
            //parenttype = 3
        //end
		//float prob=nstim/numsp
		//echo "spines" {numsp} "stim" {numstim} "connecting with probability" {prob}
		//numsp = {spineLoop {startcomp} {parenttype} {maxpath} {prob} {maxdelay} {mindelay} {mirrorbranch} {branchoffset}}
	//end

	//**********set the file name and headers.  Must be after spines connected
    
    spinehead={add_outputMultiSpines {spinefile} {0.1}}
    str saveComps= "secdend11,tertdend1_1,tertdend1_2,tertdend1_3,tertdend1_4,tertdend1_5,tertdend1_6,tertdend1_7,tertdend1_8,tertdend1_9,tertdend1_10,tertdend1_11,tertdend2_1,tertdend2_2,tertdend2_3,tertdend2_4,tertdend2_5,tertdend2_6,tertdend2_7,tertdend2_8,tertdend3_1,tertdend3_2,tertdend3_3,tertdend3_4,tertdend3_5,tertdend3_6,tertdend3_7,tertdend3_8,tertdend3_9,tertdend3_10,tertdend3_11" 
   // // echo {saveComps}
    multispinehead={add_outputOneSpinePerComp {multispinefile} {neuronname} {saveComps} {chans}} // to look at spines in non stim compartments

    str filenam={file}@"p"@{parenttype}@{startcomp}@{maxpath}@"TimeDelay"@{meanDelay}@"Mirror_"@{mirrorbranch}@"BranchOffset_"@{branchoffset}
    spinehead={add_outputMultiSpines {spinefile} {2} {chans}}

    setfilename {Vmfile} {filenam} 1 {Vmhead}
    setfilename {Cafile} {filenam} 1 {Cahead} 
    setfilename {Gkfile} {filenam} 1 {Gkhead}
    setfilename {spinefile} {filenam} 1 {spinehead}
    setfilename {Ikfile} {filenam} 1 {Ikhead}
    setfilename {multispinefile} {filenam} 1 {multispinehead}

  
    float initSim=0.1,postSim=.6

	// //run the simulation
    step {initSim} -time
    setfield {precell} Vm 10
    step 1
    showfield {precell}/spikegen state lastevent
    setfield {precell} Vm 0
	step {postSim} -time

    fileFLUSH {Vmfile} 
    fileFLUSH {Cafile} 
    fileFLUSH {Gkfile} 
    fileFLUSH {spinefile}
    fileFLUSH {Ikfile}
    fileFLUSH {multispinefile}
	// //disconnect the spike generator, in preparation for another stimulation paradigm
	 int nummsg={getmsg {precell}/spikegen -out -count}
	 int i
	 for (i=0; i<nummsg; i=i+1)
	 	deletemsg {precell}/spikegen 0 -outgoing 
	 end

end
