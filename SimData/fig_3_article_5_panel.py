#!/usr/bin/env python

import numpy as np
import matplotlib as mpl
from matplotlib._png import read_png
import calculate_weight as cw
import matplotlib.pyplot as plt
import figure_formating as ff

flist = [
    'Fino_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity.txt',
    'PandK_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.01_spine_plasticity.txt',
    'PandK_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.03_spine_plasticity.txt',
    'Shen_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.01_spine_plasticity.txt'
]
par_dist_weight = [
    'Fino_Pre_weights.txt',
    'Fino_Post_weights.txt',
    'PandK_Pre_weights.txt',
    'PandK_Post_weights.txt',
    'Shen_Pre_weights.txt',
    'Shen_Post_weights.txt'
]
PSP_1 = '1_PSP_UI_Pre_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_0_ISI_0.01_spine_plasticity.txt'
colors = ['k','darkslategrey','lightslategrey']
labels = ['Fino et al., 2010','Pawlak \& Kerr, 2008','Shen et al., 2008']
col = 'head_Ca1'
titles = ['A. Pre-Post', 'D. 1st pairing Pre-Post','B. Post-Pre', 'E. 1st pairing Post-Pre','C.  Weights','F. 1st pairing']
beg = 0.8
end = 1.05
TLTP = 0.46
TLTD = 0.2
labels2 = ['Ca','weight',r'$\mathrm{T_{LTP}}$',r'$\mathrm{T_{LTD}}$']
if __name__ == '__main__':


    fig = plt.figure(figsize=(6.7,8))
    ax = []
    ax.append(fig.add_subplot(3,2,1))
    ax.append(fig.add_subplot(3,2,2))
    ax.append(fig.add_subplot(3,2,3))
    ax.append(fig.add_subplot(3,2,4))
    ax.append(fig.add_subplot(3,2,5))
    ax.append(fig.add_subplot(3,2,6))
    ax4 = ax[1].twinx()
    ax5 = ax[3].twinx()
    for i,fname in enumerate(flist):
        f = open(fname)
        header = f.readline().split()
        data = np.loadtxt(f)
        
        spines = cw.parse_header(header)
        data2 = np.loadtxt(par_dist_weight[i],skiprows=1)
        
        sp = 'spine_1'
        dt = data[1,0]-data[0,0]
        beg_1= int(beg/dt)
        end_1 = int(end/dt)
        if i%2:
            ax[4].plot(data[::62,0],data[::62,spines[sp]['head_weight']],'--', color = colors[i/2])
            ax[5].plot(data2[:,0],data2[:,1],'--',color = colors[i/2])
            ax[3].plot(data2[:,0],1000*data2[:,2],'--',color = colors[i/2],label = labels[i/2])
            ax5.plot(data2[:,0],1000*data2[:,4],'d',color = colors[i/2],label = labels[i/2])
        else:
            ax[4].plot(data[::62,0],data[::62,spines[sp]['head_weight']], color = colors[i/2],label = labels[i/2])
            ax[5].plot(data2[:,0],data2[:,1],color = colors[i/2],label = labels[i/2])
            ax[1].plot(data2[:,0],1000*data2[:,2],color = colors[i/2],label = labels[i/2])
            ax4.plot(data2[:,0],1000*data2[:,3],'^',color = colors[i/2],label = labels[i/2])
        new_time = np.arange(-.1,.15,dt)


        
        if 'PandK' in fname:
            if 'Pre' in fname:
                ax2 = ax[0].twinx()
                ax2.plot(1000*new_time,data[beg/dt:end/dt,spines[sp]['head_weight']],'k-.' ,label = labels[i/2])
                ax[0].plot(1000*new_time,1000*data[beg/dt:end/dt,spines[sp][col]],'k',label = 'Ca')
                ax[0].plot(0,1,color = colors[i/2],label = 'Weight')
                ax[0].plot(1000*new_time,TLTP*np.ones(new_time.shape),':k',label = labels2[2])
                ax[0].plot(1000*new_time,TLTD*np.ones(new_time.shape),'--k',label = labels2[3])
                
                ax[0].set_ylabel(r'Ca ($\mu$M)')
                ax2.set_xlabel('Time (ms)')
                ax2.set_ylim([.98,1.04])
                ax[0].set_ylim([0, 6.])
                ax2.set_ylabel('Weight')
                #ax[0].legend()
            else:
                ax3 = ax[2].twinx()
                ax3.plot(1000*new_time,data[beg/dt:end/dt,spines[sp]['head_weight']],'k-.',label = labels[i/2])
                ax[2].plot(1000*new_time,1000*data[beg/dt:end/dt,spines[sp][col]],'k',label = 'Ca')
                psp = np.loadtxt(PSP_1,skiprows =1)
                new_dt = psp[1,0]-psp[0,0]
                print 1000*psp[beg/dt,0], 1000*psp[end/dt,0]
                new_time_psp = np.arange(-.1,.15,new_dt)
                ax[2].plot(1000*new_time_psp,1000*psp[beg/new_dt:end/new_dt,4],color = colors[i/2],label = 'Ca 1 PSP')
                ax[2].plot(0,1,'k-.',label = 'Weight')
                ax[2].plot(1000*new_time,TLTP*np.ones(new_time.shape),':k',label = labels2[2])
                ax[2].plot(1000*new_time,TLTD*np.ones(new_time.shape),'--k',label = labels2[3])
                ax[2].set_ylabel(r'Ca ($\mu$M)')
                ax[2].legend(frameon=False,handlelength=3)
                ax3.set_ylim([.98,1.04])
                ax3.set_xlabel('Time (ms)')
                ax[2].set_ylim([0.,2.])
                ax3.set_ylabel('Weight')
    for i, x in enumerate(ax):
        ff.add_title(x,titles[i])

    ax[0].set_xlabel('Time (ms)')
    ax[2].set_xlabel('Time (ms)')
    ax[4].set_xlabel('Time (s)')
    ax[4].set_xlim([0,100.])
    ax[1].set_xlabel(r'Stim. distance from soma ($\mu$m)')
    ax[3].set_xlabel(r'Stim. distance from soma ($\mu$m)')
    ax[1].set_ylabel(r'Peak Ca ($\mu$M)')
    ax[5].set_xlabel(r'Stim. distance from soma ($\mu$m)')
    ax[3].set_ylabel(r'Peak Ca ($\mu$M)')
    ax[4].set_ylabel('Weight')
    ax[5].set_ylabel('Weight')
    ax4.set_ylabel(r'Duration(Ca$>\mathrm{T_{LTP}}$) (ms)')
    ax5.set_ylabel(r'Duration($\mathrm{T_{LTD}}<$Ca$<\mathrm{T_{LTP}}$) (ms)')
    
    out_name = 'Fig_3'  
    ax[3].legend(frameon=False)
    fig.subplots_adjust(wspace=.55)
    fig.subplots_adjust(hspace=.5)
   
    plt.savefig(out_name+'.png',format='png', bbox_inches='tight',pad_inches=0.1)
    plt.savefig(out_name+'.pdf',format='pdf', bbox_inches='tight',pad_inches=0.1)
    plt.savefig(out_name+'.svg',format='svg', bbox_inches='tight',pad_inches=0.1)
    plt.show()
