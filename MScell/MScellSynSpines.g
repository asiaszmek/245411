//genesis
//MScellSynSpines.g

/***************************		MS Model, Version 12	*********************
This is the top level model file, to be called by MSsim.g

	Avrama Blackwell 	kblackw1@gmu.edu
	Rebekah Evans 		rcolema2@gmu.edu
	Sriram 				dsriraman@gmail.com	
******************************************************************************/

include MScell/MScell.g                 //MScell without synapses or spines
if ({exists {getglobal EkAMPA}})
    include MScell/SynParamsCtx.g               //parameters for synaptic channel
end
include MScell/channels/synaptic_channel.g // function to make non-nmda synaptic channels in library
include MScell/channels/nmda_channel.g   //function to make nmda channel, either GHK or not, in library
include MScell/AddSynapticChannels.g	// contains functions to add synaptic channels to compartments
include MScell/AddCaSpines.g		//includes calcium channels, creates difshells in spine
include MScell/spines.g           //creates spines, puts channels & calcium in spines


function make_MS_cell_SynSpine (cellname,pfile,spinesYN, DA)
    str cellname,pfile
    int spinesYN

    str CompName, DA

    //******** make the cell without spines or synapses
    make_MS_cell {cellname} {pfile} {DA}

	//************* create synaptic channels and spine proto in library *
    pushe /library

  	make_synaptic_channel  {AMPAname} {AMPAtau1} {AMPAtau2} {AMPAgmax} {EkAMPA} {AMPAdes} {AMPAdestau} 
  	make_NMDA_channel   {NMDAname} {EkNMDA} {Kmg} {NMDAtau2} {NMDAgmax} {ghk_yesno} {NMDAdes} {NMDAdestau} {nmdacdiyesno}
	make_synaptic_channel  {GABAname} {GABAtau1} {GABAtau2} {GABAgmax} {EkGABA} 0 0

    int neckslabs={make_spineProto}

    pope {cellname}

   //********************* add spines (with synapses) or just synapses
    int totspines=0

    if (spinesYN==1)
        // NMDA and AMPA channels are already added in the spine prototype
        //Also, calcium is already implemented in the spines
        totspines = {add_spines_evenly  {cellname} spine  {spineStart} {spineEnd} {spineDensity} {neckslabs} {spineCommonParent}}
        if(synYesNo==1)
            foreach CompName ({el {cellname}/#[TYPE={compartment}]}) 
                addSynChannel  {CompName} {GABAname} {GABAgmax}	"dummyshell"
            end
        end
        
    else  //if no spines, add all synaptic channels to dendrite, add dendritic pool of calcium for NMDA


        //*******************foreach compartment that WOULD have spines, compensate RM and CM accordingly
        // Cm_new = Cm_old * (compartment_area + spine_area)/comparment_area
        // Rm_new = Rm_old/(compartment_area + spine_area)/compartment_area
                
       /* str compt
        foreach compt ({el {cellname}/#[TYPE=compartment]})
        	 if (!{{compt}=={{cellname}@"/axIS"} || {compt}=={{cellname}@"/ax"}}) 
                float dia={getfield {compt} dia}
                float position={getfield {compt} position}
                float parentPathlen={getfield {compt} pathlen}
                float len={getfield {compt} len}
                float surfaceArea ={{PI}*{dia}*{len}}
                echo {compt} SurfaceArea= {surfaceArea}
                float singleSpineSurf = {{{dia_head}*{len_head}*{PI}} + {{dia_neck}*{len_neck}*{PI}} }
                echo {compt} singleSpineSurfaceArea= {singleSpineSurf}
                float Cm_old = {getfield {compt} Cm}
                float Rm_old = {getfield {compt} Rm}
                if ({position>={spineStart}} && {position<{spineEnd}} ) //it's a compartment that would have spines
                    int numspines = {{spineDensity} * {len} * 1e6}
                  // numspines = 1
                    echo numspines= {numspines}
                    float totalSpineSurf = {{singleSpineSurf}*{numspines}}
                    echo {compt} TotalSpineSurfaceArea= {totalSpineSurf}
                    setfield {compt} \
                        Cm  {1.0*{Cm_old}*{{surfaceArea}+{totalSpineSurf}}/{surfaceArea}} \
                        Rm  {{Rm_old}/{{{surfaceArea}+{totalSpineSurf}}/{surfaceArea}}}
                    echo {compt} oldRm= {Rm_old} NewRm= {getfield {compt} Rm}
                    echo {compt} oldCm= {Cm_old} NewCm= {getfield {compt} Cm}

                   // float gKCaL12_old = {getfield {compt}"/CaL12_channelGHK" Gk}
                    //float gKCaL13_old = {getfield {compt}"/CaL13_channelGHK" Gk}
                    //float gKCaR_old = {getfield {compt}"/CaR_channelGHK" Gk}
                   // float gKCaT_old = {getfield {compt}"/CaT_channelGHK" Gk}
                   // setfield {{compt}@"/CaL12_channelGHK" Gk {gKCaL12_old*surfaceArea+
                    
                end
            end
        end*/


        if (synYesNo==1)
            if ({calciumtype}==1)
                add_CaConcen {NMDApool} 0 500e-6 {cellname}
            end

            foreach CompName ({el {cellname}/#[TYPE={compartment}]})
                addNMDAchannel {CompName} {NMDAname} {NMDApool} {NMDAgmax} {ghk_yesno} {nmdacdiyesno}
                addSynChannel  {CompName} {AMPAname} {AMPAgmax} {NMDApool} 
                addSynChannel  {CompName} {GABAname} {GABAgmax}	"dummyshell"
            end
        end
    end
    return totspines
end
