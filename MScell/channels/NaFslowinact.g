//genesis

/***************************MS Model, Version 9.1	*********************
****************************   NaF.g 	*********************
updated Rebekah Evans 3/22/12					
******************************************************************************
******************************************************************************/

//**ref: Nobukuni Ogata, et.al. 1990


function make_NaFd_channel
float Erev       = 0.05      // V

    
    str path = "NaFd_channel" 

    float xmin  = -0.10  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 3000
    int c = 0
   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV


//Inactivation constants for alphas and betas
//units are mV, ms
	
	//mtau fits ogata figure 5 perfectly, but no qfactor is applied.  
    float mtau_min=0.1
	float mtau_rate = 1.45
	float mtau_slope = 8
    float mtau_vhalf=-62
	
	
	//activation minf fits Ogata 1990 figure 3C (which is cubed root) 
	float mss_rate = 1
	float mss_vhalf = -25
	float mss_slope = -10

	//htau fits the main -50 through -10 slope of Ogata figure 9 (log tau), but a qfact of 2 is already taken into account.  
	
    float htau_min=0.2754
	float htau_rate = 1.2
	float htau_slope = 3
    float htau_vhalf=-42
	
	//inactivation hinf fits Ogata 1990 figure 6B
	float hss_rate = 1
	float hss_vhalf = -60
	float hss_slope = 6
	    
	//slow inactivation variables
	float iA_rate = 200
	float iA_vhalf = -170
    float iA_slope = 8

    float iB_rate = 50
    float iB_vhalf = 5
    float iB_slope = -8

 	 /****** End vars used to enable genesis calculations **********/ 	 

 	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate
   call {path} TABCREATE Z {xdivsFiner} {xmin} {xmax}  // inactivation gate
    
   setfield {path} Z_conc 0

   float x = -100.00             // mV

   echo "Make naF, qfactor=" {qfactorNaF}

 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 

        float m_ss = {sig_form {mss_rate} {mss_vhalf} {mss_slope} {x}}
        float m_tau = {mtau_min} + {sig_form {mtau_rate} {mtau_vhalf} {mtau_slope} {x}}*{sig_form {mtau_rate} {mtau_vhalf} {-mtau_slope} {x}}
        float h_ss = {sig_form {hss_rate} {hss_vhalf} {hss_slope} {x}}
        float h_tau = {htau_min} + {sig_form {htau_rate} {htau_vhalf} {htau_slope} {x}}
 	float i_alpha = {sig_form {iA_rate} {iA_vhalf} {iA_slope} {x}}
	float i_beta = {sig_form {iB_rate} {iB_vhalf} {iB_slope} {x}}
   /* 1e-3 converts from ms to sec */		

	    setfield {path} X_A->table[{c}] {1e-3*{m_tau}/{qfactorNaF}}
        setfield {path} X_B->table[{c}] {m_ss}
	    setfield {path} Y_A->table[{c}] {2e-3*{h_tau}/{qfactorNaF}}  //qfact of 2 taken into account in original fit.  
        setfield {path} Y_B->table[{c}] {h_ss}
	setfield {path} Z_A->table[{c}] 20e-3 //Ogata with a qfact of 3
	setfield {path} Z_B->table[{c}] {{i_alpha/(i_alpha+i_beta)}}
		x = x + increment
    end


/* Defines the powers of m Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower 3 Ypower 1 Zpower 1

    /* fill the tables with the values of tau and minf/hinf
     * calculated from tau and minf/hinf
     */
   tweaktau {path} X
   tweaktau {path} Y   
   tweaktau {path} Z

end
