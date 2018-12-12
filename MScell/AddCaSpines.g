 //genesis
//AddCaSpines.g

//Two functions to add calcium (both shells and channels) to spines 
function add_difshell_spine (calname, type, dia, len, numslabs,thickness_increase)
	str calname
	str type
	float dia
	float len
	float r = 0.5*{dia}
    int numslabs, i
    str slabname
    float thickness
		
//Need to add pumps to sides of compartments
	if (type == "head")
        thickness={PSD_thick}
		str compt = "spine/"@{spcomp1}		
	elif (type == "neck")
		thickness = {len}/{numslabs}
        str compt="spine"
	else 
		echo = "oh my god, what did you do???"
	end

//add the difshells and difbuffers
    for (i = 1; i<=numslabs; i=i+1)
        slabname={calname} @ {i}
        create_difshell {compt}/{slabname} {Ca_basal} {thickness} {r} {thickness} {SLAB}
        add_difbuffer_to_difshell {compt}/{slabname} {bname1} {btotal1} {kf1} {kb1} {d1} {thickness} {r} {thickness} {SLAB}	
        add_difbuffer_to_difshell {compt}/{slabname} {bname2} {btotal2} {kf2} {kb2} {d2} {thickness} {r} {thickness} {SLAB}
        add_difbuffer_to_difshell {compt}/{slabname} {bname4} {btotal4} {kf4} {kb4} {d4} {thickness} {r} {thickness} {SLAB}
        add_difbuffer_to_difshell {compt}/{slabname} {bname8} {btotal8} {kf8} {kb8} {d8} {thickness} {r} {thickness} {SLAB}

        if (calciumdye>0)
            add_difbuffer_to_difshell {compt}/{slabname} {bnamefluor} {btotalfluor} {kffluor} {kbfluor} {dfluor} {thickness} {r} {thickness} {SLAB}
        end
        thickness=thickness*thickness_increase
    end
	
    if  (type == "head")
        if (calciumdye==1)
         //add fura object 
           make_fura {compt} {numslabs} {bnamefluor} {calname}
        elif (calciumdye > 1)
            //add wgtavg object for bound single wavelength indicator dye 
            make_buffervolavg {compt} {numslabs} {calname} {bnamefluor}
        end

     //add wgtavg object to calculated Ca concentration without dyes
        make_volavg {compt} {numslabs} {calname}

    end
    reset

	//diffusion between shells
    for (i = 1; i<numslabs; i=i+1)
		str sn = {calname} @ {i} 
		str innerSn = {calname} @ {i+1}
		addmsg {compt}/{sn} {compt}/{innerSn} DIFF_DOWN prev_C thick
		addmsg {compt}/{innerSn} {compt}/{sn} DIFF_UP prev_C thick
		addmsg {compt}/{sn}{bname2} {compt}/{innerSn}{bname2} DIFF_DOWN prev_free thick
		addmsg {compt}/{innerSn}{bname2} {compt}/{sn}{bname2} DIFF_UP prev_free thick
		addmsg {compt}/{sn}{bname4} {compt}/{innerSn}{bname4} DIFF_DOWN prev_free thick
		addmsg {compt}/{innerSn}{bname4} {compt}/{sn}{bname4} DIFF_UP prev_free thick
		addmsg {compt}/{sn}{bname1} {compt}/{innerSn}{bname1} DIFF_DOWN prev_free thick
		addmsg {compt}/{innerSn}{bname1} {compt}/{sn}{bname1} DIFF_UP prev_free thick

        if (calciumdye>0)
            addmsg {compt}/{sn}{bnamefluor} {compt}/{innerSn}{bnamefluor} DIFF_DOWN prev_free thick
            addmsg {compt}/{innerSn}{bnamefluor} {compt}/{sn}{bnamefluor} DIFF_UP prev_free thick
        end

        //parameters needed to computer pump parameters
		float complen = {getfield {compt}/{sn} len} 
		float compdia = {getfield {compt}/{sn} dia} 
        float SAside = {PI}*{dia}*{len}
        float CaBase = {getfield {compt}/{sn} Ceq}
        float vol = {getfield {compt}/{sn} vol}

        //include top surface are for PSD shell of spine head
        if (i==1 && type == "head")
            float surfaceArea = {getfield {compt}/{sn} surf_up} + {SAside}
            echo "Add pump to PSD!!" {compt}/{sn} "SA: " {surfaceArea}
            int addncx=0
        else
            float surfaceArea = {SAside}
            echo "Add pump to " {compt}/{sn} "SA: " {surfaceArea}
            int addncx=1
        end

        add_mmpump {compt}/{sn} {surfaceArea} {kcatSpine} {km} {MMpumpName}

        float leak = {{kcatSpine*surfaceArea*CaBase}/{vol*{CaBase + km}}} 
        setfield {compt}/{sn} leak {leak}

        //optionally add second pump - ncx - to spine
        if (({addncx}==1) && ({kcatSpineNCX}>0))
			add_mmpump {compt}/{sn} {surfaceArea} {kcatSpineNCX} {kmNCX} {NCXname}
			float leak2 = {{kcatSpineNCX*surfaceArea*CaBase}/{vol*{CaBase + kmNCX}}} 
			setfield {compt}/{sn} leak {leak+leak2}
			//add_taupump {compt}/{sn} {dia/4.0/tpump_kP}
		end
 	end

    return {i}
end


function addCaChannelspines(channelName, compPath, conductance, caBufferName)
  str channelName, compPath
  float conductance
  str caBufferName

  pushe {compPath}

    // Copy the channel from library
    copy /library/{channelName} {channelName}
    copy /library/{channelName}GHK {channelName}GHK

    // Set the new conductance
    float len = {getfield {compPath} len}
    float dia = {getfield {compPath} dia}
    float surf = {len*dia*PI} 

    echo "addCaChannelspines: "{channelName}", cond: "{conductance*GHKluge} ", Comp: "{compPath} ", SA: " {surf}

    setfield {channelName} Gbar {conductance*surf*GHKluge}

 	coupleCaPoolCaChannel {caBufferName} {compPath} {channelName}


    // Couple channel, its GHK object and compartment together
    addmsg {compPath} {channelName}GHK VOLTAGE Vm
    addmsg {compPath} {channelName} VOLTAGE Vm
    addmsg {channelName}GHK {compPath} CHANNEL Gk Ek
    addmsg {channelName} {channelName}GHK PERMEABILITY Gk

//     float len = {getfield {compPath} len}
//     float dia = {getfield {compPath} dia}
//     float pi = 3.141592653589793
//     float surf = {len*dia*pi}

//     // echo "conductance (unscaled): "{conductance}
//     // echo "Compartment: "{compPath}" surface area "{surf}"m²"
//     setfield {channelName} Gbar {conductance*surf}

  pope

end

function addKCaChannelspines(channelName, compPath, conductance, caBufferName)

    str channelName, compPath
    float conductance
    str caBufferName

    pushe {compPath}


 // Copy the channel from library
    copy /library/{channelName} {channelName}
   
  // Set the new conductance
    float len = {getfield {compPath} len}
    float dia = {getfield {compPath} dia}
    float surf = {len*dia*PI} 

    echo "addKCaChannelspines: "{channelName}", cond: "{conductance} ", Comp: "{compPath} ", SA: " {surf}

    setfield {channelName} Gbar {conductance*surf}
    addmsg {compPath} {channelName} VOLTAGE Vm
    addmsg {channelName} {compPath} CHANNEL Gk Ek
    
    connectKCachannel {compPath} {caBufferName} {channelName}
 
    pope
end
