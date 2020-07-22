#!/usr/bin/env python

import numpy as np
import matplotlib as mpl
import matplotlib.image as im
import calculate_weight as cw
import matplotlib.pyplot as plt
import figure_formating as ff
from mpl_toolkits.axes_grid.inset_locator import inset_axes
imlist = ['fino_pre.svg.png',
          'fino_post.svg.png',
          'pandk_pre.svg.png',
          'pandk_post.svg.png',
          'shen_pre.svg.png',
          'shen_post.svg.png'
]
flist = [
    #'Fino_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.01_spine_plasticity_Ca_unnkown_dye.txt',
    #'Fino_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity_Ca_unnkown_dye.txt',
    #'PandK_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.01_spine_plasticity_Ca_unnkown_dye.txt',
    #'PandK_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.03_spine_plasticity_Ca_unnkown_dye.txt',
    #'Shen_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.005_spine_plasticity_Ca_unnkown_dye.txt',
    #'Shen_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.01_spine_plasticity_Ca_unnkown_dye.txt'
    'Fino_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity.txt',
    'PandK_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.01_spine_plasticity.txt',
    'PandK_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.03_spine_plasticity.txt',
    'Shen_UI_Pre_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Post_randseed_5757538_low_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.01_spine_plasticity.txt'  
]
colors = ['k','darkslategrey','lightslategrey']
labels = ['Fino et al., 2010','Pawlak \& Kerr, 2008','Shen et al., 2008']
col = 'head_Ca1'
beg = 0.8
end = 1.15
lim = 50
titles = ['A1. Fino et al., 2010','A2. Fino et al., 2010','B1. Pawlak \& Kerr, 2008','B2. Pawlak \& Kerr','C1. Shen et al., 2008','C2. Shen et al., 2008','D1. All paradigms','D2. All paradigms']
lim_y_pre = 30.
lim_y_post = 4.
if __name__ == '__main__':

    fig = plt.figure(figsize=(6.7,8.))
    ax = []
    ax.append(fig.add_subplot(4,2,1))
    ax.append(fig.add_subplot(4,2,2))
    ax.append(fig.add_subplot(4,2,3))
    ax.append(fig.add_subplot(4,2,4))
    ax.append(fig.add_subplot(4,2,5))
    ax.append(fig.add_subplot(4,2,6))
    ax.append(fig.add_subplot(4,2,7))
    ax.append(fig.add_subplot(4,2,8))
    for i,fname in enumerate(flist):
        f = open(fname)
        print(fname)
        header = f.readline().split()
        data = np.loadtxt(f)
        spines = cw.parse_header(header)
        sp = 'spine_1'
        dt = data[1,0]-data[0,0]
        beg_1= int(beg/dt)
        end_1 = int(end/dt)
       
        ax[i].plot(data[:,0],1000*data[:,spines[sp][col]],'k')#color=colors[i/2])
        ff.simpleaxis(ax[i])
        #img = im.imread(imlist[i])
        #ax_im = inset_axes(ax[i],width="50%",height=.5,loc=2)
        
        #ax_im.imshow(img)
        #ax_im.axes.get_xaxis().set_visible(False)
        #ax_im.axes.get_yaxis().set_visible(False)
        #ax_im.set_frame_on(False)
        new_time = np.arange(-100,250-dt*1000,dt*1000)
        ax[i].set_xlim([0,lim])
        if (i%2):

            ax[7].plot(new_time,1000*data[beg_1:end_1,spines[sp][col]],color=colors[i/2],label=labels[i/2])
            ax[i].set_ylim([0.0,lim_y_post])
            ax[i].set_yticks([0,1,2,3,4])
            ax[i].set_yticklabels(['0','1','2','3','4'])
            
        else:

            ax[6].plot(new_time,1000*data[beg_1:end_1,spines[sp][col]],color=colors[i/2],label=labels[i/2])
            ax[i].set_ylim([0.0,lim_y_pre])
            print(titles[i/2])
            ax[i].set_ylabel(r'Ca ($\mu$M)')

    for i,x in enumerate(ax):
        ff.add_title(x,titles[i])
        ff.simpleaxis(x)

    ax[6].set_xlabel('Time (s)')
    ax[7].set_xlabel('Time (s)')
    ax[7].legend(frameon=False)
    ax[6].set_ylabel(r'Ca ($\mu$M)') 
    ax[0].text(lim/5,lim_y_pre/4.*5,'Pre then Post',fontsize=14)
    ax[1].text(lim/5,lim_y_post/4.*5,'Post then Pre',fontsize=14)
    out_name = 'Fig_2'  
    
    fig.subplots_adjust(hspace=.3)
    plt.savefig(out_name+'.png',format='png', bbox_inches='tight',pad_inches=0.1)
    plt.savefig(out_name+'.pdf',format='pdf', bbox_inches='tight',pad_inches=0.1)
    plt.savefig(out_name+'.svg',format='svg', bbox_inches='tight',pad_inches=0.1)
    plt.show()
