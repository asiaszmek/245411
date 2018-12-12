//genesis


/***************************		MS Model, Version 9.1	*********************
**************************** 	      Krp.g 	*********************
Rebekah Evans updated 3/22/12
*****************************************************************************/

function make_Krp_channel
	
	float Erev = -0.09
	int m_power = 2 //(Nisenbaum 1996 p 1187)
	int h_power = 1
	
	//table filling parameters	
    float xmin  = -0.1  
    float xmax  = 0.05  
    int  xdivsFiner = 3000
    int c = 0
    float increment =1000*{{xmax}-{xmin}}/{xdivsFiner}
    float x = -100
 


   str path = "Krp_channel" 
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax} 
	call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax} 
	
//units are mV, ms
//m parameters tuned to fit Nisenbaum 1996 fig6C (minf^2) and fig 8C (mtau)
	float mA_rate = 16
	float mA_slope = 20
	
	float mB_rate = 2.4
	float mB_slope = -40

//h parameters tuned to fit Nisenbaum 1996 fig 9D (hinf, 87% inactivating) and 9B (htau)	
	float hA_rate = 0.01
	float hA_slope = -100
	
	float hB_rate = 0.4
	float hB_slope = 18
	
     for (c = 0; c < {xdivsFiner} + 1; c = c + 1)
		float m_alpha = {exp_form {mA_rate} {mA_slope} {-x}}   //notice x sign is reversed. see tabchanforms.g 
		float m_beta = {exp_form {mB_rate} {mB_slope} {-x}}

		float mtau= {1/(m_alpha+m_beta)}
		float m_inf= {m_alpha/(m_alpha+m_beta)}

		float h_alpha = {exp_form {hA_rate} {hA_slope} {-x}}   
		float h_beta = {exp_form {hB_rate} {hB_slope} {-x}}

		float htau= {(1/(h_alpha+h_beta))+2} //+2 is necessary to fit Nisenbaum fig 9B)
		float h_inf= ((0.87*{h_alpha/(h_alpha+h_beta)})+0.13) //(0.13 non-inact component from Nisenbaum fig 9D)

		//Nisenbaum 1996 does not specify recording temp, so room temp is assumed.
  		setfield {path} X_A->table[{c}] {{mtau}/{qfactorKrp}}
		setfield {path} X_B->table[{c}] {m_inf}
		setfield {path} Y_A->table[{c}] {{htau}/{qfactorKrp}}
		setfield {path} Y_B->table[{c}] {h_inf}
		
		x = x + increment
    end
   
     /* Defines the powers of m and h in the Hodgkin-Huxley equation*/
   setfield {path} Ek {Erev} Xpower {m_power} Ypower {h_power} 
    tweaktau {path} X 
    tweaktau {path} Y 
end
//************************ End Primary Routine ********************************
//*****************************************************************************

