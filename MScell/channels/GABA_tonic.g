//genesis

/***************************MS Model, Version 9.1	*********************
****************************   Gaba_tonic.g 	*********************
			
******************************************************************************
******************************************************************************/
//first implementation of tonic GABA

function make_tonic_GABA
    
    float Gk = 1.
    float Ek = -0.060 //V, Cl reversal potential
    str path = "tonic_GABA"
    create leakage {path}
    setfield {path} Ek {Ek} Gk {Gk}
end
