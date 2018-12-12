//genesis


/***************************		MS Model, Version 9.1	*********************
**************************** 	      graphics3.g 	*********************
	Avrama Blackwell 	kblackw1@gmu.edu
	Wonryull Koh		wkoh1@gmu.edu
	Rebekah Evans 		rcolema2@gmu.edu
	Sriram 				dsriraman@gmail.com	
******************************************************************************

*****************************************************************************/
/*
    create xform /PGform [200,100,600,700] -title "Pulse Generator"

    create xgraph /PGform/graph1 [10,260,580,200] -title  \
    "triggered mode (with delay)"
    setfield ^ ymin -0.1 ymax 1.2
    setfield ^ xmin 0 xmax 10 	

    addmsg {injectName}/bursttrigger /PGform/graph1 PLOT output *bursttrig *black
    addmsg {injectName}/traintrigger /PGform/graph1 PLOT output *traintrig *red 
    addmsg {injectName} /PGform/graph1 PLOTSCALE output *pulse *blue 0.5e9 0.1
    addmsg {precell}/spikegen /PGform/graph1 PLOT state *presyn *green 
     	
    xshow PGform
 
*/ 


/*********************** Begin Local Subroutines *****************************/
/*****************************************************************************/

	//************************ Begin function record_channel *******************
	function record_channel(compt,channel,xcell, color)
 		str compt,xcell,channel, color		
 		str path, graphic_path
                       
		path = {neuronname}@"/"@{compt}@"/"@{channel}
		if ({channel}=="Ca_difshell_1"||{channel}=="Ca_difshell_2"||	\
															{channel}=="Ca_difshell_3")
			if( {isa difshell {path}})
				addmsg {neuronname}/{compt}/{channel} 							\
										{xcell}/Ca PLOT C  *	{channel}  *{color}
			elif( {isa Ca_concen {path}})
				addmsg {neuronname}/{compt}/{channel} 							\
										{xcell}/Ca PLOT Ca *{compt}  *{color}
			end
		else 
			addmsg {neuronname}/{compt}/{channel} {xcell}/channels 			\
										PLOT Ik *{channel} *{color}
		end 
	end
	//************************ End function record_channel *********************
	//**************************************************************************

	//************************ Begin function record_channel *******************
	function record_voltage (compt, xcell,color)
 		str compt, xcell, color
 	
 		str path, spacer, graphic_path
 	
		spacer = "        "
		graphic_path = {compt}@{spacer}
    	addmsg {neuronname}/{compt} {xcell}/v PLOT Vm *{graphic_path} *{color}
	end
	//************************ End function record_channel *********************
	//**************************************************************************
	
	//************************ Begin function step_tmax ************************
/*
	function step_tmax
   	reset
   	setfield /cell/soma inject 0
   	step 5000
   	setfield /cell/soma inject {getfield /control/Injection value}
   	step 20000
   	setfield /cell/soma inject 0.0
	end
*/

	function step_tmax
   	reset
   	setfield /cell/soma inject 0
   	step 5000
   	setfield /cell/soma inject {getfield /control/Injection value}
   	step 1.0 -time
   	setfield /cell/soma inject 0.0
        step 5000
	end
	//************************ End function step_tmax **************************
	//**************************************************************************
	
	//************************ Begin function set_inject ***********************
	function set_inject(dialog)
    	str dialog
    	setfield /cell/soma inject {getfield {dialog} value}
	end
	//************************ End function set_inject *************************
	//**************************************************************************
	
	//************************ Begin function overlaytoggle ********************
	function overlaytoggle(widget)
    	str widget
    	setfield /##[TYPE=xgraph] overlay {getfield {widget} state}
	end
	//************************ End function overlaytoggle **********************
	//**************************************************************************
	
	//************************ Begin function add_overlay **********************
	function add_overlay
		create xtoggle /control/overlay   -script "overlaytoggle <widget>"
		setfield /control/overlay offlabel "Overlay OFF" onlabel "Overlay ON" \
																								state 0
	end
	//************************ End function add_overlay ************************
	//**************************************************************************

/*********************** End Local Subroutines *******************************/
/*****************************************************************************/


