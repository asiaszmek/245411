//genesis
//AddSynapticChannels.g

/***************************		MS Model, Version 12	******************
******************************************************************************/

function addSynChannel (compPath, chanpath, gbar, caBuffer)

  str compPath, chanpath, caBuffer
  float gbar

    //echo "addSynChannel, compPath = "{compPath} "chanpath = "{chanpath} "gbar = "{gbar}

  copy /library/{chanpath} {compPath}/{chanpath}
  addmsg {compPath} {compPath}/{chanpath} VOLTAGE Vm
  
  //if the channel is NOT NMDA, add channel msg from channel to compt.
  // Otherwise, if NMDA, do not add channel msg to compt here, it is added in the addNMDAchannel function below:
  if ({chanpath} != {NMDAname})
    addmsg {compPath}/{chanpath} {compPath} CHANNEL Gk Ek
    //echo "addSynChannel, chanpath = "{chanpath} "Is not an NMDA channel, adding channel msg directly to spine head"
  //else
    //echo "chanpath = " {chanpath} " is an NMDA channel, no direct msg to compt (must be sent to Mg block, then spine head)"
  end

  if ({isa caplas_synchan /library/{chanpath}})

    echo {chanpath} "is a caplas_synchan, sensing calcium from " {compPath}/{caBuffer}

    if ({isa difshell  {compPath}/{caBuffer}})         // dif_shell
        addmsg {compPath}/{caBuffer} {compPath}/{chanpath} CALCIUM C
    elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
        addmsg {compPath}/{caBuffer} {compPath}/{chanpath} CALCIUM Ca
    end

  elif ({isa caplas_des_synchan /library/{chanpath}})

    echo {chanpath} "is a caplas_des_synchan, sensing calcium from " {compPath}/{caBuffer}

    if ({isa difshell  {compPath}/{caBuffer}})         // dif_shell
        addmsg {compPath}/{caBuffer} {compPath}/{chanpath} CALCIUM C
    elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
        addmsg {compPath}/{caBuffer} {compPath}/{chanpath} CALCIUM Ca
    end
  elif ({isa caplas_tm_synchan /library/{chanpath}})

    echo {chanpath} "is a caplas_tm_synchan, sensing calcium from " {compPath}/{caBuffer}

    if ({isa difshell  {compPath}/{caBuffer}})         // dif_shell
        addmsg {compPath}/{caBuffer} {compPath}/{chanpath} CALCIUM C
    elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
        addmsg {compPath}/{caBuffer} {compPath}/{chanpath} CALCIUM Ca
    end
  end

  // Set the new conductance
  float len = {getfield {compPath} len}
  float dia = {getfield {compPath} dia}
  float surf = {len*dia*PI}

  setfield {compPath}/{chanpath} gmax {gbar}
//  setfield {compPath}/{chanName} gmax {surf*gbar}
 
  if ({chanpath} == "AMPA" && {AMPACaper}>0)
	if ({isa difshell {compPath}/{caBuffer}}) 
		//echo spine calcium model is difshell
		addmsg {compPath}/{chanpath} {compPath}/{caBuffer} FINFLUX Ik {AMPACaper}
	end
  end
end
 
function addNMDAchannel(compPath, chanpath,caBuffer, gbar, ghk, nmdacdi)

  str compPath, chanpath
  float gbar
  str caBuffer
  int ghk
  int nmdacdi
//copy the channel into the compartment and set the conductance
  addSynChannel {compPath} {chanpath} {gbar}

//next connect the mgblock
  addmsg {compPath}/{chanpath}/block {compPath} CHANNEL Gk Ek
  addmsg {compPath} {compPath}/{chanpath}/block VOLTAGE Vm

//while the block object always controls the voltage, either the block object or the ghk object controls the calcium. 
//ghk_yesno set in SynParams.g
// adds NMDA to Ca buffer in difshell or concen 
	if (ghk==0)
		if ({isa difshell  {compPath}/{caBuffer}} )         // dif_shell 
	 		addmsg {compPath}/{chanpath}/block {compPath}/{caBuffer} FINFLUX Ik {NMDAperCa}
		elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
			addmsg {compPath}/{chanpath}/block {compPath}/{caBuffer} fI_Ca Ik {NMDAperCa}
        end
	elif (ghk==1)
        float new_NMDAperCa = NMDAperCa/2.
        addmsg {compPath} {compPath}/{chanpath}/GHK VOLTAGE Vm
		if ({isa difshell  {compPath}/{caBuffer}})         // dif_shell
	 		addmsg {compPath}/{chanpath}/GHK {compPath}/{caBuffer} FINFLUX Ik {new_NMDAperCa}
			addmsg {compPath}/{caBuffer} {compPath}/{chanpath}/GHK CIN C
		elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
			addmsg {compPath}/{chanpath}/GHK {compPath}/{caBuffer} fI_Ca Ik {new_NMDAperCa}   
			addmsg {compPath}/{caBuffer} {compPath}/{chanpath}/GHK CIN Ca
        end
    end

    // If NMDA_CDI is implemented, then the cdi-gate needs calcium from the compartment (and maybe voltage to work correctly)
    if (nmdacdi==1)
        addmsg {compPath} {compPath}/{chanpath}/NMDA_CDI_gate VOLTAGE Vm
		if ({isa difshell  {compPath}/{caBuffer}})         // dif_shell
			addmsg {compPath}/{caBuffer} {compPath}/{chanpath}/NMDA_CDI_gate CONCEN C
		elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
			addmsg {compPath}/{caBuffer} {compPath}/{chanpath}/NMDA_CDI_gate CONCEN Ca
        end
    end
    //echo "addNMDAchannel, caBuffer = "{caBuffer}
end

