//genesis

//this is a function to create a file will all the important parameters for each simulation
//things like Mg concentration, CDI parameters, Fura parameters, NMDA parameters etc.


function Store_Parameters
	print "calciumdye=" {calciumdye}
	print "calciumtype=" {calciumtype}
	print "calciuminact=" {calciuminact}
	print "NMDAbuffermode=" {NMDAbuffermode}
	if (calciumdye == 1)
		print "Furaconc=" {btotal3} 
		print "FuraKf=" {Kf3}
		print "FuraKb=" {Kb3}
	elif (calciumdye == 2)
		print "Fluo5Fconc=" {btotal5}
		print "Fluo5FKf=" {Kf5}
		print "Fluo5FKb=" {Kb5}
    elif (calciumdye == 3)
		print "Fluo4conc=" {btotal6}
		print "Fluo4Kf=" {Kf6}
		print "Fluo4Kb=" {Kb6}
	end
	print "AMPAdes=" {AMPAdes}
	print "AMPAdestau=" {AMPAdestau}
	print "NMDAdes=" {NMDAdes}
	print "NMDAdestau=" {NMDAdestau}
	print "NMDAfracCa=" {NMDAperCa}
	print "nmdaKMg=" {KMg}
	print "nmdaGamma=" {gamma}
	print "Mgconc=" {CMg}


	
end
