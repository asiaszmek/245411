//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	    	CaL13channel.g 		*********************
Rebekah Evans updated 3/20/12	
******************************************************************************
******************************************************************************/


function create_CaL13
	str chanName = "CaL13_channel"
	str compPath = "/library"
	int c
	float Ek = 0.140  //(nernst calculated for 35degrees, [Cain] 50nM [Caout]2mM)
			//Ek is overwritten the the GHK object if it is used. 
	float xmin = -0.1
	float xmax = 0.05
	int 	xdivs = 3000
	float mPower = 1.0   //mh is an equally common form to m2h (tuckwell 2012)
	float hPower = 1.0
	if (calciuminact == 1)
		float zpower = 1.0
	else
		float zpower = 0
	end	
	
        float increment ={{xmax}-{xmin}}/{xdivs}
        echo "CaL13 increment:" {increment} "V"
	float x = -0.1
  	float surf = 0
 	float gMax = 0

	float hTauCaL13 	= 44.3e-3
	float mTauCaL13 	= 0.0
	float mvHalfCaL13 = -40.0e-3
	float mkCaL13     = -5e-3
	float hvHalfCaL13 = -37e-3
	float hkCaL13     = 5e-3
	float hInfCaL13	= 0.0
	float mInfCaL13	= 0.0

	float theta	= 0.0
	float beta	= 0.0
	float beta_exp	= 0.0
	float mA = 0.0
	float mB = 0.0
	float qFactCaL13 = {qfactCa}
	
	pushe {compPath}

	create tabchannel {chanName}
  	setfield {chanName} Ek {Ek} Xpower {mPower} Ypower {hPower} Zpower {zpower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
        call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}
		
//fill in the voltage act and inact tables

	for(c = 0; c < {xdivs} + 1; c = c + 1)
		/************************ Begin CaL13_mTau *********************/
		//mA = 39800*(vMemb + 67.24e-3)./(exp((vMemb + 67.24e-3)/15.005e-3) - 1);
		//mB = 3500*exp(vMemb/31.4e-3);
		//mTauCaL13 = 1./(mA + mB) / qFactCaL13;
		//parameters tuned to fit Tuckwell 2012 figure 12

		theta = 39800*{ {x} + 67.24e-3}
		beta = {{x} + 67.24e-3}/15.005e-3
		beta_exp = {exp {beta}}
		beta_exp = beta_exp - 1.0
		mA = {{theta}/{beta_exp}}
		
		beta = {{x}/31.4e-3}
		beta_exp = {exp {beta}} 
		mB = 3500*{beta_exp}

		mTauCaL13 = {{1/{mA + mB}}/{qFactCaL13}}	
		setfield {chanName} X_A->table[{c}] {mTauCaL13}
		/************************ End CaL13_mTau ***********************/		

		/************************ Begin CaL13_mInf *********************/
		// mInfCaL13   = 1./(1 + exp((vMemb - mvHalfCaL13)/mkCaL13));
		//parameters tuned to fit Tuckwell 2012 figure 3
		beta = {{x} - {mvHalfCaL13}}/{mkCaL13}
		beta_exp = {exp {beta}} + 1.0
		mInfCaL13 = 1.0/{beta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaL13}
		/************************ End CaL12_mInf ***********************/	

		/************************ Begin CaL13_hTau *********************/
		// hTauCaL13 
		setfield {chanName} Y_A->table[{c}] {{hTauCaL13}/{qFactCaL13}}
		/************************ End CaL12_hTau ***********************/

		/************************ Begin CaL13_hInf *********************/
		// hInfCaL13   = 1./(1 + exp((vMemb - hvHalfCaL13)/hkCaL13));
		//parameters tuned to fit Tuckwell 2012 figure 12
		beta = {{x} - {hvHalfCaL13}}/{hkCaL13}
		beta_exp = {exp {beta}} + 1.0
		hInfCaL13 = 1.0/{beta_exp}
		setfield {chanName} Y_B->table[{c}] {hInfCaL13}
		/************************ End CaL13_hInf ***********************/	
   	x = x + increment
	end	

	tweaktau {chanName} X
	tweaktau {chanName} Y

	//fill in the Z table with CDI values
	if (calciuminact == 1)
        addCDI {chanName}
	end

    addGHK {chanName}
  	setfield {chanName} Gbar {gMax*surf}

  	pope
end
