//genesis
//synaptic_channel.g

function make_synaptic_channel(chanpath, tau1, tau2, gmax, Ek, depr, deprtau)
    str chanpath
    float tau1
    float tau2
    float gmax 
    float Ek
    float depr
    float deprtau

    echo "### make_synaptic_channel, chanpath = "{chanpath} "tau1 = "{tau1} "tau2 = "{tau2} "gmax = "{gmax}

    if ({plastYesNo}==1 && {chanpath}=="AMPA")

        if ({desensYesNo}==1)
            create caplas_tm_synchan {chanpath}
            setfield {chanpath} tau1 {tau1} \
                tau2 {tau2}\ 
                gmax {gmax}\
                Ek {Ek} \
                fac_depr_on 1 \
                depr_per_spike {depr} \
                depr_tau {deprtau} \
                min_weight 0 \
                max_weight 2 \
                post_thresh_hi {post_thresh_hi} \
                post_thresh_lo {post_thresh_lo} \
                dur_hi {dur_hi}\
                dur_lo {dur_lo}\
                weight_change_rate_pot 600.0  \
                weight_change_rate_dep 4000.0  \
                post_tau 10e-3 
        else
            create caplas_synchan {chanpath}
            setfield {chanpath} tau1 {tau1} \
                tau2 {tau2}\ 
                gmax {gmax}\
                Ek {Ek} \
                min_weight 0 \
                max_weight 2 \
                post_thresh_hi {post_thresh_hi} \
                post_thresh_lo {post_thresh_lo} \
                dur_hi {dur_hi}\
                dur_lo {dur_lo}\
                weight_change_rate_pot 1100.0  \
                weight_change_rate_dep 4500.0  \
                post_tau 10e-3 
        
		end	
    elif ({plastYesNo}==0 && {chanpath}=="AMPA")
        if  ({desensYesNo}==1)
            create facsynchan {chanpath}
            setfield {chanpath} tau1 {tau1} \
                tau2 {tau2}\ 
                gmax {gmax}\
                Ek {Ek} \
                fac_depr_on 1 \
                depr_per_spike {depr} \
                depr_tau {deprtau}
        else
            create synchan {chanpath}
            setfield {chanpath} tau1 {tau1} \
                tau2 {tau2}\ 
                gmax {gmax}\
            Ek {Ek}
        end
        //rate changes at no more that 1.0/s
        //post_tau - shape of stdp curve? - depends on calcium curve
    else
        create synchan {chanpath}
        setfield {chanpath} tau1 {tau1} \
                       tau2 {tau2}\ 
                       gmax {gmax}\
                        Ek {Ek}
    end
end
