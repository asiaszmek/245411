import numpy as np
import calculate_weight as cw
import matplotlib.pyplot as plt
import distance as dst
import figure_formating as ff
fnames = [
    
    [
       
        [
            'Fino_UI_Post_tertdend1_1_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_1_GABAtau2_0.0144_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_2_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_2_GABAtau2_0.0144_Stim_tertdend1_2_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_3_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_3_GABAtau2_0.0144_Stim_tertdend1_3_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_4_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_4_GABAtau2_0.0144_Stim_tertdend1_4_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_5_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_5_GABAtau2_0.0144_Stim_tertdend1_5_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_6_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_6_GABAtau2_0.0144_Stim_tertdend1_6_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_8_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_8_GABAtau2_0.0144_Stim_tertdend1_8_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_10_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_10_GABAtau2_0.0144_Stim_tertdend1_10_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_11_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_11_GABAtau2_0.0144_Stim_tertdend1_11_AP_1_ISI_-0.04_spine_plasticity.txt',

        ],
        [
            'Fino_UI_Pre_tertdend1_1_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_1_GABAtau2_0.0144_Stim_tertdend1_1_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_2_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_2_GABAtau2_0.0144_Stim_tertdend1_2_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_3_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_3_GABAtau2_0.0144_Stim_tertdend1_3_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_4_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_4_GABAtau2_0.0144_Stim_tertdend1_4_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_5_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_5_GABAtau2_0.0144_Stim_tertdend1_5_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_6_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_6_GABAtau2_0.0144_Stim_tertdend1_6_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_8_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_8_GABAtau2_0.0144_Stim_tertdend1_8_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_10_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_10_GABAtau2_0.0144_Stim_tertdend1_10_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_11_Ca_ext_2_tonic_gaba_gaba_delay_0.015__tertdend1_11_GABAtau2_0.0144_Stim_tertdend1_11_AP_1_ISI_0.04_spine_plasticity.txt',
        ]
        
    ],
    [
        [

            'Fino_UI_Post_tertdend1_1_Ca_ext_2_gaba_delay_0.015__tertdend1_1_GABAtau2_0.0144_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_2_Ca_ext_2_gaba_delay_0.015__tertdend1_2_GABAtau2_0.0144_Stim_tertdend1_2_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_3_Ca_ext_2_gaba_delay_0.015__tertdend1_3_GABAtau2_0.0144_Stim_tertdend1_3_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_4_Ca_ext_2_gaba_delay_0.015__tertdend1_4_GABAtau2_0.0144_Stim_tertdend1_4_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_5_Ca_ext_2_gaba_delay_0.015__tertdend1_5_GABAtau2_0.0144_Stim_tertdend1_5_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_6_Ca_ext_2_gaba_delay_0.015__tertdend1_6_GABAtau2_0.0144_Stim_tertdend1_6_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_8_Ca_ext_2_gaba_delay_0.015__tertdend1_8_GABAtau2_0.0144_Stim_tertdend1_8_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_10_Ca_ext_2_gaba_delay_0.015__tertdend1_10_GABAtau2_0.0144_Stim_tertdend1_10_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_11_Ca_ext_2_gaba_delay_0.015__tertdend1_11_GABAtau2_0.0144_Stim_tertdend1_11_AP_1_ISI_-0.04_spine_plasticity.txt',
        ],
        [
            
            'Fino_UI_Pre_tertdend1_1_Ca_ext_2_gaba_delay_0.015__tertdend1_1_GABAtau2_0.0144_Stim_tertdend1_1_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_2_Ca_ext_2_gaba_delay_0.015__tertdend1_2_GABAtau2_0.0144_Stim_tertdend1_2_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_3_Ca_ext_2_gaba_delay_0.015__tertdend1_3_GABAtau2_0.0144_Stim_tertdend1_3_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_4_Ca_ext_2_gaba_delay_0.015__tertdend1_4_GABAtau2_0.0144_Stim_tertdend1_4_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_5_Ca_ext_2_gaba_delay_0.015__tertdend1_5_GABAtau2_0.0144_Stim_tertdend1_5_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_6_Ca_ext_2_gaba_delay_0.015__tertdend1_6_GABAtau2_0.0144_Stim_tertdend1_6_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_8_Ca_ext_2_gaba_delay_0.015__tertdend1_8_GABAtau2_0.0144_Stim_tertdend1_8_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_10_Ca_ext_2_gaba_delay_0.015__tertdend1_10_GABAtau2_0.0144_Stim_tertdend1_10_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_11_Ca_ext_2_gaba_delay_0.015__tertdend1_11_GABAtau2_0.0144_Stim_tertdend1_11_AP_1_ISI_0.04_spine_plasticity.txt',
        ]

        
    ],
    [  
        [
            'Fino_UI_Post_tertdend1_1_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_2_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_2_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_3_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_3_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_4_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_4_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_5_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_5_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_6_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_6_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_8_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_8_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_10_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_10_AP_1_ISI_-0.04_spine_plasticity.txt',
            'Fino_UI_Post_tertdend1_11_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_11_AP_1_ISI_-0.04_spine_plasticity.txt',
        ],
        [
            'Fino_UI_Pre_tertdend1_1_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_1_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_2_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_2_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_3_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_3_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_4_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_4_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_5_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_5_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_6_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_6_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_8_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_8_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_10_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_10_AP_1_ISI_0.04_spine_plasticity.txt',
            'Fino_UI_Pre_tertdend1_11_Ca_ext_2_tonic_gaba_no_gaba_Stim_tertdend1_11_AP_1_ISI_0.04_spine_plasticity.txt',
            
        ]
    ],
    [
        'Fino_Post_weights.txt',
        'Fino_0.04_Pre_weights.txt'
    ]
    
]

