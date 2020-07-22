from __future__ import print_function, division
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 19 16:23:04 2018

@author: dandorman
"""

# Figure 7: GABA enhances spatial specificity

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.pyplot import cm
import matplotlib
import matplotlib.gridspec as gridspec

def set_style():
    matplotlib.style.reload_library()
#    plt.style.use(['seaborn-ticks', 'seaborn-paper-custom'])
    plt.style.use(['seaborn-ticks'])
    matplotlib.rc("font", family="Arial")


def format0(ax):
    ax.tick_params(which='both',right='off',top='off')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)


def format1(ax):
    ax.tick_params(axis='both',which='both',right='off',top='off',left='off',labelleft='off')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)


def format2(ax):
    ax.tick_params(axis='both',which='both',right='off',top='off',left='off',labelleft='off',bottom='off',labelbottom='off')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(False)


def set_size(fig,columnsize=2,hratio=1.618):
    # columnsize = 1, 1.5, or 2
    if columnsize==1:
        w = 10.0/2.54
    elif columnsize==2:
        w = 20.0/2.54
    else:
        w = 15.0/2.54
    h = w/hratio

    fig.set_size_inches(w,h,forward=True)


def make_spine_dict():
    ### Create Dictionary of Spine name and Spine Distance
    spine_names = []
    spine_distances =  []

    for q in range(16):
        for i in range(11):
            for j in [1,2,3,4,5,6]:
                for k in [1,2,3]:
                    if j == 1:
                        spine_names.append('celltertdend'+str(q+1)+'_'+str(i+1)+'spine_'+str(k))
                    else:
                        spine_names.append('celltertdend'+str(q+1)+'_'+str(i+1)+'_'+str(j)+'spine_'+str(k))

        ii = 26.0
        for i in range(11*6*3):
            ii = ii+1.0
            spine_distances.append(ii)

    spine_dict = dict(zip(spine_names,spine_distances))
    return spine_dict


def importGABA(simnames,labels):
    normdata={}
    for i,sim in enumerate(simnames):
        with open(sim+'spine.txt','r') as f:
            headers = f.readline().replace('/','').split()
            usenames = [header for header in headers if 'CaAvg' in header]
            sp=np.genfromtxt(sim+'spine.txt',names=True,usecols=usenames)
        with open(sim+'multispines.txt','r') as f:
            headers = f.readline().replace('/','').split()
            usenames = [header for header in headers if 'CaAvg' in header]
            msp=np.genfromtxt(sim+'multispines.txt',names=True,usecols=usenames)
        with open(sim+'Ca.txt','r') as f:
            headers = f.readline().replace('/','').split()
            usenames = [header for header in headers if 'CaAvg' in header]
            ca = np.genfromtxt(sim+'Ca.txt',names=True,usecols=usenames)
        spy = np.array([(spine_dict[b[:-len('headCaAvg')]],np.max(sp[b])) for b in sp.dtype.names if 'tertdend1_' in b and 'CaAvg' in b])
        mspy = np.array([(spine_dict[b[:-len('headCaAvg')]],np.max(msp[b])) for b in msp.dtype.names if 'tertdend1_' in b and 'CaAvg' in b])
        cay = np.array([(denddict[b[4:-len('CaAvg')]],np.max(ca[b])) for b in ca.dtype.names if 'tertdend1_' in b and 'CaAvg' in b])
        spymax=spy[:,1].max()
        spy[:,1]/=spymax
        mspy[:,1]/=spymax
        cay[:,1]/=spymax
        normdata[labels[i]]={'spy':spy,'mspy':mspy,'cay':cay}
    return normdata

def figureCaRatio(ax1,ax2):

    stimlist=[simDataPath+'PSim_ConstrainUp_noGABAcontrol_16spinesp3tertdend1_81.8e-05TimeDelay0Mirror_0BranchOffset_0_',
              simDataPath+'PSim_ConstrainUp_GABAAfast_tertdend1_8_0_16spinesp3tertdend1_81.8e-05TimeDelay0Mirror_0BranchOffset_0.1_',
              simDataPath+'PSim_ConstrainUp_GABAAslow_tertdend1_8_0_16spinesp3tertdend1_81.8e-05TimeDelay0Mirror_0BranchOffset_0.1_',
              ]
    labels=['Control','Fast GABA','Slow GABA']
    colors=[cm.gray(5/10.),cm.Reds(np.linspace(1,0,10))[1],cm.Reds(np.linspace(1,0,10))[4]]
    ax=ax1
    normdata=importGABA(stimlist,labels)
    handles = []
    for i,key in enumerate(normdata):
        spy = normdata[key]['spy']
        cay = normdata[key]['cay']
        mspy = normdata[key]['mspy']
        handle ,=ax.plot(mspy[:,0],mspy[:,1],label='',marker='s',markersize=4,c=colors[i])
        handles.append(handle)
        handle ,=ax2.plot(cay[:,0],cay[:,1],label='',marker='o',c=colors[i],markersize=4,linestyle=':',alpha=.9)
        handles.append(handle)
    ax.legend([handles[i] for i in [0,2,4]],labels,title='Non-Stim Spine',frameon=True,fancybox=True,loc='upper left')
    ax2.legend([handles[i] for i in [1,3,5]],labels,title='Dendrite',frameon=True,fancybox=True,loc='upper left')
    format0(ax)
    ax.set_xlabel(u'Distance from Soma (µm)',labelpad=0)
    ax.set_ylabel('Peak $\it{[Ca^{2+}]}$ / Stim Spine Peak $\it{[Ca^{2+}]}$',labelpad=0)
    ax.set_xlim([20,220])
    ax.set_ylim([-.01,.36])
    format1(ax2)
    ax2.set_xlabel(u'Distance from Soma (µm)',labelpad=0)
    ax2.set_xlim(ax.get_xlim())
    ax2.set_ylim([-.01,.36])
    return ax,normdata

spine_dict=make_spine_dict()
denddict = {'primdend1':11.7,'secdend11':24.7,'tertdend1_1':33.2,'tertdend1_2':51.2,
            'tertdend1_3':69.2,'tertdend1_4':87.2,'tertdend1_5':105.2,'tertdend1_6':123.2,
            'tertdend1_7':141.2,'tertdend1_8':159.2,'tertdend1_9':177.2,'tertdend1_10':195.2,'tertdend1_11':213.2}

set_style()
fig = plt.figure()
set_size(fig,columnsize=1.5)#1.5) # ,hratio=1.25)

gs = gridspec.GridSpec(1,2,bottom=.15,right=.98,top=.925,left=.15,wspace=.075)#,left=.1,right=.98,top=.93,bottom=.075,wspace=.3,hspace=.3)
axA = plt.subplot(gs[0])
axB = plt.subplot(gs[1])


axA.annotate('A', xy=(0, 1), xytext=(2,-2), fontsize=12,
    xycoords='figure fraction', textcoords='offset points',
    horizontalalignment='left', verticalalignment='top',fontweight='bold')
axB.annotate('B', xy=(.52, 1), xytext=(2,-2), fontsize=12,
    xycoords='figure fraction', textcoords='offset points',
    horizontalalignment='left', verticalalignment='top',fontweight='bold')

simDataPath = './SimData/'

ax,normdata=figureCaRatio(axA,axB)
fig.savefig('figure7A-B.png')
plt.show()
