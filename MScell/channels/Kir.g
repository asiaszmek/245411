//genesis
/***************************		MS Model, Version 9.1 *********************
**************************** 	    	Kirg 			*********************
						Rebekah Evans updated 3/22/12 
******************************************************************************
******************************************************************************/


function make_KIR_channel

 //initial parameters for making tab channel
	float Erev = -0.09
	int m_power = 1
    int h_power = 0
    
//units are mV, ms
	float mA_rate = 1e-5
	float mA_slope = -11
	
	float mB_rate = 1.2
	float mB_vhalf = 30
	float mB_slope = -50

	str path = "KIR_channel" 

    float xmin  = -0.15  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 4000
    int c = 0

   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV
   
   float x = -150.00 
  
    	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate

    /* Defines the powers of m Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower {m_power} Ypower {h_power}

    /* fill the tables with the values of tau and minf/hinf
     * calculated from tau and minf/hinf
     */
	
	for (c = 0; c < {xdivsFiner} + 1; c = c + 1)
		float m_alpha = {exp_form {mA_rate} {mA_slope} {-x}}
		float m_beta = {sig_form {mB_rate} {mB_vhalf} {mB_slope} {x}}
		float mtau = {1e-3}/{{m_alpha}+{m_beta}}

		setfield {path} X_A->table[{c}] {({mtau}*2)/{qfactorKir}}
		setfield {path} X_B->table[{c}] {{m_alpha}/({m_alpha}+{m_beta})}
		x = x + increment
   	end
    tweaktau {path} X
      
end
