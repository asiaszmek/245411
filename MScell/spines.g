//genesis
//spines.g for including spines in the MSN model.

if ({exists {getglobal len_neck}})
    include MScell/spineParams.g
end
include MScell/AddCaSpines.g

function make_spineProto

    float shell_thick, Ca_tau, kB, kE, r

    float surf_head=dia_head*len_head*{PI}
    float surf_neck=len_neck*dia_neck*{PI}

    // ############# electrical compartments
    if (!{exists spine})
        create compartment spine
    end

    addfield spine position
		addfield spine pathlen    // path length to soma, = position for prototype .p file
		addfield spine parentprim
		addfield spine parentsec
		addfield spine parenttert

    setfield  spine  \
           Cm     {{spineCM}*surf_neck} \
           Ra     /*{spineRa}*/ { 4.0*len_neck*{neckRA}/(dia_neck*dia_neck*{PI})}     \
           Em     {ELEAK}     \
           initVm {EREST_ACT} \
           Rm     {{spineRM}/surf_neck} \
           inject  0.0         \
           dia     {dia_neck}       \
           len     {len_neck}    \
           position 0.0   

    create compartment spine/{spcomp1}
    addfield spine/{spcomp1} position
    addfield spine/{spcomp1} pathlen
		addfield spine/{spcomp1} parentprim
		addfield spine/{spcomp1} parentsec
		addfield spine/{spcomp1} parenttert

    setfield spine/{spcomp1}          \
         Cm     {{spineCM}*surf_head} \
         Ra     {4.0*{spineRA}*len_head/(dia_head*dia_head*{PI})}     \
         Em     {ELEAK}           \
         initVm {EREST_ACT}       \
         Rm     {{spineRM}/surf_head} \
         inject  0.0              \
         dia     {dia_head}         \
         len     {len_head}       \
         position 0.0
/*combine neck-head of CA1 CA1_spine */
    addmsg spine/{spcomp1} spine RAXIAL Ra Vm 
    addmsg spine spine/{spcomp1} AXIAL Vm

// ******** make calcium objects **************************
    enable /library
    if ({spinecalcium}==0)
        //This function adds calcium and buffer shells, connects them, and adds pumps
        //The function is in AddCaSpines.g
		neckSlabs={add_difshell_spine {CalciumName} "neck" {dia_neck} {len_neck} {neckSlabs} {neck_thickness_inc}}
		headSlabs={add_difshell_spine {CalciumName} "head" {dia_head} {len_head} {headSlabs} {head_thickness_inc}}
        echo "new slabs, neck=" {neckSlabs} ", head=" {headSlabs}

        //Connect head to neck, calcium and diffusible buffers

		addmsg spine/{spcomp1}/{CalciumName}{headSlabs} spine/{CalciumName}1 DIFF_DOWN prev_C thick
		addmsg spine/{CalciumName}1 spine/{spcomp1}/{CalciumName}{headSlabs} DIFF_UP prev_C thick
		addmsg spine/{spcomp1}/{CalciumName}{headSlabs}{bname2} spine/{CalciumName}1{bname2} DIFF_DOWN prev_free thick
		addmsg spine/{CalciumName}1{bname2} spine/{spcomp1}/{CalciumName}{headSlabs}{bname2} DIFF_UP prev_free thick
 		addmsg spine/{spcomp1}/{CalciumName}{headSlabs}{bname4} spine/{CalciumName}1{bname4} DIFF_DOWN prev_free thick
		addmsg spine/{CalciumName}1{bname4} spine/{spcomp1}/{CalciumName}{headSlabs}{bname4} DIFF_UP prev_free thick
 		addmsg spine/{spcomp1}/{CalciumName}{headSlabs}{bname1} spine/{CalciumName}1{bname1} DIFF_DOWN prev_free thick
		addmsg spine/{CalciumName}1{bname1} spine/{spcomp1}/{CalciumName}{headSlabs}{bname1} DIFF_UP prev_free thick

        if ({calciumdye}>0)
            addmsg spine/{spcomp1}/{CalciumName}{headSlabs}{bnamefluor} spine/{CalciumName}1{bnamefluor} DIFF_DOWN prev_free thick
            addmsg spine/{CalciumName}1{bnamefluor} spine/{spcomp1}/{CalciumName}{headSlabs}{bnamefluor} DIFF_UP prev_free thick
        end
        bufferNMDA={upperShell}
        
    elif ({spinecalcium}==1)  // Sabatini's model.       Sabatini, 2001,2004
		create Ca_concen  spine/{spcomp1}/{bufferNMDA}  // to create simplified Ca_pool here! 
        kE =86.0                                   // Carter and Sabatini, 2004
        Ca_tau = 25.0e-3                            
        r= (1+kE)/Ca_tau
        if ({calciumdye}==3)
            kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004,STEK
            Ca_tau = (1+kE+kB)/r         // re-calculate time constant because of application of the new calcium-dye
        elif({calciumdye}==2)
            kB = 70                      // Fluo-5F
            Ca_tau = (1+kE+kB)/r
        elif ({calciumdye}==1)
            echo "spines.g, ca_concen: need parameter kB for fura, single tau"
        end
        float shell_vol= {PI}*(dia_head*dia_head/4.0)*len_head
        setfield spine/{spcomp1}/{bufferNMDA} \
                                 B          {1.0/(2.0*96494*shell_vol*(1+kE+kB))} \
                                 tau        {Ca_tau}                         \
                                 Ca_base    {Ca_basal}   \
                                 thick      {shell_thick} 

	end 
    disable /library