/*********************** Begin Externally Available Subroutines **************/
/*****************************************************************************/

	//************************ Begin function make_control *********************
	function make_control
    	create xform /control [1050,0,250,145]
    	create xlabel /control/label -hgeom 25 -bg cyan -label "CONTROL PANEL"
       
    	create xbutton /control/RESET -wgeom 33%       -script reset
    	create xbutton /control/RUN  -xgeom 0:RESET -ygeom 0:label -wgeom 33% \
         -script step_tmax
         
    	create xbutton /control/QUIT -xgeom 0:RUN -ygeom 0:label -wgeom 34% 	 \
      	-script quit
    	create xdialog /control/Injection -label "Inject Amps" 					 \
         -value 304.95e-12 -script "set_inject <widget>"
   
    	xshow /control
	end
	//************************ End function make_control ***********************
	//**************************************************************************

	//************************ Begin function make_graph ***********************	
	function make_graph (cellname)
		str cellname
		str xcell = "/data"	
		float tmax = 1.1
		float xmin = 0.01
					
		create xform  /data [0,0,1000,1000]
		create xlabel /data/label [10,0,95%,25] 							\
			-label " MSN Cell"  													\
      	-fg    red

		create xgraph /data/soma [10,10:label.bottom, 50%, 45%] 			\
      	-title "Membrane Potential in the Soma"  					\
      	-bg    white

		create xgraph /data/spineCa [10,10:soma.bottom,50%,45%] 	\
      	-title "calcium in dendrites"  										\
      	-bg    white 
	
		create xgraph /data/Ca [10:soma.right,10:label.bottom,50%,45%] \
      	-title "Calcium Concentration: " 			\
      	-bg    white
      
		create xgraph /data/spineVm											\
			[10:spineCa.right,10:Ca.bottom,48%,45%] 					\
      	-title "Fluorescence" 			\
      	-bg    white

		setfield /data/soma      		xmin {xmin} xmax {tmax+0.01}   	\
											ymin -0.1 ymax 0.05
		setfield /data/Ca     		xmin {xmin} xmax {tmax+0.01}   	\
											ymin 4.5e-5 ymax 7e-5
		setfield /data/spineCa 		xmax {tmax+0.8}  ymin 0 			\
											ymax 5.0e-12
		setfield /data/spineVm   	xmax {tmax+0.01}  ymin -1.2e-12 	\
											ymax 1.0e-13

  		useclock /data/v					 	1
  		useclock /data/Ca        			1 
  		useclock /data/channels  			1
		xshow /data
	
		reset

	//addmsg {cellname}/soma/Ca_difshell_6 /data/Ca PLOT C *Ca6 *blue
	//addmsg {cellname}/soma/Ca_difshell_5 /data/Ca PLOT C *Ca5 *pink
	//addmsg {cellname}/soma/Ca_difshell_4 /data/Ca PLOT C *Ca4 *green
	//addmsg {cellname}/soma/Ca_difshell_3 /data/Ca PLOT C *Ca3 *orange
	//addmsg {cellname}/soma/Ca_difshell_2 /data/Ca PLOT C *Ca2 *red
	//addmsg {cellname}/soma/Ca_difshell_1 /data/Ca PLOT C *Ca1soma *black
	
