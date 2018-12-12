//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	    	CaL12channel.g 		*********************Rebekah Evans updated 3/20/12
******************************************************************************
******************************************************************************/


function create_CaL12
	str chanName = "CaL12_channel"
	str compPath = "/library"
	int c
	float Ek = 0.140  //(nernst calculated for 35degrees, [Cain] 50nM [Caout]2mM)
			//Ek is overwritten the the GHK object if it is used. 
	float xmin = -0.1
	float xmax = 0.05
	int 	xdivs = 3000
	float mPower = 1.0  //mh is an equally common form to m2h (tuckwell 2012)
	float hPower = 1.0
	if (calciuminact == 1)
		float zpower = 1.0
	else
		float zpower = 0
	end	

	
        float increment ={{xmax}-{xmin}}/{xdivs}
        echo "CaL12 increment:" {increment} "V"
	float x = -0.1
  	float surf = 0
 	float gMax = 0

	float hTauCaL12 	= 44.3e-3
	float mTauCaL12 	= 0.0
	float mvHalfCaL12 = -8.9e-3
	float mkCaL12     = -6.7e-3
	float hvHalfCaL12 = -55e-3
	float hkCaL12     = 8e-3
	float hInfCaL12	= 0.0
	float mInfCaL12	= 0.0

	float theta	= 0.0
	float beta	= 0.0
	float beta_exp	= 0.0
	float mA = 0.0
	float mB = 0.0
	float qFactCaL12 = {qfactCa}
	
	pushe {compPath}
	

	create tabchannel {chanName}
  	setfield {chanName} Ek {Ek} Xpower {mPower} Ypower {hPower} Zpower {zpower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
        call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}
		
	
//fill in the voltage act and inact tables

	for(c = 0; c < {xdivs} + 1; c = c + 1)
		/************************ Begin CaL12_mTau *********************/
		//mA = 0.0398e6*(vMemb + 8.124e-3)./(exp((vMemb + 8.124e-3)/9.005e-3) - 1);
		//mB = 0.99e3*exp(vMemb/31.4e-3);
		//mTauCaL12 = 1./(mA + mB) / qFactCaL12;

		theta = 0.0398e6*{ {x} + 8.124e-3}
		beta = {{x} + 8.124e-3}/9.005e-3
		beta_exp = {{exp {beta}} - 1.0}
		mA = {{theta}/{beta_exp}}
		
		beta = {{x}/31.4e-3}
		beta_exp = {exp {beta}} 
		mB = 0.99e3*{beta_exp}

		mTauCaL12 = {1/{mA + mB}}/{qFactCaL12}		
		setfield {chanName} X_A->table[{c}] {mTauCaL12}
		/************************ End CaL12_mTau ***********************/		

		/************************ Begin CaL12_mInf *********************/
		// mInfCaL12   = 1./(1 + exp((vMemb - mvHalfCaL12)/mkCaL12));
		beta = {{x} - {mvHalfCaL12}}/{mkCaL12}
		beta_exp = {exp {beta}} + 1.0
		mInfCaL12 = 1.0/{beta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaL12}
		/************************ End CaL12_mInf ***********************/	

		/************************ Begin CaL12_hTau *********************/
		// hTauCaL12 
		setfield {chanName} Y_A->table[{c}] {{hTauCaL12}/{qFactCaL12}}
		/************************ End CaL12_hTau ***********************/

		/************************ Begin CaL12_hInf *********************/
		// hInfCaL12   = 1./(1 + exp((vMemb - hvHalfCaL12)/hkCaL12));
		beta = {{x} - {hvHalfCaL12}}/{hkCaL12}
		beta_exp = {exp {beta}} + 1.0
                //0.17 has vdep inactivation, 0.83 does not inactivate
		hInfCaL12 = {0.17*{1.0/{beta_exp}} + 0.83}
		setfield {chanName} Y_B->table[{c}] {hInfCaL12}
		/************************ End CaL12_hInf ***********************/	
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
