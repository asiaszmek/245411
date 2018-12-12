//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	  		CaT.g 			*********************
	
******************************************************************************
Rebekah Evans updated 3/20/12 
Dan Dorman modified for a CaV3.2 T-Type (aka alpha1H subunit)
******************************************************************************/

function create_CaT32
	str chanName = "CaT32_channel"
	str compPath = "/library"

	int c = 0	
	float Ek = 0.140 //(nernst calculated for 35degrees, [Cain] 50nM [Caout]2mM)
			//Ek is overwritten the the GHK object if it is used. 
	float increment = 0.00005	
	float x = -0.1
	int xdivs = 3000
	float xmin = -0.1
	float xmax = 0.05
        float increment ={{xmax}-{xmin}}/{xdivs}
        echo "CaT increment:" {increment} "V"
  	float mPower = 3.0  //Cain 2010 review Crunelli 2005
  	float hPower = 1.0		

  	float mInfCaT = 0.0
	float mvHalfCaT = -43.15e-3//McRory a1h (CaV3.2) 
  	float mkCaT     = -5.34e-3//
	float mshift = 0//

  	float hvHalfCaT = -73.9e-3// 
  	float hkCaT     = 2.76e-3// 
  	float hInfCaT = 0.0
	float hshift = 0//


  	float mTauCaT = 0.0
  	float mInfCaT = 0.0
  	float hTauCaT = 0.0
  	float hInfCaT = 0.0
	float mA	= 0.0
	float mB	= 0.0
	float hA	= 0.0
	float hB	= 0.0


	
	float qFactCaT = {qfactCa}


	float surf = 0.0
	float gMax = 0

	float theta = 0.0
	float theta_exp = 0.0
	
	float beta = 0.0
	float beta_exp = 0.0
	
	pushe {compPath}

	create tabchannel {chanName}
  	setfield {chanName} Ek {Ek} Xpower {mPower} Ypower {hPower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
   call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}

	for(c = 0; c < {xdivs} + 1; c = c + 1)
		// mA = 160000*(vMemb + 0.112)./
		//                      (exp((vMemb + 0.112)/0.011)-1);
		// mB = 8500*exp(vMemb/0.0125);
		// mTauCaT = ((1/(mA + mB))+0.0009) / qFactCaT;
		// parameters tuned to fit mcrory 2001 subunit a1H


		theta = 160000*{ {x} + 0.112}
		beta = {{x}  + 0.112}/0.011
		beta_exp = {exp {beta}}
		beta_exp = beta_exp - 1.0
		mA = {{theta}/{beta_exp}}

		beta = {{x}/0.0125}
		beta_exp = {exp {beta}} 
		mB = 8500*{beta_exp}

		mTauCaT = {{1.0/{mA + mB}}+0.0009}		
		setfield {chanName} X_A->table[{c}] {{mTauCaT}/{qFactCaT}}
		/************************ End CaT_mTau ***********************/
		
		/************************ Begin CaT_mInf *********************/
		// mInfCaT   = 1./(1 + exp((vMemb - mvHalfCaT)/mkCaT));
		// parameters tuned to match Mcrory et al., 2001 a1g
        // minf = 1/(1 + exp(-(v-vhalfn)/kn)), vhalf = -43.15e-3, kn = 5.34
		theta = {{{x} - {mshift} - {mvHalfCaT}}/{mkCaT}}
		theta_exp = {exp {theta}} + 1.0
		mInfCaT = 1.0/{theta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaT}
		/************************ End CaT_mInf ***********************/

		/************************ Begin CaT_hTau *********************/
		/*  hTau = (22.25e-3+0.0455e-3*exp(-vm/7.46e-3))/qfactorCa
		// parameters tuned to fit mcrory 2001 subunit a1H (CaV3.2) */




        float hTauexp = {exp {{-x}/7.46e-3}}
    
        hTauCaT = 22.25e-3 +0.0455e-3 * {hTauexp}		

		setfield {chanName} Y_A->table[{c}] {{hTauCaT}/{qFactCaT}}
		/************************ End CaT_hTau ***********************/
		
		/************************ Begin CaT_hInf *********************/
		// hInfCaT   = 1./(1 + exp((vMemb - hvHalfCaT)/hkCaT));
		// parameters tuned to fit mcrory 2001 subunit a1g
		theta = {{{x} - {hshift} - {hvHalfCaT}}/{hkCaT}}
		theta_exp = {exp {theta}} + 1.0
		hInfCaT = 1.0/{theta_exp}
		setfield {chanName} Y_B->table[{c}] {hInfCaT}
		/************************ End CaT_hInf ***********************/
    	x = x + increment
	end

	tweaktau {chanName} X
	tweaktau {chanName} Y

  	addGHK {chanName}
  	setfield {chanName} Gbar {gMax*surf}

    pope
end
