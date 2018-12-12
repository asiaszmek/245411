//genesis


/***************************		MS Model, Version 9.1	*********************
**************************** 	      BK.g 	*********************
Rebekah Evans updated 3/22/12
******************************************************************************

*****************************************************************************/

function make_BK_channel
    float EK=-0.09  
    float K1=0.003
    float K4=0.009
  
  
	//tuned to fit Berkefeld et al., 2006 fig 3C for 10uM Ca, with positive shift for 1uM Ca and negative shift for 100uM Ca. 
    int xdivs = 299
    int ydivs = 2000 //increments of 5 nM from 0 to 100 uM calcium
    float xmin, xmax, ymin, ymax
    xmin = -0.1; xmax = 0.05; ymin = 0.0; ymax = 0.1 // x = Vm, y = [Ca],mM
    int i, j
    float x, dx, y, dy, a, b
    float Temp = 35
    float ZFbyRT = 23210/(273.15 + Temp)
    if (!({exists BK_channel}))
        create tab2Dchannel BK_channel
        setfield BK_channel Ek {EK} Gbar 0.0  \
            Xindex {VOLT_C1_INDEX} Xpower 1 Ypower 0 Zpower 0
        call BK_channel TABCREATE X {xdivs} {xmin} {xmax} \
            {ydivs} {ymin} {ymax}
    end
    dx = (xmax - xmin)/xdivs
    dy = (ymax - ymin)/ydivs
    x = xmin
    for (i = 0; i <= xdivs; i = i + 1)
        y = ymin
        for (j = 0; j <= ydivs; j = j + 1)
            a = 480*y/(y + {K1}*{exp {-0.84*ZFbyRT*x}}) 
            b = 280/(1 + y/({K4}*{exp {-1.00*ZFbyRT*x}}))
            setfield BK_channel X_A->table[{i}][{j}] {a}
            setfield BK_channel X_B->table[{i}][{j}] {a + b}
            y = y + dy
        end
        x = x + dx
    end
    setfield BK_channel X_A->calc_mode {LIN_INTERP}
    setfield BK_channel X_B->calc_mode {LIN_INTERP}
	//the tau curve that comes out of this is comparable (but not an exact fit) to Berkefeld 2006 figure 4A 10uM, if a qfact of 3 is applied to their figure.  
	//recordings in Berkefeld were at 22-24 degrees (supporting online material)
	
	
end