//addmsg {cellname}/tertdend1_1/Ca_difshell_1 /data/spineCa PLOT C *Ca1 *purple

	//addmsg {cellname}/soma/Ca_difshell_1 /data/spineVm PLOT C *somaCa1 *blue
	//addmsg {cellname}/primdend1/Ca_difshell_1 /data/spineVm PLOT C *primCa1 *red
	//addmsg {cellname}/secdend11/Ca_difshell_1 /data/spineVm PLOT C *secCa1 *black
	//addmsg {cellname}/tertdend1_1/Ca_difshell_1 /data/spineVm PLOT C *tertCa1 *orange
	
	//addmsg {cellname}/soma/Ca_difshell_1calbindin /data/spineCa PLOT Bfree *calbindin *black
	//addmsg {cellname}/soma/Ca_difshell_1CaMC /data/spineCa PLOT Bfree *CaM *red
	
	//addmsg {cellname}/soma/Ca_difshell_1calbindin /data/spineVm PLOT Bbound *calbindinbound *blue
	//addmsg {cellname}/soma/Ca_difshell_1CaMC /data/spineVm PLOT Bbound *CaMbound1 *green
	//addmsg {cellname}/soma/Ca_difshell_3CaMC /data/spineVm PLOT Bbound *CaMbound3 *blue
	//addmsg {cellname}/secdend1/Ca_difshell_1CaMC /data/spineVm PLOT Bbound *CaMbound1dend *black
	//addmsg {cellname}/soma/Ca_difshell_3CaMC /data/spineVm PLOT Bbound *CaMbound3dend *red
	
	//addmsg {cellname}/soma/BK_channel /data/Ca PLOT Gk *BK *pink
	//addmsg {cellname}/soma/SK_channel /data/Ca PLOT Gk *SK *purple
	
	//addmsg {cellname}/soma/KIR_channel /data/spineVm PLOT Gk *KIR *blue
	//addmsg {cellname}/soma/KIR_channel /data/spineVm PLOT Ik *KIR *blue
	
	//addmsg {cellname}/soma/KAf_channel /data/spineVm PLOT Gk *Kaf *black
	//addmsg {cellname}/soma/KAf_channel /data/spineVm PLOT Ik *Kaf *black
	
	//addmsg {cellname}/soma/KAs_channel /data/spineVm PLOT Gk *Kas *red
	//addmsg {cellname}/soma/KAs_channel /data/Ca PLOT Ik *Kas *red

	//addmsg {cellname}/soma/Krp_channel /data/Ca PLOT Gk *Krp *green
	//addmsg {cellname}/soma/NaF_channel /data/spineVm PLOT Gk *NaF *orange

	//addmsg {cellname}/soma/NaF_channel /data/spineVm PLOT Ik *NaF *green

	//addmsg {cellname}/tertdend1_1/NR2A/block /data/spineVm PLOT Gk *NMDAblock *red
	//addmsg {cellname}/tertdend1_1/NR2A/GHK /data/Ca PLOT Gk *NMDAghk *green
	//addmsg {cellname}/tertdend1_1/AMPA /data/spineVm PLOT Gk *AMPA *blue
	//addmsg {cellname}/tertdend1_1/GABA /data/spineVm PLOT Gk *GABA *black


	//addmsg {cellname}/secdend11/NR2A/block /data/spineVm PLOT Gk *NMDA *red
	//addmsg {cellname}/secdend11/AMPA /data/spineVm PLOT Gk *AMPA *blue

	//addmsg {cellname}/secdend11/BK_channel /data/Ca PLOT Ik *BKsec *red
	//addmsg {cellname}/soma/BK_channel /data/Ca PLOT Ik *BKsoma *black
	//addmsg {cellname}/tertdend1_1/BK_channel /data/Ca PLOT Ik *BKtert3 *blue
	//addmsg {cellname}/soma/SK_channel /data/spineVm PLOT Ik *SKsoma *green
	//addmsg {cellname}/tertdend1_1/SK_channel /data/Ca PLOT Ik *SKtert3 *purple
	//addmsg {cellname}/secdend11/SK_channel /data/spineVm PLOT Ik *SKsec *orange
	
	addmsg {cellname}/soma /data/soma PLOT Vm *somaVm *blue
	addmsg {cellname}/primdend1 /data/soma PLOT Vm *primVm *red
	addmsg {cellname}/secdend11 /data/soma PLOT Vm *secVm *black
	addmsg {cellname}/tertdend1_1 /data/soma PLOT Vm *tert1m *orange
	addmsg {cellname}/tertdend1_2 /data/soma PLOT Vm *tert2m *green
	addmsg {cellname}/tertdend1_3 /data/soma PLOT Vm *tert3m *purple
/*	
	addmsg {cellname}/primdend1 /data/soma PLOT Vm *primVm *red
	addmsg {cellname}/secdend11 /data/soma PLOT Vm *secVm *green
	addmsg {cellname}/tertdend1_1 /data/soma PLOT Vm *tertVm *black
	addmsg {cellname}/tertdend1_2 /data/soma PLOT Vm *tert2Vm *pink
	addmsg {cellname}/primdend3 /data/soma PLOT Vm *primVm *red
	addmsg {cellname}/secdend32 /data/soma PLOT Vm *secVm *green
	addmsg {cellname}/tertdend3_1 /data/soma PLOT Vm *tertVm *black
	addmsg {cellname}/tertdend3_2 /data/soma PLOT Vm *tert2Vm *pink
*/
	//addmsg {cellname}/soma/Fluo5FVavg /data/spineVm PLOT meanValue *somaF *blue
	//addmsg {cellname}/primdend1/Fluo5FVavg /data/spineVm PLOT meanValue *primF *red
	//addmsg {cellname}/secdend12/Fluo5FVavg /data/spineVm PLOT meanValue *secF *green
	//addmsg {cellname}/tertdend1_1/Fluo5FVavg /data/spineVm PLOT meanValue *tert1_1 *black
	//addmsg {cellname}/tertdend1_2/Fluo5FVavg /data/spineVm PLOT meanValue *tert1_2 *purple
	//addmsg {cellname}/tertdend5_1/Fluo5FVavg /data/spineVm PLOT meanValue *tert5_1 *orange	
	//addmsg {cellname}/tertdend9_1/Fluo5FVavg /data/spineVm PLOT meanValue *tert9_1 *pink

