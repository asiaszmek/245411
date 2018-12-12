//genesis
//nmda_channel.g
include MScell/channels/NMDA_CDIGate.g

function make_NMDA_channel (chanpath, Ek, KMg, tau2, gmax, ghk, depr, deprtau,nmdacdi)

  str chanpath //what you want the channel to be called (full path)
  float KMg, tau2, gmax  //parameters that differ between NR2A, B, C and D subunits
  float depr
  float deprtau
  float Ek
  int ghk 
  int nmdacdi

  float tau1 =  (4.4624e-3)/2 //(5.63e-3)/8 //(4.4624e-3)/2 //  DE Chapman et al 2003, table 1 (5.63ms: wolf) w/qfact of 2 
			     //is (4.4624e-3)/2 in Evans et al., 2012
  float CMg = 1.4  // [Mg] in mM //Kerr and Plenz uses 1.4mM Mg

  float eta = 1/3.57  // Kmg = 1/eta, (per mM) overwritten by synparams, 3.57 old, 18 new
  float gamma = 99  //99 new //62 old  // per Volt

	echo "XXX make_NMDA_channel, chanpath = "{chanpath} "caBuffer = "{Ek} "KMg = "{KMg} "tau2 = "{tau2}

    make_synaptic_channel {chanpath} {tau1} {tau2} {gmax} {Ek} {depr} {deprtau}

//the kinetics of the magnesium block is different for different subunits.  
// NR2A and B are about the same, but C and D are much less affected by the block.  
//these numbers were used because the made the magnesium block curve fit the figures by Moyner et al (1994 figure 7) best by eye.

  create Mg_block {chanpath}/block
  setfield {chanpath}/block CMg {CMg} 
  setfield {chanpath}/block KMg_B {1.0/{gamma}}
  setfield {chanpath}/block KMg_A {KMg}
				
  addmsg {chanpath} {chanpath}/block CHANNEL Gk Ek

  if (ghk==1)  //GHK_yesno is set in Synparams.g
     create ghk {chanpath}/GHK
     setfield {chanpath}/GHK Cout 2 // Carter & Sabatini 2004 uses 2mM, Wolf 5mM
     setfield {chanpath}/GHK valency 2.0
     setfield {chanpath}/GHK T {TEMPERATURE}

    //need to scale the NMDA current according to GHK kluge factor and calcium permeability
     create diffamp {chanpath}/CaCurr
     setfield {chanpath}/CaCurr gain {NMDAfactGHK} saturation 1.0

     addmsg {chanpath}/block {chanpath}/CaCurr PLUS Gk
     addmsg {chanpath}/CaCurr {chanpath}/GHK PERMEABILITY output
  end

  if (nmdacdi==1) //nmdacdi set in synparams.g
    make_NMDA_CDI_gate {chanpath}/NMDA_CDI_gate
    addmsg {chanpath}/NMDA_CDI_gate {chanpath} MOD Gk
  end
end

