//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	    	KaS.g 			*********************
	Rebekah Evans update 3/22/12
	Kv1.2
******************************************************************************
*****************************************************************************/


function make_KAs_channel
   //include tabchanforms
  //initial parameters for making tab channel
	float Erev = -0.09
	int m_power = 2  //shen et al., 2004 p 1341
   int h_power = 1
	
//Activation constants for alphas and betas Shen et al., 2004 fig 3B (minf^2) and 3D (mtau)
float xshift = -3 //mv		
float vmh = -27.0
float vmc = -16
float vhh = -33.5
float vhc = 21.5
float taum0 = 3.4
float Cmt = 89.2
float vthm = -34.3
float vtcm = 30.1
float alpha = 1
float vth1 = -0.96
float vtc1 = 29.01
float beta = 1
float vth2 = -0.96
float vtc2 = 100
float Ch = 9876.6
float a = .996
float hshift = 0
float htaushift = -90


//Inactivation constants for alphas and betas tuned to fit Shen et al., 2004 fig 6B (Inact) hinf and htau.  
	
    
	//table filling parameters	
    float xmin  = -0.1  /* minimum voltage we will see in the simulation */ 
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */ 
    int  xdivsFiner = 3000 /* the number of divisions between -0.1 and 0.05 */
    int c = 0
    float increment = 1000*{{xmax}-{xmin}}/{xdivsFiner}

    float x = -100
	float m_alpha, m_beta, h_alpha, h_beta
      	
      	
    /* make the table for the activation with a range of -100mV - +50mV
     * with an entry for every 10mV
     */
	 
    str path = "KAs_channel" 
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax} 
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax} 
	 
 
    /*fills the tabchannel with values for minf, mtau, hinf and htau,
     *from the files.
     */

echo "make kA, qfactor=" {qfactorkAs}	
    for (c = 0; c < {xdivsFiner} + 1; c = c + 1)
			
        float minf = {1 / {1+{exp { {{{x}+{xshift}} - {vmh}} / {vmc} } }}}
        float hinf = {{1 / {1+{exp { {{{x}+{xshift}} - {vhh} - {hshift}} / {vhc} } }}}} //* {{a}*{hinf}+{1-{a}}}}
 		
//        float mtau = {{{taum0}  + { {Cmt} * {exp {  { { {x}-{vthm} }/{vtcm}}^2 * {-1.0} }}}} * {1e-3}}
        float mtau_sq = { {{{x}+{xshift}}-{vthm}}/{vtcm} }
        float mtau_exp = { exp { -{{mtau_sq} * {mtau_sq}} } }
        float mtau = {{{taum0} + {{Cmt} * {mtau_exp}}} * {1e-3}}

        float left = {{alpha} * {exp { -{{{x}+{xshift}}-{vth1}-{htaushift}}/{vtc1} }}}
        float right = {{beta} * {exp { {{{x}+{xshift}}-{vth2}-{htaushift}}/{vtc2} }}}
	
		float htau = {{{Ch}  /  { {left} + {right} }	}	* {1e-3}}


        float xa = {mtau}
		float xb = {minf}
		float ya = {htau}
		float yb = {{{hinf} * {a}} + {1-{a}}} 
		//the *0.8+0.2 in yb is to make the channel partially inactivate.  Shen et al., 2004 fig 6B
		
		// Tables are filled with inf and taus in order to make this channel partially inactivate.
		setfield {path} X_A->table[{c}] {{xa}/{qfactorkAs}}
		setfield {path} X_B->table[{c}] {xb}
		setfield {path} Y_A->table[{c}] {{ya}/{qfactorkAs}}
        setfield {path} Y_B->table[{c}] {yb}
		x = x + increment
    end
			
    /* Defines the powers of m and h in the Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower {m_power} Ypower {h_power} 
    tweaktau {path} X 
    tweaktau {path} Y 

end
