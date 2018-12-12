//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	  		connectCaChannels.g		*********************

******************************************************************************
******************************************************************************/

function coupleCaPoolCaChannel(bufferName, compPath, caChannelName)

  str bufferName
  str compPath
  str caChannelName

  pushe {compPath}

  if({isa difshell {compPath}/{bufferName}})
    addmsg {caChannelName}GHK {bufferName} INFLUX Ik 
    addmsg {bufferName} {caChannelName}GHK CIN C
    if (calciuminact == 1)
        addmsg {bufferName} {caChannelName} CONCEN C
    end
  elif({isa Ca_concen {compPath}/{bufferName}})
    addmsg {caChannelName}GHK {bufferName} I_Ca Ik 
    addmsg {bufferName} {caChannelName}GHK CIN Ca 
    if (calciuminact == 1)
        addmsg {bufferName} {caChannelName} CONCEN Ca
    end
  else 
    echo "coupleCaPoolCaChannel: Whoops" {compPath}/{bufferName} "not found"
  end

  pope {compPath}

end


function addCaChannel(channelName, compPath, caBufferName)

  str channelName, compPath
  str caBufferName

  pushe {compPath}

    // Copy the GHK part of the channel from library
    copy /library/{channelName}GHK {channelName}GHK

    coupleCaPoolCaChannel {caBufferName} {compPath} {channelName}

    // Couple channel, its GHK object and compartment together
    addmsg {compPath} {channelName}GHK VOLTAGE Vm
    addmsg {channelName}GHK {compPath} CHANNEL Gk Ek
    addmsg {channelName} {channelName}GHK PERMEABILITY Gk

  pope

end