/******************Channels***************************
/**** add NMDA/AMPA channels**************************/

pushe spine/{spcomp1}
if(synYesNo==1)
addSynChannel . {AMPAname} {AMPAgmax} {bufferNMDA}
addNMDAchannel . {NMDAname} {bufferNMDA} {NMDAgmax} {ghk_yesno} {nmdacdiyesno}
end

/*****************  add L-type, R-type, and T-type Calcium Channels*****************/

//  addCaChannel {obj} {compt} {Gchan} {CalciumBuffer}
  if({addCa2Spine}==1)
     if ({spinecalcium}==0)
        addCaChannelspines CaL12_channel      .  {gCaL12spine}    {CalciumName}2         // HVA CaL
        addCaChannelspines CaL13_channel      .  {gCaL13spine}    {CalciumName}1      // LVA CaL
        addCaChannelspines CaR_channel        .  {gCaRspine}      {CalciumName}2
        addCaChannelspines CaT32_channel        .  {gCaT32spine}      {CalciumName}2
        addCaChannelspines CaT33_channel        .  {gCaT33spine}      {CalciumName}2
        addKCaChannelspines SK_channel        .  {gSKspine}       {CalciumName}2
     elif ({spinecalcium}==1)
        copy   {bufferNMDA} {bufferNR}
        copy   {bufferNMDA} {bufferLT}
        copy   {bufferNMDA} {bufferAll}

        addmsg {NMDAname} {bufferAll} I_Ca Ik

        if ({gCaL12spine} > {SMALLNUMBER})
            addCaChannelspines CaL12_channel      .  {gCaL12spine}    {bufferLT}         // HVA CaL
            addmsg CaL12_channelGHK {bufferAll} I_Ca Ik
        end
        if ({gCaL13spine} > {SMALLNUMBER})
            addCaChannelspines CaL13_channel      .  {gCaL13spine}    {bufferLT}      // LVA CaL
            addmsg CaL13_channelGHK {bufferAll} I_Ca Ik
        end
        if ({gCaRspine} > {SMALLNUMBER})
            addCaChannelspines CaR_channel        .  {gCaRspine}      {bufferNR}
            addmsg CaR_channelGHK {bufferAll} I_Ca Ik
        end
        if ({gCaT32spine} > {SMALLNUMBER})
            addCaChannelspines CaT32_channel        .  {gCaT32spine}      {bufferLT}
            addmsg CaT32_channelGHK {bufferAll} I_Ca Ik
        end
        if ({gCaT33spine} > {SMALLNUMBER})
            addCaChannelspines CaT33_channel        .  {gCaT33spine}      {bufferLT}
            addmsg CaT33_channelGHK {bufferAll} I_Ca Ik
        end
        if ({gSKspine} > {SMALLNUMBER})
            addKCaChannelspines SK_channel        .  {gSKspine}      {bufferNR}
        end
     end

     pope

  end
  return {neckSlabs}
end
//******************done making spines*********************************

//*****************begin function to add spines*********************************