/*	
	addmsg {cellname}/tertdend1_1/NMDApool /data/spineCa PLOT Ca *NMDAF1_1 *black
	addmsg {cellname}/tertdend1_1/LVApool /data/spineCa PLOT Ca *LVA1_1 *gray
	addmsg {cellname}/tertdend1_1/HVApool /data/spineCa PLOT Ca *HVA1_1 *blue
	addmsg {cellname}/tertdend5_1/NMDApool /data/spineCa PLOT Ca *NMDAF5_1 *red
	addmsg {cellname}/tertdend5_1/LVApool /data/spineCa PLOT Ca *LVA5_1 *orange
	addmsg {cellname}/tertdend5_1/HVApool /data/spineCa PLOT Ca *HVA5_1 *green

	//addmsg {cellname}/soma/allpool /data/Ca PLOT Ca *allpoolsoma *blue
	//addmsg {cellname}/primdend1/allpool /data/Ca PLOT Ca *allpoolprim *red
	//addmsg {cellname}/secdend11/allpool /data/Ca PLOT Ca *allpoolsec *black
	//addmsg {cellname}/tertdend1_1/allpool /data/Ca PLOT Ca *allpooltert *orange
	
	addmsg {cellname}/tertdend1_1/allshell /data/Ca PLOT C *1_1 *red
	addmsg {cellname}/tertdend5_1/allshell /data/Ca PLOT C *5_1 *pink

*/	
	//addmsg {cellname}/tertdend1_1/volavg /data/spineCa PLOT meanValue *Volavg1_1 *black
	//addmsg {cellname}/tertdend5_1/volavg /data/spineCa PLOT meanValue *Volavg5_1 *green
	//addmsg {cellname}/tertdend9_1/volavg /data/spineCa PLOT meanValue *Volavg9_1 *red
	//addmsg {cellname}/tertdend13_1/volavg /data/spineCa PLOT meanValue *Volavg13_1 *blue
 	
	//addmsg {cellname}/tertdend1_1/Ca_difshell_1 /data/spineCa PLOT C *Cadifshell1 *cyan

	//addmsg {cellname}/tertdend1_1/allshellcalbindin /data/spineVm PLOT Bbound *1_1 *red
	//addmsg {cellname}/tertdend5_1/allshellcalbindin /data/spineVm PLOT Bbound *5_1 *pink
	

 	//addmsg {cellname}/soma/fluorescence /data/spineVm PLOT ratio *somaF *blue
	//addmsg {cellname}/primdend1/fluorescence /data/spineVm PLOT ratio *primF *red
	//addmsg {cellname}/secdend11/fluorescence /data/spineVm PLOT ratio *secF *black
	//addmsg {cellname}/tertdend1_1/fluorescence /data/spineVm PLOT ratio *tertF *orange
/*
	addmsg {cellname}/tertdend5_1/fluorescence /data/spineVm PLOT ratio *tertF5 *green
	addmsg {cellname}/tertdend9_1/fluorescence /data/spineVm PLOT ratio *tertF9 *red
	addmsg {cellname}/tertdend13_1/fluorescence /data/spineVm PLOT ratio *tertF13 *blue
	//addmsg {cellname}/tertdend1_2/fluorescence /data/spineVm PLOT ratio *tertF2 *purple	
	//addmsg {cellname}/tertdend1_3/fluorescence /data/spineVm PLOT ratio *tertF3 *pink	
	//addmsg {cellname}/tertdend1_5/fluorescence /data/spineVm PLOT ratio *tertF5 *orange	
	//addmsg {cellname}/tertdend1_9/fluorescence /data/spineVm PLOT ratio *tertF9 *magenta	
	
*/	
	//addmsg {cellname}/secdend1/Cortex/block	/data/Ca PLOT Ik *nmda *black
	addmsg {cellname}/soma/volavg /data/spineCa PLOT meanValue *somavolavg *blue
	addmsg {cellname}/primdend1/volavg /data/spineCa PLOT meanValue *primvolavg *red
	addmsg {cellname}/secdend11/volavg /data/spineCa PLOT meanValue *secvolavg *black
	addmsg {cellname}/tertdend1_1/volavg /data/spineCa PLOT meanValue *tert1volavg *orange
	addmsg {cellname}/tertdend1_2/volavg /data/spineCa PLOT meanValue *tert2volavg *green
	addmsg {cellname}/tertdend1_3/volavg /data/spineCa PLOT meanValue *tert3volavg *purple
	addmsg {cellname}/tertdend1_4/volavg /data/spineCa PLOT meanValue *tert4volavg *magenta

