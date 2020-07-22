# -*- coding: utf-8 -*-
from __future__ import print_function, division

"""
Script to Run GABA Variation of Constrained Upstate.
For each variation, edit the PSim_ConstrainUp_GABA.g" file
Runs simulations in parallel using number of pools specified

@author: dandorman
"""

import os
import multiprocessing as mp
import numpy as np
import scipy
from matplotlib import pyplot as plt
import time
import glob

command = "genesis PSim_ConstrainUp_GABA.g"
          
fn = command[8:]

tempdir = '.tempScripts'

if not os.path.exists(tempdir):
    os.makedirs(tempdir)


gabatypes = ["0","1"] #0 is fast, 1 is slow
gabadelays = ["-100e-3","-50e-3","-25e-3","-12.5e-3","-6.75e-3","0e-3",
              "6.75e-3","12.5e-3","25e-3","50e-3","100e-3"]
gabalocs = ["primdend1","primdend2","secdend11","secdend12","tertdend1_1","tertdend1_2","tertdend1_3","tertdend1_4",
            "tertdend1_5","tertdend1_6","tertdend1_7","tertdend1_8","tertdend1_9","tertdend1_10","tertdend1_11"]

def readwritesim(fn,gabatype,gabadelay,gabaloc):
    with open(fn,'r') as f:
        text=[]
        for line in f:
            if "int numstim=" in line:
                newline = "int numstim="+str(16)+"\n"
                text.append(newline)
            elif 'str stimcomp=' in line:
                newline = 'str stimcomp="tertdend1_'+str(8)+'"\n'
                text.append(newline)
            elif 'str GABAloc =' in line:
                newline = 'str GABAloc = "'+gabaloc+'"\n'
                text.append(newline)
            elif "float GABA_delay =" in line:
                newline = "float GABA_delay = "+gabadelay+"\n"
                text.append(newline)
            elif "int GABAtype =" in line:
                newline = "int GABAtype = "+gabatype+"\n"
                text.append(newline)
            else:
                text.append(line)
        newfn = tempdir + '/' + fn[:-2] + gabaloc + gabadelay + gabatype + '.g'
    with open(newfn,'w') as f:
        f.writelines(text)
    newcommand = 'genesis ' + newfn
    time.sleep(10)
    pool.apply_async(os.system,args=(newcommand,))
    time.sleep(10)
    return    

pool=mp.Pool(processes=16)
pool.apply_async(os.system,args=('genesis PSim_ConstrainUp_NoGABAControl.g',))

for gabatype in gabatypes:
    for gabadelay in ["0e-3"]: ##gabadelays:
        readwritesim(fn,gabatype,gabadelay,"tertdend1_8")
    #for gabaloc in gabalocs:
    #    readwritesim(fn,gabatype,"0e-3",gabaloc)
        
        
