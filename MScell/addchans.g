//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	      addchansNew.g 	*********************
	Avrama Blackwell 	kblackw1@gmu.edu
	Wonryull Koh		wkoh1@gmu.edu
	Rebekah Evans 		rcolema2@gmu.edu
	Sriram 				dsriraman@gmail.com		
******************************************************************************/
function connectKCachannel(compPath, caBufferName, channel)
  str compPath, channel
  str caBufferName

  if({isa difshell {compPath}/{caBufferName}}) 
    addmsg {compPath}/{caBufferName} {compPath}/{channel} CONCEN C
  elif({isa Ca_concen {compPath}/{caBufferName}})
   addmsg {compPath}/{caBufferName} {compPath}/{channel} CONCEN Ca
  end
end

function SumGk (compPath)  //called in MScellshort.g
	str compPath
	create diffamp {compPath}/GkSum
	setfield {compPath}/GkSum gain 1
	setfield {compPath}/GkSum saturation 100 

	addmsg {compPath}/KAf_channel {compPath}/GkSum PLUS Gk
	addmsg {compPath}/KAs_channel {compPath}/GkSum PLUS Gk
	addmsg {compPath}/Krp_channel {compPath}/GkSum PLUS Gk
	addmsg {compPath}/KIR_channel {compPath}/GkSum PLUS Gk
	addmsg {compPath}/BK_channel {compPath}/GkSum PLUS Gk 
	addmsg {compPath}/SK_channel {compPath}/GkSum PLUS Gk
end

function SumCa (compPath) //called in MScellshort.g
	str compPath
	create diffamp {compPath}/CaSum
	setfield {compPath}/CaSum gain 1
	setfield {compPath}/CaSum saturation 100

	addmsg {compPath}/CaR_channelGHK {compPath}/CaSum PLUS Gk
	addmsg {compPath}/CaL12_channelGHK {compPath}/CaSum PLUS Gk
	addmsg {compPath}/CaL13_channelGHK {compPath}/CaSum PLUS Gk
	addmsg {compPath}/CaT32_channelGHK {compPath}/CaSum PLUS Gk
	addmsg {compPath}/CaT33_channelGHK {compPath}/CaSum PLUS Gk
end

include MScell/connectCaChannels.g

//********************* Begin function add_uniform_channel ********************
//*****************************************************************************
function add_uniform_channel(obj, a, b,Gchan,cellpath, chantype )
	//************************ Begin Local Variables ***************************
 	str obj, compt, path, chantype
    str strhead, strhead3
 	float dia,len,surf,shell_vol,shell_thick, a,b,position,Gchan,PI,shell_dia,kb
 	float Ca_base = 5.0e-5  // mM
 	float Ca_tau            // second
 	float PI = 3.14159
    str caPool
	//************************ End Local Variables *****************************
	 
	//************************* Begin Warnings *********************************
 	if (!{exists /library/{obj}} )
  		echo the object {obj} has not been made (C) 
  	return
 	end

 	if (!{exists {cellpath}})
   	  echo the cell path {cellpath} does not exist! Please check it (add_uniform_channel)
        return
 	end

 	if (a>b)
   	  echo You set a WRONG boundary of a and b (E)
   	return
 	end
	//************************* End  Warnings ********************************** 
//these next lines are not needed for the "real" calcium dynamics, only for the ca_concen object 
 	strhead = {substring {obj} 0 0}     
		// we need the first letter of the name of the object
 	strhead3 = {substring {obj} 2 2}     
		// we need the third letter of the name of the object
 
	//********************* Begin foreach statement ****************************
	foreach compt ({el {cellpath}/##[TYPE={compartment}]})
		
		//************** Begin external if statement*****************************
	    if (!{{compt} == {{cellpath}@"/axIS"} || {compt} == {{cellpath}@"/ax"}}) 
    		   dia = {getfield {compt} dia}
    	 	   position = {getfield {compt} position} 
    		  		
    		//********* calculate surface area from diameter (above) and length  *************  
 		    if ({({dia} > 0.11e-6) && {position > a} && {position <= b} }) 
 				//if the compartment is not a spine ,and position between [a,b]
     		   len = {getfield {compt} len}
      		   surf = dia*{PI}*len
		/* add channels & make channels communicated w/parent dendrites */     
         	   copy /library/{obj} {compt}
         	   addmsg {compt} {compt}/{obj} VOLTAGE Vm
               float Gchantemp=Gchan
               if ({chantype} == "V")
         	        addmsg {compt}/{obj} {compt} CHANNEL Gk Ek
                    
               elif ({chantype} == "KC")
         	        addmsg {compt}/{obj} {compt} CHANNEL Gk Ek
                    if (calciumtype == 0)
                       caPool={CalciumName}@"1"
                    elif (calciumtype == 1)
                        if (strhead == "S")
                            caPool={bufferNR}
                        elif (strhead == "B")
                            caPool={bufferLT}
                        else
                            echo "addchans KC: unrecognized KCa channel:" {obj}
                        end
                    else
                        echo "addchans KC: unrecognized type of calcium dynamics"
                    end
          		    connectKCachannel {compt} {caPool} {obj}
         	   elif ({chantype}=="VC")
                    Gchantemp={Gchan}*{GHKluge}
                    if (calciumtype == 0)
                        caPool={CalciumName}@"1"
                        addCaChannel {obj} {compt} {caPool}
                    elif (calciumtype == 1)
                        if ((strhead == "C") && ((strhead3 == "N") || (strhead3 == "R")))
                            caPool={bufferNR}
                        elif ((strhead == "C") && ((strhead3 == "T") || (strhead3 == "L")))
                            caPool={bufferLT}
                        else
                            echo "addchans VC: unrecognized calcium channel" {obj}
                        end
                        addCaChannel {obj} {compt} {caPool}
                        //add all calcium channels provide input to the total calcium pool
                        addmsg {compt}/{obj}GHK {compt}/{bufferAll} I_Ca Ik
                    else
                        echo "addchans VC: unrecognized type of calcium dynamics"
                    end
               else
                    echo "unrecognized type of channel"
    		   end

     		   if ({isa tabchannel /library/{obj}} || {isa tab2Dchannel /library/{obj}})
                    setfield {compt}/{obj} Gbar {Gchantemp*surf}
       		   elif ({isa vdep_channel /library/{obj} })
                    setfield {compt}/{obj} gbar {Gchantemp*surf}
               elif ({isa leakage /library/{obj}})
                    setfield {compt}/{obj} Gk {Gchantemp*surf}
      		   end 

    		end	//******* End internal if statement***************** 
  		
  	   end	  //******* End external if statement****************

	end 	//******* End foreach statement *******************	
end 


