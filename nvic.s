def NVIC_ISER, 0xE000E100, 32
def NVIC_ICER, 0xE000E180, 32
def NVIC_ISPR, 0xE000E200, 32
def NVIC_ICPR, 0xE000E280, 32
.macro _nvic_ipr i=0, n=7
def NVIC_IPR\i, 0xE000E400 + (4 * \i), 32
.if \n - \i
.altmacro
_nvic_ipr %(\i + 1)
.noaltmacro
.endif
.endm
_nvic_ipr
