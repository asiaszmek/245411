//genesis

/***************************		MS Model, Version 9.1	*********************
**************************** 	  		CaR.g 			*********************
	Rebekah Evans 3/20/12 updated channel. 
******************************************************************************
******************************************************************************/

function create_CaR
	str chanName = "CaR_channel"
	str compPath = "/library"

	int c = 0	

	int xdivs = 3000
	float Ek = 0.140  //(nernst calculated for 35degrees, [Cain] 50nM [Caout]2mM)
    //Ek is overwritten the the GHK object if it is used. 
	float x = -0.1
	float xmin = -0.1
	float xmax = 0.05
    float increment ={{xmax}-{xmin}}/{xdivs}
    echo "CaR increment:" {increment} "V"
  	float mPower = 3.0  //Foerhing et al., 2000 p 2228
  	float hPower = 1.0
	if (calciuminact == 1)
		float zpower = 1.0
	else
		float zpower = 0
	end

    float mvshift = 0//-15e-3 + 20e-3 //Improves R contribution to bAP calcium (consistent with Carter/sabatini 2004)
    float hvshift = 0//0+20e-3
    float mvHalfCaR = -19.9e-3//-29e-3 //-14.9e-3 is the value given by Foehring et al  
	float mkCaR     = -6.8e-3//-9.6e-3 
	float hvHalfCaR = -38.3e-3//-33.3e-3 is value given by Foehring
 	float hkCaR     = 17e-3

	float mTauCaR = 0.0 //5.1e-003  //Foehring et al., 2000 pg 2230.
	float mInfCaR = 0.0
	float hTauCaR = 0.0
	float hInfCaR = 0.0
    float malpha = 0.0
    float mbeta = 0.0
	float hA 
	float hB

	float qFactCaR = {qfactCa}

	float surf = 0.0
	float gMax = 0

	float theta = 0.0
	float theta_exp = 0.0

	float beta = 0.0
	float beta_exp = 0.0

	pushe {compPath}

	create tabchannel {chanName}
  	setfield {chanName} Ek {Ek} Xpower {mPower} Ypower {hPower} Zpower {zpower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
    call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}

	for(c = 0; c < {xdivs} + 1; c = c + 1)
        /************************ Begin CaR_mTau *********************/
		// mTauCaR 
		malpha = {240./{exp {{{x} + {mvshift}}/-.028}}}
        mbeta = {{1.26e6 + 8.0e6 * {{x} + {mvshift}} }/{-1.0 + { exp {{ {{x} + {mvshift}} + 0.158}/.0136}}}}
        mTauCaR = {1./{{malpha}+{mbeta}}}
        setfield {chanName} X_A->table[{c}] {{mTauCaR}/{qFactCaR}}
		/************************ End CaR_mTau ***********************/
		
		/************************ Begin CaR_mInf *********************/
		//mInfCaR   = 1./(1 + exp((vMemb - mvHalfCaR)/mkCaR));
		// parameters tuned to fit Foerhing et al., 2000 fig 6
		theta = {{{x} + {mvshift}} - {mvHalfCaR}}/{mkCaR}
		theta_exp = {exp {theta}} + 1.0
		mInfCaR = 1.0/{theta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaR}
		/************************ End CaR_mInf ***********************/

	
		/************************ Begin CaR_hTau *********************/
		// hA = 10e6*(vMemb + 0.0945)./
		//                      (exp((vMemb + 0.0945)/0.00512)-1);
		// hB = 84.2*exp(vMemb/0.013);
		// hTauCaR = ((1/(hA + hB))+0.1) / qFactCaR;
		// parameters tuned to fit Brevi 2001 fig 10


        //	theta = {{10e6}*{ {x} + 0.0945}}
        //	beta = {{x}  + 0.0945}/0.00512
        //	beta_exp = {exp {beta}}
        //	beta_exp = beta_exp - 1.0
        //	hA = {{theta}/{beta_exp}}

        //	beta = {{x}/0.013}
        //	beta_exp = {exp {beta}} 
        //	hB = 84.2*{beta_exp}

        //	hTauCaR = {{1.0/{{hA} + {hB}}}+0.02}		
		
        float hTauAlpha = {{10000.*.11+10000.*{{x} + {hvshift}}}/{-1+{exp {{{{x} + {hvshift}}+.110001}/.017}}}}
        float hTauBeta = {20/{exp {{{x} + {hvshift}}/-.03}}}
        hTauCaR = {1.0/{{hTauAlpha}+{hTauBeta}}}   
        setfield {chanName} Y_A->table[{c}] {hTauCaR}/{qFactCaR}
		/************************ End CaR_hTau ***********************/
		
		/************************ Begin CaR_hInf *********************/
		//hInfCaR   = 1./(1 + exp((vMemb - hvHalfCaR)/hkCaR));
		// parameters tuned to fit Foerhing et al., 2000 fig 7
		theta = {{{x} + {hvshift}} - {hvHalfCaR}}/{hkCaR}
		theta_exp = {exp {theta}} + 1.0
		hInfCaR = 1.0/{theta_exp}
		setfield {chanName} Y_B->table[{c}] {hInfCaR}
		/************************ End CaR_hInf ***********************/
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


