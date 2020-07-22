import matplotlib as mpl
import matplotlib.pyplot as plt
#mpl.rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
#mpl.rc('font', family='Helvetica')
mpl.rcParams['text.latex.preamble'] = [
          r'\usepackage{helvet}',    # set the normal font here
       r'\usepackage{sansmath}',  # load up the sansmath so that math -> helvet
       r'\sansmath']#mpl.rc('text.latex', preamble=r'\usepackage{cmbright}')

mpl.rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
## for Palatino and other serif fonts use:
#rc('font',**{'family':'serif','serif':['Palatino']})
mpl.rc('text', usetex=True)
mpl.rcParams['axes.linewidth'] = 1.
mpl.rcParams['lines.linewidth'] = 1.
mpl.rcParams['patch.linewidth'] = 1.
mpl.rcParams.update({'font.size': 12})
plt.rc('legend',**{'fontsize':8})
plt.rc('ytick',**{'labelsize':10})
plt.rc('xtick',**{'labelsize':10})
#plt.legend(frameon=False)
def simpleaxis(ax):
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.get_xaxis().set_tick_params(direction='out', right=0, pad=1, width=1, length=2)
    ax.get_yaxis().set_tick_params(direction='out', top=0, pad=1, width=1, length=2)
    ax.get_xaxis().tick_bottom()


    #ax.minorticks_on()
    #ax.tick_params('both', length=2, width=1, which='major')
    #ax.tick_params('both', length=1, width=0.5, which='minor')
   
    
    
def add_title(ax,title):
    x = ax.get_xlim()
    left = x[0] - (x[-1] - x[0])/5.
    y = ax.get_ylim()
    up = y[-1]+(y[-1]-y[0])/13.

    ax.text(left,up,title)
