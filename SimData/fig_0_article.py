#!/usr/bin/env python
# -*- coding: utf-8 -*-
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import figure_formating as ff
import matplotlib.image as im
lines = ['darkgrey','k','grey','lightgrey']
fname = 'IF_UI_Pre_randseed_5757538_high_res_IF_Vm_plasticity.txt'
titles = ['A. Morphology', 'B. Calcium diffusion', 'C. Electric properties']
f = ['neuron.png', 'diff.png']
if __name__ == '__main__':
    fig = plt.figure(figsize=(3.3,8) )
    ax = []
    ax.append(fig.add_subplot(3,1,1))
    ax.append(fig.add_subplot(3,1,2))
    ax.append(fig.add_subplot(3,1,3))
    for i,x in enumerate(ax[:-1]):
        im0 = im.imread(f[i])
        x.imshow(im0,aspect='auto')
        x.axes.get_xaxis().set_visible(False)
        x.axes.get_yaxis().set_visible(False)
        x.set_frame_on(False)
    f = open(fname)
    header = f.readline().split()
    data = None
    i = -1
    for line in f:
        if line.startswith('/new'):
            if data and i <3:
                dane = np.array(data)
                ax[2].plot(1000*dane[:,0], 1000*dane[:,1],lines[i],label = curr)
            i +=1
            data = []

        
        elif line.startswith('/plot'):
            curr = str(int(float(line.split(' ')[-2])*1000))+' pA'
            print curr
        else:
            
            data.append([float(line.split()[0]),float(line.split()[1])])
    ax[2].legend(frameon=False,loc=2)
    ax[2].set_xlabel('Time (ms)')
    ax[2].set_ylabel('$\mathrm{V_m}$ (mV)')
    for i, x in enumerate(ax):
        ff.add_title(x,titles[i])
        ff.simpleaxis(x)
    out_name = 'Fig_0'
    plt.savefig(out_name+'.png',format='png', bbox_inches='tight',pad_inches=0.1,dpi=400)
    plt.savefig(out_name+'.pdf',format='pdf', bbox_inches='tight',pad_inches=0.1,dpi=600)
    plt.savefig(out_name+'.svg',format='svg', bbox_inches='tight',pad_inches=0.1,dpi=600)
    plt.show()
