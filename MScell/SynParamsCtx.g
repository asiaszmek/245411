//genesis
//SynParamsCtx.g
str AMPAname = "AMPA"
float EkAMPA = 0.0
float AMPAtau1 = 1.1e-3   //wolf with qfact of 2 taken into account (t1 and t2)
//float AMPAtau2 = 5.75e-3  //these tau are quite slow compared to hippocampal values
//float AMPAgmax = 0.51e-9 // 45 mV PSP, AP calcium trivial compared to PSP
//float AMPAtau1=0.2e-3
float AMPAtau2=2.0e-3 // double hippo values; faster than GABA
float AMPAgmax=0.9e-9//0.125e-9  //0.15 0.19 25 mV PSP, AP calcium higher than PSP calcium 0.342e-9
float AMPACaper = 0.001//0.00 //0.001 //percent AMPA conductance that is carried by calcium. value from wolf							//more like 2/1 for thalamus so should be 0.47e-9 for thalamo-striatal syanpnse if NMDA is 0.94e-9 Rebekah Evans 6/25/10
float AMPAdes = 0.39 //1.7  		//desensitization factor, (depr_per_spike field of facsynchan)
float AMPAdestau = 0.8 // 0.54	// desensitization tau (how fast des recovers)



str GABAname = "GABA"
float GABAtau1 = 1.0e-3//0.25e-3    // 0.25e-3From Galarreta and Hestrin 1997 
float GABAtau2 = 14.4e-3//80.75e-3    //(3.75e-3 used in Wolfs model; 80.75e-3 used by Asia; from NPY_Neurogliaform with slow GABAA current)
float EkGABA = -0.060  		//calculated Kerr and Plenz 2004 Erev for Cl, is -60 mV 5/2/12 RCE
float GABAgmax = 1200e-12//5000e-12 used by Asia  //was 750, Sri uses 900 //Modified Koos 2004 (Wolf uses 435e-12)
/*Notes on GABA: gmax= 600 pS would not be unreasonable for LTSI based on Straub...Sabatini (2016), might be larger due to being distally located;
gmax = 1200-1800 pS for NPY-NGF based on Ibanez-Sandoval...Tepper (2011); similar for FSI (Straub et al 2016)
LTSI,FSI: tau rise: ~.5-2.0 ms (mean ~1.0); tau decay ~ 10-30 ms (mean~14.4) (based on Straub, Ibanez-Sandoval). LTSI appears slower in somatic voltage clamp, likely due to distally located synapses
NPY-NGF: tau rise: 10 ms (range 3-19), tau decay: 83 (range 29-127) (From Ibanez-Sandoval et al. Consistent with other GABA_A_slow currents in other NGF interneurons) */
float GABAdelay =  0.02
int ghk_yesno=1  //0 no ghk objects for NMDA, 1 add ghk to NMDA 
			 //ghk reduction factor and hoook ups to calcium shells are in Addsynapticchannels.g


// parameters for NMDA subunits
// cortex
str	    subunit = "ctx" 
float   EkNMDA   = 0
float	Kmg       = 18 //18 new //3.57 old overwrites 1/eta in nmda_channel.g
if ({subunit}=="NR2A")
    float	NMDAtau2      = {(50e-3)/2} 
elif ({subunit}=="NR2B")
    float NMDAtau2 = (300e-3)/2 
elif ({subunit}=="ctx")
    float NMDAtau2 =  (112.5e-3)/2  //	ctx avg for .25 NR2B and .75 NR2A. 
else
    echo "no other NMDA subunits defined in SynParamsCtx.g"
end
float   N2Aratio=1.0  //NMDA to AMPA ratio of 1:1 is in middle of measured range for striatum
float	NMDAgmax   = {AMPAgmax}*{N2Aratio} //0.94e-9 NR2A and B from (Moyner et al., 1994 figure 7)
                      //0.47e-9 using 2.75:1 NMDA:AMPA (Ding 2008), which is extreme.  
float   NMDAperCa = 0.1 // percent calcium influx Note: Divided by 2 in AddSynapticChannel for GHK case because of the enhanced driving potential: ohmic to GHK, reversal potentail from 0 to huge value
float 	NMDAfactGHK = 35e-9//35e-9 	//adjustment factor for GHK to calcium shell/pool
//This is necessary because GHK reads in Gk from block and interprets it as permeability.  this results in ridiculous current, restored to normal by factor of ~e-8
float   NMDAdes = 0 //1  		//desensitization factor, (depr_per_spike field of facsynchan)
float   NMDAdestau = 0 //200e-3	// desensitixation t (how fast des recovers)
str NMDAname = {subunit}
int nmdacdiyesno = 1 // 1 or 0, whether to implement nmda_cdi
//for saving info on distal or proximal dendrites or massed and spaced. formula typeof dend, # of spines.

//parameters for NMDA calcium interactions
int NMDABufferMode = 0  // 1, connect both NMDA and AMPA calcium to Calcium_pool
                            // 0, connect only NMDA currents to calcium_pool
str bufferNMDA="Ca_pool_nmda"
if ({calciumtype}==0)
    str NMDApool= {CalciumName}@"1"
else
    str NMDApool={bufferNMDA}
end
