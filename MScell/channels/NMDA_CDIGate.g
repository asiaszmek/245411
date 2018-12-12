//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	      NMDA_CDIGate.g 	*********************

******************************************************************************

*****************************************************************************/

		// This is an implementation of a CDI gate for the NMDA receptor.
		// CDI model reference: Farinella et a. 2014 Plos Comp Bio.
		// Steady-State: exp(-8*[Ca]) where [Ca] is internal calcium concentration (mM)
        // Tau: 1000 ms.
        // This is a hack to use a calcium-dependent channel gate to implement NMDAR_CDI.
        // This object will not contribute any conductance to a compartment, rather, it
        // will be set up only to pass its GK (equivalent to its Z gate value) value as
        // a message to the MOD field of the NMDA channel object


function make_NMDA_CDI_gate(chanpath)

  	int nStep = 2000
  	float nmdacdi = 1.0
  	float CaMax = 0.1 // 100 uM
	float CaMin = 0 
  	float delta = (CaMax - CaMin)/nStep  

    float nmdacdi_fact = 8.0
    float tau = 1.0 //1 second
	int i
   	float Ca = 0.0
    		
  	str chanpath 
  	
  	//pushe /library

  	//if (({exists {chanpath}}))
    //	return
  	//end

  	create  tabchannel {chanpath}
  	setfield	^		Ek  		{0e-3}		\
					Gbar		1		\  //Gbar=1 so GK will be value of Zgate
					Ik			0			\
					Gk			0			\
					Xpower  	0			\
					Ypower  	0			\
					Zpower  	1			

  	call {chanpath} TABCREATE Z {nStep} {CaMin} {CaMax} // Creates nStep entries
	
	for (i = 0; i < {nStep}; i = i + 1)		 		
 		Ca=i*delta
  		nmdacdi = {exp {-1*{nmdacdi_fact}*{Ca}}}
     	setfield {chanpath} Z_B->table[{i}] {nmdacdi} 
		setfield {chanpath} Z_A->table[{i}] {tau} 
	end		   	  		 			 
  	tweaktau {chanpath} Z
  	pope
end





