.macro _uart_reg name, offset
def UART0_\name, 0x4006A000 + \offset, 8
.endm

_uart_reg BDH, 0x0
_uart_reg BDL, 0x1
.equiv LBKDIE, 7
.equiv RXEDGIE, 6
.equiv SBNS, 5
.equiv SBR, 0

_uart_reg C1, 0x2
.equiv LOOPS, 7
.equiv DOZEEN, 6
.equiv RSRC, 5
.equiv M, 4
.equiv WAKE, 3
.equiv ILT, 2
/* .equiv PE, 1 */
.equiv PT, 0

_uart_reg C2, 0x3
.equiv TIE, 7
.equiv TCIE, 6
.equiv RIE, 5
.equiv ILIE, 4
.equiv TE, 3
.equiv RE, 2
.equiv RWU, 1
.equiv SBK, 0

_uart_reg S1, 0x4
.equiv TDRE, 7
.equiv TC, 6
.equiv RDRF, 5
.equiv IDLE, 4
.equiv OR, 3
.equiv NF, 2
.equiv FE, 1
.equiv PF, 0

_uart_reg S2, 0x5
.equiv LBKDIF, 7
.equiv RXEDGIF, 6
.equiv MSBF, 5
.equiv RXINV, 4
.equiv RWUID, 3
.equiv BRK13, 2
.equiv LBKDE, 1
.equiv RAF, 0

_uart_reg C3, 0x6
.equiv R8T9, 7
.equiv R9T8, 6
.equiv TXDIR, 5
.equiv TXINV, 4
.equiv ORIE, 3
.equiv NEIE, 2
.equiv FEIE, 1
.equiv PEIE, 0

_uart_reg D, 0x7

_uart_reg MA1, 0x8
_uart_reg MA2, 0x9
_uart_reg C4, 0xA
_uart_reg C5, 0xB
