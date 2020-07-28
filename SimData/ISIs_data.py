import glob
import numpy as np

fname_bases = ['Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI',
               'No_L_Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI',
               'No_NMDA_Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI',
               'P_and_K_UI_Pre_tertdend1_1_Ca_ext_2.5_no_gaba_Stim_tertdend1_1_AP_3_ISI',
               'No_L_P_and_K_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISI',
               'No_NMDA_P_and_K_UI_Pre_tertdend1_1_Ca_ext_2.5_no_gaba_Stim_tertdend1_1_AP_3_ISI'
]

th_lo = 0.2e-3
th_hi = 0.46e-3
def duration(data,dt):
   
    how_long_hi = 0
    how_long_lo = 0
    how_longhi = []
    how_longlo = []
    for i, ca in enumerate(data):
        if ca > th_hi:
            how_long_hi += dt
            if how_long_lo > 0:
                how_longlo.append(how_long_lo)
                how_long_lo = 0
        elif ca <=th_hi and ca > th_lo:
            how_long_lo += dt
            if how_long_hi > 0:
                how_longhi.append(how_long_hi)
                how_long_hi = 0
        else:
            if how_long_hi > 0:
                how_longhi.append(how_long_hi)
                how_long_hi = 0
            if how_long_lo > 0:
                how_longlo.append(how_long_lo)
                how_long_lo = 0
    if how_longhi == []:
        m_how_longhi = 0
    else:
        m_how_longhi = max(how_longhi)
        
    if how_longlo == []:
        m_how_longlo = 0
    else:
        m_how_longlo = max(how_longlo)
    return m_how_longhi, m_how_longlo



        
def get_fnames(fname_base):
    lista = glob.glob(fname_base+'*')
    result = []
    for l in lista:
        if l.endswith('spine_plasticity_spine_1_head_Ca1.txt'):
            result.append(l)

    return result
def find_isi(fname):
    return float(fname.split('ISI_')[-1].split('_')[0])
if __name__ == '__main__':
    for fname_base in fname_bases:
        fnames = get_fnames(fname_base)
        fnames.sort()
        res = np.zeros((len(fnames),5))
        for i,fname in enumerate(fnames):
            print(fname)
            res[i,0] = find_isi(fname)
            f = open(fname)
            header = f.readline().split()
            data = np.loadtxt(f)
            which = [j for j,x in enumerate(header) if 'weight' in x][0]
            which2 = [j for j,x in enumerate(header) if 'Ca' in x][0]
            dt = data[1,0]-data[0,0]
            long_hi,long_lo = duration(data[:,which2],dt)
            res[i,1] = data[-1,which]
            res[i,2] =  data[:,which2].max()
            res[i,3] = long_hi
            res[i,4] = long_lo
        #print res
        print(fname_base+'s.txt')
        np.savetxt(fname_base+'s.txt',res,comments='',header='ISI weight')
