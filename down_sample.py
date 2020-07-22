#Python program to read in the output of STDP simulations and output
#1. high res sample of one pairing
#2. low res sample of entire 6 sec simulation
#Since several different stim protocols, use glob on protocol name, e.g. Shen
import os
import numpy as np
from pylab import *
from string import *
import glob

prninfo=1
filetype=['Vm.txt', 'spine.txt']
init_sim=0.05
hi_res_rate=2    #This assumes dt = 0.02 ms, and empirically 0.04 ms is fine

try:
    #example: protocol="Venance 0.3 1000"
    prefix = protocol.split(' ')[0] #within python: define prefix as protocol
    stim_time=float(protocol.split(' ')[1])
    samplerate=int(protocol.split(' ')[2])
except NameError: #NameError refers to an undefined variable 
    prefix = sys.argv[1]
    stim_time=float(sys.argv[2])
    samplerate=int(sys.argv[3])

for suffix in filetype:
    pattern=prefix+'*'+suffix
    filenames = glob.glob(pattern)
    if prninfo:
        print(filenames)
    if (len(filenames)==0):
        print "***************Mistyped the filenames. Python found NO files:"
    else:
        for fnum,eachfile in enumerate(filenames): 
            f = open(eachfile, 'r+')
            dataheader=f.readline()
            data=loadtxt(eachfile,skiprows=1)
            if (prninfo==1):
                print eachfile, "\n", dataheader, "\n", data[0],data[1]
            else:
                print "header not printed"
            ignore=data.shape[0]%samplerate
            data=data[0:data.shape[0]-ignore]
            f.close()
            
            #calculate  dt, number of samples, samplerate
            dt=data[1][0]-data[0][0]
            one_stim_samples=int(stim_time/dt)
            start_samples=int(init_sim/dt)
            one_stim=data[start_samples:one_stim_samples:hi_res_rate]
            low_res=data[0::samplerate]
            
            #two output files for each input file
            outfname=eachfile[:-4]+"_one.txt"
            f=open(outfname,'w')
            savetxt(outfname, one_stim, fmt='%.5g', delimiter=' ', header=str(dataheader))
            f.close()
            
            outfname=eachfile[:-4]+"_low.txt"
            f=open(outfname,'w')
            savetxt(outfname, low_res, fmt='%.5g', delimiter=' ', header=str(dataheader))
            f.close()

