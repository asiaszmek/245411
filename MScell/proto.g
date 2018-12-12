//genesis


/***************************		MS Model, Version 9.1	*********************
**************************** 	      proto.g 	*********************
	Avrama Blackwell 	kblackw1@gmu.edu
	Wonryull Koh		wkoh1@gmu.edu
	Rebekah Evans 		rcolema2@gmu.edu
	Sriram 				dsriraman@gmail.com	
******************************************************************************

************************************************************************************************************************************************************
	proto.g is called by MScell.g
	it contains one primary routine:  
		make_prototypes
 	and two local routines 
		make_cylind_compartment
		make_spines - this one needs much work
	these are used by the primary and are not intended for external calls
	The primary function, make_prototypes is called exactly once by MSsim.g

******************************************************************************/

include MScell/include_channels.g		// required for calls in make_protypes

//************************ Begin Local Subroutines ****************************

	//********************* Begin function make_cylind_compartment *************
	function make_cylind_compartment
		if (!{exists {compartment}})
			echo "COMPARTMENT DID NOT EXIST PRIOR TO CALL TO:"
			echo 			"make_cylind_compartment"
			create	{compartment} {compartment}
		end

   	addfield {compartment} position   // Euclidean distance to soma
		addfield {compartment} pathlen    // path length to soma, = position for prototype .p file
		addfield {compartment} parentprim
		addfield {compartment} parentsec
		addfield {compartment} parenttert

		setfield {compartment} 		\ 
     	      Em        {ELEAK} 	\
            initVm    {EREST_ACT} 	\
            inject		0.0 	\
      	    position   0.0
	end
	//************************ End function make_cylind_compartment ************
/*Also, addfields: primparent, secparent, tertparent, and modify below
 * to determine those parents while traversing the tree 
*/
function setAxialPathLength(compt, parent_pathlen, parent_complen)
	str compt
	float parent_pathlen, parent_complen
	float complen = {{getfield {compt} len}/2}
	setfield {compt} pathlen {{parent_pathlen} + {parent_complen} + {complen}}
	int outmsgcount = {getmsg {compt} -outgoing -count}
	//echo {compt}  " "  {getfield {compt} pathlen} {outmsgcount} {getfield {compt} parentprim} {getfield {compt} parentsec} 
	int i,newparent,needsec=0,needtert=0
	for (i = 0; {i} < {outmsgcount}; i = {i} + 1)
		str msgtype = {getmsg {compt} -outgoing -type {i}}
		//determine whether present compt has a branch point
		if ({outmsgcount}>2)
			newparent=1
			//determine whether this is a secondary or tertiary branch
			if ({strlen {getfield {compt} parentsec}} ==0)
				needsec=1
			else
				needtert=1
			end
			//echo "branch" {compt} "needsec" {needsec} "needtert" {needtert} "parentsec" {getfield {compt} parentsec}
		else
			newparent=0
		end
		if ({strcmp {msgtype} "AXIAL"} == 0) 
			str child = {getmsg {compt} -outgoing -destination {i}}
			setfield {child} parentprim {getfield {compt} parentprim}
			if ({newparent} && {needsec})
				setfield {child} parentsec {child}
			elif ({newparent} && {needtert})
				setfield {child} parenttert {child} parentsec {getfield {compt} parentsec} 
			else
				setfield {child} parentsec {getfield {compt} parentsec} parenttert {getfield {compt} parenttert}
			end
			setAxialPathLength {child} {getfield {compt} pathlen} {complen}
		end	               
	end
end
	
function set_pathlen(CELLPATH, comp)
  str CELLPATH, comp

 	str  compt={CELLPATH}@{comp}
	setfield {compt} pathlen {0}	
	float complen = {{getfield {compt} len}/2}
	int outmsgcount = {getmsg {compt} -outgoing -count}
	int i, level
	for (i = 0; {i} < {outmsgcount}; i = {i} + 1)
		str msgtype = {getmsg {compt} -outgoing -type {i}}
		str child = {getmsg {compt} -outgoing -destination {i}}
		if ({strcmp {msgtype} "AXIAL"} == 0) 
			setfield {child} parentprim {child}
			setAxialPathLength {child} {getfield {compt} pathlen} {complen} 
		end		
	end
end

//************************ End Local Subroutines ******************************

//************** Begin function make_prototypes (primary routine) *************
function make_prototypes

  	create neutral /library
  	disable /library
	pushe /library

    make_cylind_compartment

	//********************* create non-synaptic channels in library ************************
       //voltage dependent Na and K channels
	//make functions are in their resepective channel .g files
 	make_NaF_channel	
	make_NaFd_channel
	make_KAf_channel		
	make_KAs_channel	
	make_KIR_channel	
	make_Krp_channel  

       //voltage dependent Ca channels
 	create_CaL12 
	create_CaL13	
	create_CaN
	create_CaR
 	create_CaT32
    create_CaT33

       //Ca dependent K channels
	make_BK_channel
	make_SK_channel
    if ({GABAtonic})
        make_tonic_GABA
    end
	//********************* End channels in library ************************

end
//************************ End function make_prototypes ***********************



