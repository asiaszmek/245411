//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	  		CaT.g 			*********************
	
******************************************************************************
Rebekah Evans updated 3/20/12 
Dan Dorman: edited generic CaT to CaV3.2 and 3.3
This file is the 3.3, aka alpha1I subunit, which is the slowest and most 
negative activation/inactivation curves (can cause bursting if too high gbar)
******************************************************************************/

function create_CaT33
	str chanName = "CaT33_channel"
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
	float mvHalfCaT = -72e-3 
  	float mkCaT     = -8e-3 
	float mshift = 0.002   //0 for a1i; 0.009 for a1g; 0.019 for a1h

  	float hvHalfCaT = -93e-3 
  	float hkCaT     = 5e-3 
  	float hInfCaT = 0.0
	float hshift = 0.0   //0 for a1i; 0.007 for a1g; 0.02 for a1h


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
		/************************ Begin CaT_mTau *********************/
		// mA = 14552*(vMemb + 0.0845)./
		//                      (exp((vMemb + 0.0845)/0.00712)-1);
		// mB = 4984.2*exp(vMemb/0.013);
		// mTauCaT = ((1/(mA + mB))+0.0025) / qFactCaT;
		// parameters tuned to fit mcrory 2001 subunit a1I


		theta = 14552*{ {x} + 0.0845}
		beta = {{x}  + 0.0845}/0.00712
		beta_exp = {exp {beta}}
		beta_exp = beta_exp - 1.0
		mA = {{theta}/{beta_exp}}

		beta = {{x}/0.013}
		beta_exp = {exp {beta}} 
		mB = 4984.2*{beta_exp}

		mTauCaT = {{1.0/{mA + mB}}+0.0022}		
		setfield {chanName} X_A->table[{c}] {{mTauCaT}/{qFactCaT}}
		/************************ End CaT_mTau ***********************/
		
		/************************ Begin CaT_mInf *********************/
		// mInfCaT   = 1./(1 + exp((vMemb - mvHalfCaT)/mkCaT));
		// parameters tuned to match Mcrory et al., 2001 a1g 
		theta = {{{x} - {mshift} - {mvHalfCaT}}/{mkCaT}}
		theta_exp = {exp {theta}} + 1.0
		mInfCaT = 1.0/{theta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaT}
		/************************ End CaT_mInf ***********************/

		/************************ Begin CaT_hTau *********************/
		// hA = 2652*(vMemb + 0.0945)./
		//                      (exp((vMemb + 0.0945)/0.00512)-1);
		// hB = 684.2*exp(vMemb/0.013);
		// hTauCaT = ((1/(hA + hB))+0.1) / qFactCaT;
		// parameters tuned to fit mcrory 2001 subunit a1I


		theta = 2652*{ {x} + 0.0945}
		beta = {{x}  + 0.0945}/0.00512
		beta_exp = {exp {beta}}
		beta_exp = beta_exp - 1.0
		hA = {{theta}/{beta_exp}}

		beta = {{x}/0.013}
		beta_exp = {exp {beta}} 
		hB = 684.2*{beta_exp}

		hTauCaT = {{1.0/{hA + hB}}+0.1}		
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
