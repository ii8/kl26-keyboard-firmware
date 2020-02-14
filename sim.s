.macro _sim_reg name, offset
def SIM_\name, 0x40047000 + \offset, 32
.endm

_sim_reg SOPT1, 0x0
.equiv USBREGEN, 31
.equiv USBSSTBY, 30
.equiv USBVSTBY, 29
.equiv OSC32KSEL, 18

_sim_reg SOPT1CFG, 0x4
.equiv USSWE, 26
.equiv UVSWE, 25
.equiv URWE, 24

_sim_reg SOPT2, 0x1004
.equiv UART0SRC, 26
.equiv TPMSRC, 24
.equiv USBSRC, 18
.equiv PLLFLLSEL, 16
.equiv CLKOUTSEL, 5
.equiv RTCCLKOUTSEL, 4

_sim_reg SOPT4, 0x100C
.equiv TPM2CLKSEL, 26
.equiv TPM1CLKSEL, 25
.equiv TPM0CLKSEL, 24
.equiv TPM2CH0SRC, 20
.equiv TPM1CH0SRC, 18

_sim_reg SOPT5, 0x1010
.equiv UART2ODE, 18
.equiv UART1ODE, 17
.equiv UART0ODE, 16
.equiv UART1RXSRC, 6
.equiv UART1TXSRC, 4
.equiv UART0RXSRC, 2
.equiv UART0TXSRC, 0

_sim_reg SOPT7, 0x1018
.equiv ADC0ALTTRGEN, 7
.equiv ADC0PRETRGSEL, 4
.equiv ADC0TRGSEL, 0

_sim_reg SDID, 0x1024

_sim_reg SCGC4, 0x1034
.equiv SPI1, 23
.equiv SPI0, 22
.equiv CMP, 19
.equiv USBOTG, 18
.equiv UART2, 12
.equiv UART1, 11
.equiv UART0, 10
.equiv I2C1, 7
.equiv I2C0, 6
.equiv SIM_SCGC4_RO, 0xf<<28 | 0x3<<4

_sim_reg SCGC5, 0x1038
.equiv PORTE, 13
.equiv PORTD, 12
.equiv PORTC, 11
.equiv PORTB, 10
.equiv PORTA, 9
.equiv TSI, 5
.equiv LPTMR, 0
.equiv SIM_SCGC5_RO, 0x3<<7 | 0x1<<1

_sim_reg SCGC6, 0x103C
.equiv DAC0, 31
.equiv RTC, 29
.equiv ADC0, 27
.equiv TPM2, 26
.equiv TPM1, 25
.equiv TPM0, 24
.equiv PIT, 23
.equiv I2S, 15
.equiv DMAMUX, 1
.equiv FTF, 0

_sim_reg SCGC7, 0x1040
.equiv DMA, 8

_sim_reg CLKDIV1, 0x1044
.equiv OUTDIV1, 28
.equiv OUTDIV4, 16

_sim_reg FCFG1, 0x104C
.equiv PFSIZE, 24
.equiv FLASHDOZE, 1
.equiv FLASHDIS, 0

_sim_reg FCFG2, 0x1050
.equiv MAXADDR0, 24
.equiv MAXADDR1, 16

_sim_reg UIDMH, 0x1058
_sim_reg UIDML, 0x105C
_sim_reg UIDL, 0x1060

_sim_reg COPC, 0x1100
.equiv COPT, 2
.equiv COPCLKS, 1
.equiv COPW, 0

_sim_reg SRVCOP, 0x1104
