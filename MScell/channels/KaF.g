//genesis

/***************************		MS Model, Version 9.1 *********************
**************************** 	    	KaF.g 			*********************
						Rebekah Evans updated 3/21/12 
	Kv4.2
******************************************************************************
******************************************************************************/

function make_KAf_channel

  //initial parameters for making tab channel
	float Erev = -0.09
	int m_power = 2   //used in Wolf 2005
    int h_power = 1

    float xshift = 0//1 //mv (positive value shifts curve to the left)
//Activation constants for alphas and betas (obtained by matching m2 to Tkatch et al., 2000 Figs 2c, and mtau to fig 2b)
//units are mV, ms
	float mA_rate = 1.8  
	float mA_vhalf = -18    
	float mA_slope = -13   
	
	float mB_rate = 0.45  
	float mB_vhalf = 2   
	float mB_slope = 11  
	
//Inactivation constants for alphas and betas obtained by matching Tkatch et al., 2000 Fig 3b, and creating a tau voltage dependence 
//which is consistent with their value for V=0 in figure 3c.  
//units are mV, ms
	float hA_rate = 0.105
	float hA_vhalf = -121
	float hA_slope = 22
	
	float hB_rate = 0.065
	float hB_vhalf = -55
	float hB_slope = -11
	    
	//table filling parameters	
    float xmin  = -0.1  
    float xmax  = 0.05  
    int  xdivsFiner = 3000
    int c = 0
    float increment =1000*{{xmax}-{xmin}}/{xdivsFiner}

    float x = -100

 
    str path = "KAf_channel" 
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {{xmin}} {{xmax}} 
    call {path} TABCREATE Y {xdivsFiner} {{xmin}} {{xmax}} 
	 
 
    /*fills the tabchannel with values for minf, mtau, hinf and htau,
     *from the files.
     */

    for (c = 0; c < {xdivsFiner} + 1; c = c + 1)
		float m_alpha = {sig_form {mA_rate} {mA_vhalf} {mA_slope} {{x}+{xshift}}}
		float m_beta = {sig_form {mB_rate} {mB_vhalf} {mB_slope} {{x}+{xshift}}}
		float h_alpha = {sig_form {hA_rate} {hA_vhalf} {hA_slope} {{x}+{xshift}}}
		float h_beta = {sig_form {hB_rate} {hB_vhalf} {hB_slope} {{x}+{xshift}}}
   /* 1e-3 converts from ms to sec. Tkactch does not specify recording temperature so room temperature is assumed*/		
		setfield {path} X_A->table[{c}] {{{1e-3/(m_alpha+m_beta)}}/{{qfactorkAf}}}
		setfield {path} X_B->table[{c}] {m_alpha/(m_alpha+m_beta)}
		setfield {path} Y_A->table[{c}] {{{1e-3/(h_alpha+h_beta)}}/{{qfactorkAf}}}
        	setfield {path} Y_B->table[{c}] {h_alpha/(h_alpha+h_beta)}
		x = x + increment
    end
	
			
    /* Defines the powers of m and h in the Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower {m_power} Ypower {h_power} 
    tweaktau {path} X 
    tweaktau {path} Y 

end



































