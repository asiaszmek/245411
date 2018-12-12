//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	      SK.g 	*********************

******************************************************************************

*****************************************************************************/

		// This is a simplified implementation of the SK channel without voltage
		// dependence. Reference: MaylieBondHersonLeeAdelman2004
		// Fast component has tau=4 ms, slow tau = 70 ms (rough ranges)


function make_SK_channel

  	int nStep = 2000
  	float SKact = 0.0
  	float CaMax = 0.1 // 100 uM
	//float CaMax = 0.006 // 6 uM 
	float CaMin = 1e-6 //1 nM
	float CaMin = 0 
  	float delta = (CaMax - CaMin)/nStep  
echo "delta=", {delta}
	float theta = 0.0
	float theta_pow = 0.0	
 	float Kd = 0.57e-003

	int i
   	float Ca = 0.0
    		
  	str chanpath = "SK_channel" 
  	
  	pushe /library

  	if (({exists {chanpath}}))
    	return
  	end

  	create  tabchannel {chanpath}
  	setfield	^		Ek  		{-90e-3}		\
					Gbar		0.145e4		\  //gbar gets overwritten by globals.g
					Ik			0			\
					Gk			0			\
					Xpower  	0			\
					Ypower  	0			\
					Zpower  	1			

  	call {chanpath} TABCREATE Z {nStep} {CaMin} {CaMax} // Creates nStep entries
	
	for (i = 0; i < {nStep}; i = i + 1)		 		
 		Ca=i*delta
   		theta = {Ca/Kd}
  		theta_pow = { pow {theta} 5.2}
  		SKact = theta_pow/{1 + theta_pow}
     	setfield {chanpath} Z_B->table[{i}] {SKact} //from Maylie et al., 2004 figure 2 
		setfield {chanpath} Z_A->table[{i}] {4.9e-3} // Fast component, tau=4.9ms from Hirschberg et al., 1998 figure 13.
	end		   	  		 			 
  	tweaktau {chanpath} Z
  	pope
end





