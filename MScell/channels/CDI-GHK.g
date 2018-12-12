function addCDI (chanName)
str chanName

	//parameters for calcium-dep inactivation (CDI) 
	
	float Ca = 0.0
	float CaMax = 0.1 //100uM
	float CaMin = 0.0
	float CaDivs = 2000//increments of 50 nM
	float CaIncrement ={{CaMax}-{CaMin}}/{CaDivs}
    echo "CDIincrement:" {CaIncrement} 

	//CDI equation from Tuckwell review paper 2012 progress in neurobiology table A1.3 

    call {chanName} TABCREATE Z {CaDivs} {CaMin} {CaMax}
	
    int a
    float CDI
    float q, k, b, n
    for(a = 0; a < {CaDivs} + 1; a = a + 1)
			//f= (0.001/(0.001+[Ca]))Poirazi CA1  2003
			//f= (0.0005/(0.0005+[Ca])) Rhodes and Llinas 2001 Cort Pyr
        Ca=a*{CaIncrement}
        k=0.12e-3 //0.5e-3
        b={pow {k} 4} //3
        n={pow {Ca} 4} //3
        q = {{b}/({b}+{n})}
        CDI = {pow {q} 2} //100
        setfield {chanName} Z_B->table[{a}] {CDI}
        setfield {chanName} Z_A->table[{a}] {{142e-3}/{cdiqfact}} //CaL1.2 in HEK cells Barrett and Tsien 2007 roomtemp
	end	
    tweaktau {chanName} Z 
end
  	
function addGHK (chanName)
str chanName

	create ghk {chanName}GHK
  	setfield {chanName}GHK Cout 2 // Carter & Sabatini 2004 uses 2mM, 
										// Wolf 5mM
  	setfield {chanName}GHK valency 2.0
  	setfield {chanName}GHK T {TEMPERATURE}
	
  	addmsg {chanName} {chanName}GHK PERMEABILITY Gk	
end
