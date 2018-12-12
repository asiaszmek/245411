//genesis
//CaDifshell.g

/***************************		MS Model, Version 12	*********************
	Avrama Blackwell 	kblackw1@gmu.edu
	Rebekah Evans 		rcolema2@gmu.edu
	Sriram 				dsriraman@gmail.com	
*****************************************************************************/

//old calcium concentration - single time constant of decay
function add_CaConcen (buffername, a, b, cellpath)
	str buffername,cellpath
    float a,b

    str compt
	float len,dia,position
    float Ca_tau,kb   		
	float PI = 3.14159
    float shell_thick={outershell_thickness}

	foreach compt ({el {cellpath}/##[TYPE={compartment}]})
		//make sure this is not an axon, and determine length and diameter
 		  if (!{{compt} == {{cellpath}@"/axIS"} || {compt} == {{cellpath}@"/ax"}}) 
    		dia = {getfield {compt} dia}
    		position = {getfield {compt} position}
     		len = {getfield {compt} len}
    	end


  			//if the compartment is not a spine and its position is between [a,b] 
   		if ({position >= a} && {position < b} ) 
     			// Sabatini's model. Sabatini, 2001,2004
      		create Ca_concen  {compt}/{buffername}  // create Ca_pool here!
      		if({dia} < 0.81e-6)        // this is tertiary dendrites
            		kb = 96
      		elif (dia < 1.5e-6)        // secondary dendrites
            		kb = 96
      		elif (dia < 1.8e-6)        // primary dendrites
            		kb = 96
            else                       // soma 
                kb = 200             	// the setting for soma is arbitrary
            end

            if({dia}	<	15e-6)
   				Ca_tau = 25e-3
            else 
      			Ca_tau = 100e-3       	// adhoc setting to fit the model
            end  
                
   			// set Ca_tau  according to diameters of dendrites
            if ({shell_thick} > 0)
                float  inner_dia = dia - shell_thick*2
            else
                float inner_dia = 0
            end
            float  shell_vol= {PI}*(dia*dia/4-inner_dia*inner_dia/4)*len
            float surf = dia*{PI}*dia
            if ({dia}>= 15e-6)
                echo {compt} "shell vol,len,dia=" {shell_vol} {len} "dia=" {dia} "SA=" {surf}
            end
		
            setfield {compt}/{buffername} \
               B          {1.0/(2.0*96494*shell_vol*(1+kb))}	\ 
               tau        {Ca_tau}                        		\  
               Ca_base    {Ca_basal}   									\
               thick      {shell_thick}  
        end
    end
end

//new calcium concentration - various buffers, pumps and diffusion
function create_difshell (shellName, basal, compLen, r, shellThickness, mode)
	str shellName
	float basal
	float compLen
	float r, shellThickness
    str mode

	create difshell {shellName}
	setfield {shellName}	\
		C    {basal}	\
        Ceq  {basal}	\
        D    {dca}	\ //D_Ca = 2e-6 (cm^2)(s^(-1))
        val  2	\
        leak 0	\
        shape_mode {mode}	\ 
        len {compLen}	\
        dia {r*2}	\	//outer diameter of the shell
        thick {shellThickness}
end

function add_difbuffer_to_difshell (shellName, bname, btotal, kf, kb, d, compLen, r, shellThickness, mode)
	str shellName, bname
	float btotal, kf, kb, d, compLen, r
    str mode

	create difbuffer {shellName}{bname}

    setfield {shellName}{bname}	\
		Btot {btotal}	\
        kBf {kf} \
        kBb {kb} \
        D {d} \
        shape_mode {mode} \
        len {compLen} \
        dia {r*2} \
        thick {shellThickness}

    addmsg {shellName}{bname} {shellName} BUFFER kBf kBb Bfree Bbound
    addmsg {shellName} {shellName}{bname} CONCEN C 
end

function add_mmpump (shellName, surfaceArea, kcat, km, pname)
	str shellName
	float surfaceArea, kcat, km
	str pname
	
	create mmpump {shellName}{pname}
	setfield {shellName}{pname}	\
        vmax {kcat*surfaceArea}	\ 
		val {2}	\	
        Kd {km}
   	addmsg {shellName}{pname} {shellName} MMPUMP vmax Kd
    addmsg {shellName} {shellName}{pname} CONCEN C
end

function make_fura (compt, totalshells, bufname, calname)
	str compt
	str calname
	str bufname
	int totalshells, i
	create fura2 {compt}/{bnamefluor}
	i=1
	while (i < totalshells+1)
		str bnx = {calname} @ {i}
		//str bn = {bnx}{bufname}
		addmsg {compt}/{bnx}{bufname} {compt}/{bnamefluor} CONCEN Bfree Bbound vol
		i=i+1
	end 
end

function make_volavg (compt, totalshells, calname)
	str compt
	str calname
	int totalshells, i
	create wgtavg {compt}/volavg
	i=1
	while (i < totalshells+1)
		str bnx = {calname} @ {i}
		addmsg {compt}/{bnx} {compt}/volavg ValueWgt C vol
		i=i+1	
	end
end

function make_buffervolavg (compt, totalshells, calname, buffer)
	str compt
	str calname
	str buffer
	int totalshells, i
	create wgtavg {compt}/{buffer}Vavg
	i=1
	while (i < totalshells+1)
		str bnx = {calname} @ {i}
		addmsg {compt}/{bnx}{buffer} {compt}/{buffer}Vavg ValueWgt Bbound vol
		i=i+1	
	end
end


function add_caconcen_objects (calName, CELLPATH)
	str calName, CELLPATH
	str outermostShellName = {calName} @ 1
	str compt 
	int totalshells
	float thickness, totalthick, remaining

	foreach compt ({el {CELLPATH}/##[TYPE={compartment}]})
        float dia={getfield {compt} dia}
        float rad = 0.5*{dia}
        float len = {getfield {compt} len}
        int numShells = 0 //initialize numShells at 0

//**********calculate how many shells are needed from the diameter and thickness
        int i
        totalthick=outershell_thickness
        remaining=rad
        for (i = 1; remaining>minthick; i=i+1)
               remaining=rad-totalthick
               totalthick=totalthick+outershell_thickness*thicknessincrease**i
               //echo "shells="{i}, "remaining" {remaining}
        end
        totalshells=i-1
        if (({substring {compt} 6 9} != "tert") || ({compt}=="/cell/tertdend1_1"))
            echo {compt} "radius=" {rad} ", totalshells=" {totalshells}
        end

//make shells and buffers using the number of shells calculated above. 
        float shellRadius = {rad} 
        thickness=outershell_thickness
        for (i=1; i<= totalshells; i=i+1)
			str shellname = {calName} @ {i}
			create_difshell {compt}/{shellname} {Ca_basal} {len} {shellRadius} {thickness} {SHELL} 
			add_difbuffer_to_difshell {compt}/{shellname} {bname1} {btotal1} {kf1} {kb1} {d1} {len} {shellRadius} {thickness} {SHELL}
			add_difbuffer_to_difshell {compt}/{shellname} {bname2} {btotal2} {kf2} {kb2} {d2} {len} {shellRadius} {thickness} {SHELL} 
			add_difbuffer_to_difshell {compt}/{shellname} {bname4} {btotal4} {kf4} {kb4} {d4} {len} {shellRadius} {thickness} {SHELL}
            add_difbuffer_to_difshell {compt}/{shellname} {bname8} {btotal8} {kf8} {kb8} {d8} {len} {shellRadius} {thickness} {SHELL}

            if (calciumdye>0)
                add_difbuffer_to_difshell {compt}/{shellname} {bnamefluor} {btotalfluor} {kffluor} {kbfluor} {dfluor} {len} {shellRadius} {thickness} {SHELL} 
            end
			shellRadius = shellRadius-thickness
            if (i==totalshells-1)
                thickness=shellRadius
            else
                thickness=thickness*thicknessincrease
			end
		end
        reset > reset.txt //reset to set sa and vol for correct diffusion messages.

		if (calciumdye == 1)
		   //add fura object to each compartment to calc fluorescence
			make_fura {compt} {totalshells} {bnamefluor} {calName}
		elif (calciumdye > 1)
		   //add wgtavg object for bound single wavelength indicator dye 
			make_buffervolavg {compt} {totalshells} {calName} {bnamefluor}
		end

		//add wgtavg object to calculated Ca concentration without dyes
		make_volavg {compt} {totalshells} {calName}
		
		//diffusion between calcium and diffusible buffer shells
			for (i=1; i < totalshells; i=i+1)
				str sn = {calName} @ {i} 
				str innerSn = {calName} @ {i+1}
                //echo "shell=" {compt}/{sn} "SA=" {getfield {compt}/{sn} surf_up}
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
			end	

			//pump @ outershell
			float surfaceArea = {getfield {compt}/{outermostShellName} surf_up}
			//echo "shell=" {compt}/{outermostShellName}
			//showfield {compt}/{outermostShellName} *
			if ({compt} == "/cell/soma")
                float kcat=kcatsoma
            else
                float kcat=kcatdend
            end

			add_mmpump {compt}/{outermostShellName} {surfaceArea} {kcat} {km} {MMpumpName}
            float CaBase = {getfield {compt}/{outermostShellName} Ceq}
            float vmax = kcat*surfaceArea
            float vol = {getfield {compt}/{outermostShellName} vol}
            float leak = {{{vmax*CaBase}/{vol*{CaBase + km}}}}// {{kcat*CaBase}/{outershell_thickness*{CaBase + km}}} 
            setfield {compt}/{outermostShellName} leak {leak}
            //echo "mmpump" {compt} "kcat="{kcatsoma} "leak ="{leak}
	end
end

