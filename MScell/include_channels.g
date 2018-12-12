//genesis
//include_channels.g v9.1
/*******
Rebekah Evans updated 3/20/12
include_channels.g is included in proto.g file
**********/

include MScell/channels/tabchanforms.g
include MScell/channels/CDI-GHK.g

//voltage dependent channels
include MScell/channels/NaF	
include MScell/channels/NaFslowinact		//double checked RCE 3/23/12, realized htau has qfact 2 taken into account, but not mtau. no changes made, but will test qfact
include MScell/channels/KaF  			//double checked RCE 3/21/12 fine, no changes.  triple checked with genesis _____
include MScell/channels/Kir			//double checked RCE 3/22/12 fine, no changes. triple checked with genesis ____
include MScell/channels/KaS			//double checked RCE 3/22/12 fine, no changes. triple checked with genesis _____
include MScell/channels/Krp			//adjusted 3/22/12 RCE double checked _____ triple checked with genesis _____

//calcium channels
include MScell/channels/CaL12CDI  	//adjusted 3/20/12 RCE double checked _______  triple checked with genesis _____
include MScell/channels/CaL13CDI  	//adjusted 3/20/12 RCE double checked _______ triple checked with genesis _____
include MScell/channels/CaNCDI		  //adjusted 3/20/12 RCE double checked _______ triple checked with genesis _____
include MScell/channels/CaRCDI		  //adjusted 3/20/12 RCE double checked _______ triple checked with genesis _____
include MScell/channels/CaT32 	 	 //adjusted 3/20/12 RCE double checked _______ triple checked with genesis _____
include MScell/channels/CaT33 	 	 //adjusted 3/20/12 RCE double checked _______ triple checked with genesis _____



//calcium dependent potassium channels
include MScell/channels/BK			//double checked RCE 3/22/12 fine, no changes made.  
include MScell/channels/SK			//double checked RCE 3/23/12 fine, no changes made.  
include MScell/channels/GABA_tonic	
