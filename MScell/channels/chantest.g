//genesis

/* This script should be modified to create the channels for which the
   activations and taus will be plotted
*/

/* First create the channels.  This example is taken from the traub91
  channels in neurokit/prototypes
*/
include../Ca_constants.g
int calciuminact=1
float qfactCa=2
include ../globals.g
qfactorkAs=3
include defaults.g   // Some definitions used by traub91chan.g
include CDI-GHK.g
include tabchanforms.g
include CaL12CDI.g // the functions to create the channels
include CaL13CDI.g
include CaNCDI.g
include CaRCDI.g
include CaT32.g
include CaT33.g
include KaS.g
include KaF.g
include Kir.g
include Krp.g
include NaF.g
include BK.g
include SK.g
include KaS_old.g
include NMDA_CDIGate.g
// a place to put channels - usually created in defaults.g or protodefs.g
if (!({exists /library}))
    create neutral /library
end
pushe /library
 	create_CaL12 
	create_CaL13
  create_CaN
  create_CaR
  create_CaT32
  create_CaT33
  make_KAs_channel  
  make_KAf_channel
  make_KIR_channel
  make_Krp_channel
  make_NaF_channel
  make_BK_channel
  make_SK_channel
  make_KAs_channel_old
  make_NMDA_CDI_gate /library/NMDA_CDI_gate
pope

/* This defines the default channel that will be plotted */
str channelpath = "/library/KAs_channel"

include chanplot.g  // modified from neurokit/xchannel_funcs.g
do_xchannel_funcs    // defined in chanplot.g 

ce /
xshow /channel_params  // show the form with graphs and widgets