function compensate_for_spines(cellpath,parentlevel)
// This function compensates Rm and Cm for increased surface area when spines are explicitly added to the model. Compensation must be done for each spine and the parent dendritic compartment for any dendritic compartment containing spines
str cellpath, parentlevel
str compt, parent
    foreach compt ({el {cellpath}/#[TYPE={compartment}]})
     	 if (!{{compt}=={{cellpath}@"/axIS"} || {compt}=={{cellpath}@"/ax"}})
            if ({strcmp {parentlevel} soma}==0)
                parent = {cellpath}@"/soma"
            elif ({strcmp {parentlevel} primdend1}==0)
                parent = {getfield {compt} parentprim}
            elif ({strcmp {parentlevel} secdend11}==0)
                parent = {getfield {compt} parentsec}
            end
            //echo parent {parent} parentlevel {parentlevel}
            if ({{parent}=={{cellpath}@"/"@{parentlevel}}})
                float dia={getfield {compt} dia}
                float position={getfield {compt} position}
                float parentPathlen={getfield {compt} pathlen}
                float len={getfield {compt} len}
                float surfaceArea = PI*dia*len
                float singleSpineSurf = {{{dia_head}*{len_head}*{PI}} + {{dia_neck}*{len_neck}*{PI}}}
                float Cm_old = {getfield {compt} Cm}
                float Rm_old = {getfield {compt} Rm}
                if ({position>={spineStart}} && {position<{spineEnd}} ) //it's a compartment that would have spines
                    
                    int numspines = {{spineDensity} * {len} * 1e6}
                    //echo numspines= {numspines}
                    float totalSpineSurf = singleSpineSurf*numspines
                    setfield {compt} \
                        Cm  {{Cm_old}/{{{surfaceArea}+{totalSpineSurf}}/{surfaceArea}}} \
                        Rm  {{Rm_old}*{{{surfaceArea}+{totalSpineSurf}}/{surfaceArea}}}
                    //echo compensating {compt}  
                    //str subcompt
                    //foreach subcompt ({el {compt}/##[TYPE=compartment]})
                    //    float Cm_old = {getfield {subcompt} Cm}
                    //    float Rm_old = {getfield {subcompt} Rm}
                    //    setfield {subcompt} \
                    //        Cm  {{Cm_old}/{{{surfaceArea}+{totalSpineSurf}}/{surfaceArea}}} \
                    //        Rm  {{Rm_old}*{{{surfaceArea}+{totalSpineSurf}}/{surfaceArea}}}
                       // echo compensating {subcompt}
                    //end
                end
            end
        end
    end


end


function add_spines_evenly(cellpath,spineproto,a,b,density,bottomslab,parentlevel)
/* "spineproto"   :   spine prototype
** "density" :   1/um,  spine density; The number of spines in one compartment = density * compartment length. 
*/
// parentlevel specifies where to add spines: soma - adds to every branch; primdend1 - adds only to branches off of primdend1, etc
 str cellpath,compt,spineproto,spine,bottomslab
 int number,i
 float dia,len,a,b,density,position
 float separation,spineloc
 float parentPathlen, spinepath

 if(!{exists /library/{spineproto}})
    echo "The spine protomodel has not been made!"
    return
 end

 str bottomslabName={CalciumName}@{bottomslab}
 int totalspines=0
str parent
            
 foreach compt ({el {cellpath}/#[TYPE={compartment}]}) 
	 if (!{{compt}=={{cellpath}@"/axIS"} || {compt}=={{cellpath}@"/ax"}})
 
     dia={getfield {compt} dia}
     position={getfield {compt} position}
		 parentPathlen={getfield {compt} pathlen}
     len={getfield {compt} len}
		 float xstart={getfield {compt} x0}

    
  //if the compartment is not a spine ,
  // and its position is between [a,b]
			if ({position>=a} && {position<b} )
		         if ({strcmp {parentlevel} soma}==0)
                    parent = {cellpath}@"/soma"
                 elif ({strcmp {parentlevel} primdend1}==0)
                    parent = {getfield {compt} parentprim}
                 elif ({strcmp {parentlevel} secdend11}==0)
                    parent = {getfield {compt} parentsec}
                 end
            if ({{parent}=={{cellpath}@"/"@{parentlevel}}})
                number = density * len * 1e6

   // make sure that each compartment has at least one spine
				if (number == 0)
					number = number + 1
				end
				separation={len/number}

				for(i=1;i<=number;i=i+1)
					spine = "spine"@"_"@{i}
					totalspines=totalspines+1
					copy /library/{spineproto} {compt}/{spine}
          //assign position and pathlen to the spine, this is specific to our one dimensional morphology
					//The 2nd term of pathlen needs to be  changed if spineloc is changed for real morphology
					spineloc={separation/2}+{i-1}*{separation}+{xstart}
					spinepath=(parentPathlen-len/2)+(spineloc-xstart)
					setfield {compt}/{spine} position {spineloc}
					setfield {compt}/{spine}/{spcomp1} position {spineloc}
					setfield {compt}/{spine} pathlen {spinepath}
					setfield {compt}/{spine}/{spcomp1} pathlen {(parentPathlen-len/2)+(spineloc-xstart)}
					//parents of spine are same as parents of compartment
					setfield {compt}/{spine} parentprim {getfield {compt} parentprim}
					setfield {compt}/{spine}/{spcomp1} parentprim {getfield {compt} parentprim}
					setfield {compt}/{spine} parentsec {getfield {compt} parentsec}
					setfield {compt}/{spine}/{spcomp1} parentsec {getfield {compt} parentsec}
					setfield {compt}/{spine} parenttert {getfield {compt} parenttert}
					setfield {compt}/{spine}/{spcomp1} parenttert {getfield {compt} parenttert}
					//messages between spineneck and dendrite compartment
					addmsg {compt}/{spine} {compt} RAXIAL Ra Vm
					addmsg {compt} {compt}/{spine} AXIAL Vm
					if ({spinecalcium}==0)
	   //send calcium diffusion message from bottom shell of spine neck to outer shell of compartment
            addmsg {compt}/{spine}/{bottomslabName} {compt}/{upperShell} DIFF_DOWN prev_C thick
            addmsg {compt}/{upperShell} {compt}/{spine}/{bottomslabName} DIFF_UP prev_C thick
       //send buffer diffusion messages from bottom shell of spine neck to outer shell of compartement
            addmsg {compt}/{spine}/{bottomslabName}{bname2} {compt}/{upperShell}{bname2} DIFF_DOWN prev_free thick
            addmsg {compt}/{upperShell}{bname2} {compt}/{spine}/{bottomslabName}{bname2} DIFF_UP prev_free thick
            addmsg {compt}/{spine}/{bottomslabName}{bname4} {compt}/{upperShell}{bname4} DIFF_DOWN prev_free thick
            addmsg {compt}/{upperShell}{bname4} {compt}/{spine}/{bottomslabName}{bname4} DIFF_UP prev_free thick
            addmsg {compt}/{spine}/{bottomslabName}{bname1} {compt}/{upperShell}{bname1} DIFF_DOWN prev_free thick
            addmsg {compt}/{upperShell}{bname1} {compt}/{spine}/{bottomslabName}{bname1} DIFF_UP prev_free thick

            if ({calciumdye} > 0)
                addmsg {compt}/{spine}/{bottomslabName}{bnamefluor} {compt}/{upperShell}{bnamefluor}  DIFF_DOWN prev_free thick
                addmsg {compt}/{upperShell}{bnamefluor} {compt}/{spine}/{bottomslabName}{bnamefluor}  DIFF_UP prev_free thick
            end
					end	

        end //end of for i< number
        
        //// Loop to set up CONNECTCROSS MESSAGES Between child spines and child dendrites of current compartment
        /*int outmsgcount = {getmsg {compt} -outgoing -count}
        int i
	    for (i = 0; {i} < {outmsgcount}; i = {i} + 1)
            str msgtype = {getmsg {compt} -outgoing -type {i}}
            str child =   {getmsg {compt} -outgoing -destination {i}}
		    if ({strcmp {msgtype} "CONNECTHEAD"} == 0) //If the message is CONNECTHEAD We Want to connectcross this child (spine or dend) with every other spine-only child
                str subcompt
                foreach subcompt ({el {compt}/#[TYPE={compartment}]}) //This will get list of spine compartments
                if (!{strcmp {subcompt} {child}}==0)  //If the element we are crossconnecting is not itself
                    addmsg {child} {subcompt} CONNECTCROSS Ra Vm //This will add messages both ways for every spine-spine and msgs from dend-to-spine but not spine-to-dend
                    if (!{strncmp {getpath {child} -tail} "spine" 5} ==0) //child is dendrite (not spine), also add message: addmsg {subcompt} {child}
                        //echo adding connectcross message from {child} to {subcompt}
                        addmsg {subcompt} {child} CONNECTCROSS Ra Vm
                    end // if child is dendrite (not spine)
                end //if subcompt, child not identical
                end //foreach subcompt (spine)
            end //if message is connect tail
         end //for i = 0:outmsgcount*/
            
       end //end if parentprim is prim1
     end // end of if position...

   end // end of if ... axIS

 end // end of "foreach" loop

 compensate_for_spines {cellpath} {parentlevel}

 return totalspines
end
