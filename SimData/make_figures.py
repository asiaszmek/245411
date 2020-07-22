import sys
import numpy as np
import matplotlib.pyplot as plt

if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.exit('Give me a filename')
    for fname in sys.argv[1:]:
        try:
            f = open(fname)
        except IOError:
            sys.exit('Could not open file')


    header = f.readline().split()
  
    data = np.loadtxt(f)
    dt = data[1,0]-data[0,0]
    for i,x in enumerate(header[1:]):
        
        if 'Fura' in x:
            mean = data[int(0.01/dt):int(0.09/dt),i+1].mean()
            print(x, (max(data[:,i+1])-mean)/mean)

        if x.endswith('Ca2') or x.endswith('Ca3') or x.endswith('CaMN') or x.endswith('CaMC') or x.endswith('calbindin') or 'neck' in x:
            pass
        else:
            plt.figure()
            plt.plot(1000*data[:,0],data[:,i+1])
            plt.xlabel('time [ms]')
            plt.title(x)
            plt.savefig(fname[:-4]+'_'+x.split('/')[-1]+'.png',format='png', bbox_inches='tight',pad_inches=0.1)

    plt.show()

