#!/usr/bin/env python
# -*- coding: utf-8 -*-
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import figure_formating as ff
texts = ['Fino et al., 2010','Pawlak and Kerr, 2008']
titles = ['A1. Peak Ca','A2. Peak Ca','B1. Ca above threshold', 'B2. Ca above threshold','C1. Weight ','C2. Weight']
fnames = [
    'Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISIs.txt',
    'No_L_Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISIs.txt',
    'No_NMDA_Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISIs.txt',
    'P_and_K_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISIs.txt',
    'No_L_P_and_K_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISIs.txt',
    'No_NMDA_P_and_K_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISIs.txt'
    ]
th_lo = .2e-3
th_hi = .46e-3
colors = ['k','slategrey','w','k','slategrey','w']
shapes = ['d','o','^']
labels = ['Ctrl','No L-types','No NMDA','Ctrl', 'No L-types','No NMDA']

if __name__ == '__main__':
    fig = plt.figure(figsize=(6.7,8))
    ax = []
    mini = 2.
    maxi = 0.
    ax.append(fig.add_subplot(3,2,1))
    ax.append(fig.add_subplot(3,2,2))
    ax.append(fig.add_subplot(3,2,3))
    ax.append(fig.add_subplot(3,2,4))
    ax.append(fig.add_subplot(3,2,5))
    ax.append(fig.add_subplot(3,2,6))
    print(ax)
    for i, fname in enumerate(fnames):
        print(fname)
        data = np.loadtxt(fname,skiprows=1)
        #data = data[1:-1,:]
        duration = np.zeros(data[:,0].shape)
        if 'Fino' in fname:
            
            data[:,0] = data[:,0]+0.03
            for j,d in enumerate(data[:,0]):
                if d > 0:
                    duration[j] = data[j,3]
                else:
                    duration[j] = data[j,4]
            ax[0].plot(1000*data[:,0],1000*data[:,2],shapes[i%3],color=colors[i],label = labels[i])
            ax[4].plot(1000*data[:,0],data[:,1],shapes[i%3],color=colors[i],label = labels[i])
            ax[2].plot(1000*data[:,0],1000*duration, shapes[i%3],color=colors[i],label = labels[i])
            
            
        else:
            for j,d in enumerate(data[:,0]):
                if d > 0:
                    duration[j] = data[j,3]
                else:
                    duration[j] = data[j,4]
                    
            ax[1].plot(1000*data[:,0],1000*data[:,2],shapes[i%3],color=colors[i],label = labels[i])

            ax[5].plot(1000*data[:,0],data[:,1],shapes[i%3],color=colors[i],label = labels[i])
            ax[3].plot(1000*data[:,0],1000*duration, shapes[i%3],color=colors[i],label = labels[i])
    
    ax[1].legend(loc=2,frameon=False)
   

    #ax[1].set_ylim([0.99,1.13])
    #ax[1].set_ylim([mini-0.005,1.04])
        
    ax[4].set_ylabel('Weight after 1st pairing')
    ax[5].set_ylabel('Weight after 1st pairing')
    ax[0].set_ylabel(r'Ca (\unsansmath$\mu$\sansmath M)')
    ax[1].set_ylabel(r'Ca (\unsansmath$\mu$\sansmath M)')
    ax[2].set_ylabel(r'Duration (ms)')
    ax[3].set_ylabel(r'Duration (ms)')
    ax[4].set_xlabel(r'\unsansmath$\Delta$\sansmath t (ms)') 
    ax[5].set_xlabel(r'\unsansmath$\Delta$\sansmath t (ms)') 
    ax[4].set_ylim([.99, 1.25])
    ax[5].set_ylim([.99, 1.025])
    
    #ax[0].set_yscale('log')
    #ax[1].set_yscale('log')
    for i,x in enumerate(ax):
        x.set_xlim([-105,105])
        ff.add_title(x,titles[i])
        ff.simpleaxis(x)
        if i == 2 or i == 3:
            y1 = x.get_ylim()
            y = np.arange(y1[0],y1[-1], 1.)
            xy = np.zeros(y.shape)
            x.plot(xy,y,'--k')
    
           
    #ax[1].set_xticks([])
    #ax[0].set_xticks([])
    fig.subplots_adjust(hspace=.3)
    fig.subplots_adjust(wspace=.3)
    out_name = 'Fig_4'
    lim_y_pre = 20
    lim_y_post = 10
    lim = 105
    ax[0].text(-lim+lim/5,lim_y_pre/4.*5,'Fino et al., 2010',fontsize=14)
    ax[1].text(-lim+lim/5,lim_y_post/4.*5,'Pawlak and Kerr, 2008',fontsize=14)
    plt.savefig(out_name+'.png',format='png', bbox_inches='tight',pad_inches=0.1)
    plt.savefig(out_name+'.pdf',format='pdf', bbox_inches='tight',pad_inches=0.1)
    plt.savefig(out_name+'.svg',format='svg', bbox_inches='tight',pad_inches=0.1)
    plt.show()
