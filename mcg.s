.macro _mcg_reg name, offset
def MCG_\name, 0x40064000 + \offset, 8
.endm

_mcg_reg C1, 0x0
.equiv CLKS, 6
.equiv FRDIV, 3
.equiv IREFS, 2
.equiv IRCLKEN, 1
.equiv IREFSTEN, 0

_mcg_reg C2, 0x1
.equiv LOCRE0, 7
.equiv FCFTRIM, 6
.equiv RANGE0, 4
.equiv HGO0, 3
.equiv EREFS0, 2
.equiv LP, 1
.equiv IRCS, 0

_mcg_reg C3, 0x2
.equiv SCTRIM, 0

_mcg_reg C4, 0x3
.equiv DMX32, 7
.equiv DRST_DRS, 5
.equiv FCTRIM, 1
.equiv SCFTRIM, 0

_mcg_reg C5, 0x4
.equiv PLLCLKEN0, 6
.equiv PLLSTEN0, 5
.equiv PRDIV0, 0

_mcg_reg C6, 0x5
.equiv LOLIE0, 7
.equiv PLLS, 6
.equiv CME0, 5
.equiv VDIV0, 0

_mcg_reg S, 0x6
.equiv LOLS0, 7
.equiv LOCK0, 6
.equiv PLLST, 5
.equiv IREFST, 4
.equiv CLKST, 2
.equiv OSCINIT0, 1
.equiv IRCST, 0

_mcg_reg SC, 0x8
.equiv ATME, 7
.equiv ATMS, 6
.equiv ATMF, 5
.equiv FLTPRSRV, 4
.equiv FCRDIV, 1
.equiv LOCS0, 0

_mcg_reg ATCVH, 0xA
_mcg_reg ATCVL, 0xB

_mcg_reg C7, 0xC
.equiv OSCSLE, 0

_mcg_reg C8, 0xD
.equiv LOLRE, 6
