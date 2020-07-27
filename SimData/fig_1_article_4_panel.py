#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors
import matplotlib
import figure_formating as ff

maxi  = 0.3 #mM
mini = 0.00645 #mM
kd = 2.3 #uM
titles = ['A. 1 PSP', 'B. 3 AP','C. Pre then Post','D. Post then Pre']
colors = ['k','k','k','gray','k']
lines = ['-','--','-.',':','-']
colors_exp = ['k','k']
lines_exp = ['-',':']
labels_exp = ['spine','tertdend']
labels_3AP = ['spine','dendrite']
labels_shindou = ['stim. spine $44\,\mu$m','dendrite $44\,\mu$m','stim. spine $80\,\mu$m','dendrite $80\,\mu$m']
labels_spine = ['spine  $44\,\mu$m','spine $224\,\mu$m']
heads = [ [['/cell/tertdend1_1/spine_1/head/Fluo5F_Vavg'],['/cell/tertdend1_1/Fluo5F_Vavg']],[['/cell/tertdend1_3/spine_1/head/Fluo5F_Vavg'],['/cell/tertdend1_3/Fluo5F_Vavg']]]

heads_3AP= [ ['/cell/secdend11/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_1/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_2/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_3/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_4/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_5/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_6/spine_1/head/Fluo5F_Vavg','/cell/tertdend1_7/spine_1/head/Fluo5F_Vavg'],['/cell/soma/Fluo5F_Vavg','/cell/primdend1/Fluo5F_Vavg','/cell/secdend11/Fluo5F_Vavg','/cell/tertdend1_1/Fluo5F_Vavg','/cell/tertdend1_2/Fluo5F_Vavg','/cell/tertdend1_3/Fluo5F_Vavg','/cell/tertdend1_4/Fluo5F_Vavg','/cell/tertdend1_5/Fluo5F_Vavg','/cell/tertdend1_6/Fluo5F_Vavg','/cell/tertdend1_7/Fluo5F_Vavg']]

heads_1PSP = [['/cell/tertdend1_1/spine_1/head/Fluo5F_Vavg'],['/cell/tertdend1_11/spine_1/head/Fluo5F_Vavg']]

x_3AP = [np.array([26,44,62,80,98,116,134,152]),np.array([0,12,26,44,62,80,98,116,134,152])]

if __name__ == '__main__':
    #endings = ['Ca_Fluo_5f_plasticity.txt','spine_plasticity.txt']#_Ca_Fluo_5f.txt']#,['Vm_plasticity_Ca_Fluo_5f.txt','spine_plasticity_Ca_Fluo_5f.txt']]
    fname_list = [
        
        
            ['1_PSP_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_0_ISI_0.04_',
            '1_PSP_UI_Pre_tertdend1_11_Ca_ext_2_no_gaba_Stim_tertdend1_11_AP_0_ISI_0.04_'],
            ['3_AP_UI_Pre_Ca_ext_2_no_gaba_Stim_secdend11,tertdend1_1,tertdend1_2,tertdend1_3,tertdend1_4,tertdend1_5,tertdend1_6,tertdend1_7_AP_3_ISI_0.01_'],
            ['Shindou_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.01_',
            'Shindou_UI_Pre_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_3_ISI_0.01_'],
            ['Shindou_UI_Post_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.03_',
             'Shindou_UI_Post_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_3_ISI_-0.03_'
            ]
        
    ]
    fnames_exp = [
        'ca_shindou_1_PSP_',
        'ca_shindou_3_AP_',
        'ca_shindou_pre_post_',
        'ca_shindou_post_pre_'
    ]
    endings = [
        [
            'spine_plasticity.txt'
            ],
        [
            'spine_plasticity_Ca_Fluo_5f.txt',
            'Ca_Fluo_5f_plasticity.txt'
            ],
        [
            'spine_plasticity.txt','Ca_Fluo_5f_plasticity.txt'
            ],
        [
            'spine_plasticity.txt','Ca_Fluo_5f_plasticity.txt'
            ]
            
    ]
    fig = plt.figure(figsize=(3.3,8.))
    ax = []
    ax.append(fig.add_subplot(4,1,1))
    ax.append(fig.add_subplot(4,1,2))
    ax.append(fig.add_subplot(4,1,3))
    ax.append(fig.add_subplot(4,1,4))

    m = 0
    m_exp = 0
    for i,fnames in enumerate(fname_list):
        which  = i
        results = []
        for ind,fname in enumerate(fnames):
            if '1_PSP' in fname:
                labels = labels_spine
            else:
                labels = labels_shindou
            for j,ending in enumerate(endings[i]):
                print(fname+ending)
                f = open(fname+ending)
                header = f.readline().split()
                data = np.loadtxt(f)
                if fname.startswith('3_AP'):
                    head = heads_3AP[j]
                    
                    results.append([])
                elif '1_PSP' in fname:
                    head = heads_1PSP[ind]
                else:
                    head = heads[ind][j]

                time  = data[:,0]
                for k,x in enumerate(head):
                    dt = time[1]-time[0]
                    beg = int(0.8/dt)
                    end = int(1.5/dt)
                    
                    indx = header.index(x)

                    basal = data[0:int(0.8/dt),indx].mean()
                    dat = kd *(data[:,indx]- basal)/(maxi-mini-(data[:,indx]-basal))
                    if fname.startswith('3_AP'):
                        
                        results[j].append(dat.max())

                    else:
                        results.append(dat)                        
                        
       
        new_time = 1000*np.arange(-.1,.6,dt)
        print fname
        if  fname.startswith('3_AP'):
            for k,r in enumerate(results):
                #res = np.array(r)
                print len(x_3AP[k]),len(r)
                ax[i].plot(x_3AP[k],r,lines[k],color=colors[k],label=labels_3AP[k])
        else:
            for k,dat in enumerate(results):

                if m < dat.max():
                    m = dat.max()
           
                ax[i].plot(new_time,dat[beg:end],lines[k],color = colors[k],label=labels[k])
            
   
        if fname.startswith('3_AP'):
            ax[i].set_ylabel(r"max Ca ($\mu$M)")
            ax[i].set_xlabel(r"distance from soma ($\mu$m)")

        else:
            ax[i].set_ylabel(r"Ca ($\mu$M)")
            ax[i].set_xlabel('Time (ms)')
        ax[i].legend(loc=1, frameon=False,handlelength=3)
        
        fname = 'Fig_1'
        


    
    for i,x in enumerate(ax):
        
        if i != 1 and i!= 0:
            x.set_ylim([0,m*1.1])
            x.yaxis.set_ticks([0.,0.2,0.4])
        elif i == 0:
            x.yaxis.set_ticks([0.,0.03,0.06])
        else:
            x.yaxis.set_ticks([0.,0.1,0.2])
  
        ff.add_title(x,titles[i])
        ff.simpleaxis(x)
    
  
  
    fig.subplots_adjust(hspace=.55)
    #fig.subplots_adjust(wspace=.6)
    
    plt.savefig('Fig_1.png',format='png', bbox_inches='tight',pad_inches=0.1)
    plt.savefig('Fig_1.svg',format='svg', bbox_inches='tight',pad_inches=0.1)
    plt.savefig('Fig_1.pdf',format='pdf', bbox_inches='tight',pad_inches=0.1)

    plt.show()
            
            