gain_pot = 1100
gain_dep = 4500
post_thresh_hi = .46e-3
post_thresh_lo = .2e-3
depr_len = 0.032
pot_len = 0.002
col = 5

shape_line = ['--','-']
shape_symbol = ['d','^']
labels = [r'$\mathrm{GABA_A}$ present',r'phasic $\mathrm{GABA_A}$',r'tonic $\mathrm{GABA_A}$','ctrl']
shape = [':','-.','--','-']

titles = [r'A1. Duration(Ca$>\mathrm{T_{LTP}})$', r'A2. Duration(Ca$>\mathrm{T_{LTP}})$', r'B1. Duration$(\mathrm{T_{LTD}}<$Ca$<\mathrm{T_{LTP}})$', r'B2. Duration$(\mathrm{T_{LTD}}<$Ca$<\mathrm{T_{LTP}})$', r'C1. Weight', r'C2. Weight' ]
fnams = ['Fino_Post_gaba','Fino_Pre_gaba','Fino_Post_phasic','Fino_Pre_phasic','Fino_Post_tonic','Fino_Pre_tonic']
fnames_post = [['Fino_Post_gaba.txt','Fino_Pre_gaba.txt'],['Fino_Post_phasic.txt','Fino_Pre_phasic.txt'],['Fino_Post_tonic.txt','Fino_Pre_tonic.txt'],['Fino_Post_weights.txt','Fino_Pre_weights.txt']]
if __name__ == '__main__':

    fig = plt.figure(figsize=(6.7,8))
    ax = []

    for i in range(6):
        ax.append(fig.add_subplot(3,2,i+1))
    # twax = []
    # for i in range(3):
    #     twax.append(ax[i*2].twinx())

    for k, fnames_list in enumerate(fnames):
       
        for j,fname_list in  enumerate(fnames_list):
            if isinstance(fname_list,str):
                f = open(fname_list)
                header = f.readline()
                dat = np.loadtxt(f)
            else:
                syns = cw.go(fname_list,gain_pot,gain_dep,post_thresh_hi,post_thresh_lo,depr_len,pot_len,st=0.5)
                dat = np.zeros((len(syns),col))

                new_syns = [syn[0] for syn in syns]
                for i,syn in enumerate(new_syns):
            
                    dat[i,0] = dst.dist(syn.fname)
                    dat[i,1] = syn.weight[-1]
                    dat[i,2] = max(syn.Ca)
                    dat[i,3],dat[i,4] = dst.duration(syn.Ca,syn.dt)
                
                np.savetxt(fnams[2*k+j]+'.txt',dat,header="distance weight ca tltp tltd",comments='')            
                print(fnams[2*k+j]+'.txt')
            if j%2: #Pre-Post
                ax[0].plot(dat[:,0],1000*dat[:,3],shape[k],color='k',label=labels[k])
                ax[2].plot(dat[:,0],1000*dat[:,4],shape[k],color='k',label=labels[k])
                ax[4].plot(dat[:,0],dat[:,1],shape[k],color='k',label=labels[k])

            else:
                ax[1].plot(dat[:,0],1000*dat[:,3],shape[k],color='k',label=labels[k])
                ax[3].plot(dat[:,0],1000*dat[:,4],shape[k],color='k',label=labels[k])
                ax[5].plot(dat[:,0],dat[:,1],shape[k],color='k',label=labels[k])

 
                


    ax[4].set_xlabel(r'Distance from soma ($\mu$m)')
    ax[5].set_xlabel(r'Distance from soma ($\mu$m)')
    ax[0].set_ylabel(r'Time (ms)')
    ax[1].set_ylabel(r'Time (ms)')
    ax[2].set_ylabel(r'Time (ms)')
    ax[3].set_ylabel(r'Time (ms)')
    ax[4].set_ylabel('Weight')
    ax[5].set_ylabel('Weight')
    ax[2].legend(frameon=False,handlelength=3)
    ax[0].set_ylim([0,140])
    ax[1].set_ylim([0,140])
    ax[2].set_ylim([60,150])
    ax[3].set_ylim([60,150])
    
    #ax[2].legend(frameon=False)
    for i,x in enumerate(ax):
      
        ff.add_title(x,titles[i])
        ff.simpleaxis(x)
    fig.subplots_adjust(wspace=.55)
    fig.subplots_adjust(hspace=.4)
    lim = ax[0].get_xlim()
    lim_y_pre = ax[0].get_ylim()[-1]
    lim_y_post= ax[1].get_ylim()[-1]
    ax[0].text(lim[0]+lim[-1]/5,lim_y_pre/4.*5,'Pre then Post',fontsize=14)
    ax[1].text(lim[0]+lim[-1]/5,lim_y_post/4.*5,'Post then Pre',fontsize=14)
    plt.savefig('Fig_5.png',format='png', bbox_inches='tight',pad_inches=0.1)
    plt.show()
                    
