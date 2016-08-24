# ng.py
def genData():
    import CoolProp.CoolProp as CP
    import numpy as np

    fluid       = 'R50&R170&R728&R290&R600&R600a'
    fractions   = [0.8770,0.0540,0.031,0.0260,0.0080,0.0040]

    HEOS = CP.AbstractState('HEOS',fluid)
    HEOS.set_mole_fractions(fractions)
    try:
        HEOS.build_phase_envelope("dummy")
        PE = HEOS.get_phase_envelope_data()
    except ValueError as VE:
        print(VE)
    NT = 500
    Np = 500
    T = np.linspace(-200,100,NT+1)
    p = np.linspace(45e5,70e5,Np+1)
    h = np.zeros((NT+1,Np+1))

    for i in range(0,Np+1):
        for j in range(0,NT+1):
            HEOS.update(CP.PT_INPUTS, p[Np-i], T[NT-j]+273.15)
            h[NT-j,Np-i] = HEOS.hmass()

    np.savetxt('p.txt',p)
    np.savetxt('T.txt',T)
    np.savetxt('h.txt',h)