/*	
	addmsg {cellname}/soma/CaT_channelGHK /data/spineVm PLOT Gk *CaTghk *green
	addmsg {cellname}/soma/CaR_channelGHK /data/spineVm PLOT Gk *CaR *red
	addmsg {cellname}/soma/CaN_channelGHK /data/spineVm PLOT Gk *CaN *black
	addmsg {cellname}/soma/CaL12_channelGHK /data/spineVm PLOT Gk *12 *magenta
	addmsg {cellname}/soma/CaL13_channelGHK /data/spineVm PLOT Gk *13 *blue	
*/
	addmsg {cellname}/tertdend1_1/CaT_channelGHK /data/spineVm PLOT Gk *CaTghk *green
	addmsg {cellname}/tertdend1_1/CaR_channelGHK /data/spineVm PLOT Gk *CaR *red
	addmsg {cellname}/tertdend1_1/CaL12_channelGHK /data/spineVm PLOT Gk *12 *magenta
	addmsg {cellname}/tertdend1_1/CaL13_channelGHK /data/spineVm PLOT Gk *13 *blue	
/*
	addmsg {cellname}/tertdend1_1/KIR_channel /data/spineCa PLOT Gk *Kir *blue
	addmsg {cellname}/tertdend1_1/KAf_channel /data/spineCa PLOT Gk *KAf *green
	addmsg {cellname}/tertdend1_1/KAs_channel /data/spineCa PLOT Gk *KAs *black
	addmsg {cellname}/tertdend1_1/Krp_channel /data/spineCa PLOT Gk *Krp *purple
	addmsg {cellname}/tertdend1_1/SK_channel /data/spineCa PLOT Gk *SK *red
	addmsg {cellname}/tertdend1_1/BK_channel /data/spineCa PLOT Gk *BK *pink
	addmsg {cellname}/tertdend1_1/GkSum /data/spineCa PLOT output *GkSum *orange
*/
	//addmsg {cellname}/tertdend1_1/GkSum /data/Ca PLOT output *GkSum *orange
	//addmsg {cellname}/tertdend1_1/CaSum /data/Ca PLOT output *CaSum *orange

	//addmsg {cellname}/tertdend1_1/NaFd_channel /data/spineCa PLOT X *act *blue
	//addmsg {cellname}/tertdend1_1/NaFd_channel /data/spineCa PLOT Y *inact *red
	//addmsg {cellname}/tertdend1_1/NaFd_channel /data/spineCa PLOT Z *slowinact *orange

end

	//************************ End function make_graph *************************
	//**************************************************************************
	
/*********************** End Externally Available Subroutines ****************/
/*****************************************************************************/
function add_weight
     int ctr	
     str n_name="/cell"
        
	//create asc_file /output/Somaweight
        //create asc_file /output/Primweight
	//create asc_file /output/Secweight
	create asc_file /output/Tertweight

	//setfield /output/Somaweight   flush 1  leave_open 1 append 1 float_format %0.6g
        //setfield /output/Primweight  flush 1  leave_open 1 append 1 float_format %0.6g
        //setfield /output/Secweight  flush 1  leave_open 1 append 1 float_format %0.6g
	setfield /output/Tertweight   flush 1  leave_open 1 append 1 float_format %0.12g
        
	//useclock /output/Somaweight {CaOutDt}
        //useclock /output/Primweight {CaOutDt}
        //useclock /output/Secweight {CaOutDt}
	useclock /output/Tertweight {CaOutDt}

	//addmsg {n_name}/soma/AMPA /output/Somaweight SAVE synapse[0].weight  
        //addmsg {n_name}/primdend2/AMPA /output/Primweight  SAVE synapse[0].weight  
        //addmsg {n_name}/secdend11/AMPA /output/Secweight  SAVE synapse[0].weight 
	//addmsg {n_name}/tertdend1_1/AMPA /output/Tertweight  SAVE synapse[0].weight  

	//addmsg {n_name}/primdend2/spine_1/head/AMPA /output/Primweight  SAVE synapse[0].weight  
        //addmsg {n_name}/secdend11/spine_1/head/AMPA /output/Secweight  SAVE synapse[0].weight 
	addmsg {n_name}/tertdend1_3/spine_1/head/AMPA /output/Tertweight  SAVE synapse[0].weight 
	//addmsg {n_name}/tertdend1_3/AMPA /output/Tertweight  SAVE synapse[0].weight 
 
end
  



