.macro _usb_reg name, offset
def USB0_\name, 0x40072000 + \offset, 8
.endm

_usb_reg PERID, 0x0
_usb_reg IDCOMP, 0x4
_usb_reg REV, 0x8
_usb_reg ADDINFO, 0xC
_usb_reg OTGISTAT, 0x10
_usb_reg OTGICR, 0x14
_usb_reg OTGSTAT, 0x18
_usb_reg OTGCTL, 0x1C
_usb_reg ISTAT, 0x80
.equiv STALL, 7
.equiv ATTACH, 6
/* .equiv RESUME, 5 */
.equiv SLEEP, 4
.equiv TOKDNE, 3
.equiv SOFTOK, 2
.equiv ERROR, 1
.equiv USBRST, 0

_usb_reg INTEN, 0x84
.equiv STALLEN, 7
.equiv ATTACHEN, 6
.equiv RESUMEEN, 5
.equiv SLEEPEN, 4
.equiv TOKDNEEN, 3
.equiv SOFTOKEN, 2
.equiv ERROREN, 1
.equiv USBRSTEN, 0

_usb_reg ERRSTAT, 0x88
.equiv BTSERR, 7
.equiv DMAERR, 5
.equiv BTOERR, 4
.equiv DFN8, 3
.equiv CRC16, 2
.equiv CRC5EOF, 1
.equiv PIDERR, 0

_usb_reg ERREN, 0x8C
.equiv BTSERREN, 7
.equiv DMAERREN, 5
.equiv BTOERREN, 4
.equiv DFN8EN, 3
.equiv CRC16EN, 2
.equiv CRC5EOFEN, 1
.equiv PIDERREN, 0

_usb_reg STAT, 0x90
.equiv ENDP, 4
.equiv TX, 3
.equiv ODD, 2

_usb_reg CTL, 0x94
.equiv JSTATE, 7
.equiv SE0, 6
.equiv TXSUSPENDTOKENBUSY, 5
.equiv RESET, 4
.equiv HOSTMODEEN, 3
.equiv RESUME, 2
.equiv ODDRST, 1
.equiv USBENSOFEN, 0

_usb_reg ADDR, 0x98
_usb_reg BDTPAGE1, 0x9C
_usb_reg FRMNUML, 0xA0
_usb_reg FRMNUMH, 0xA4
_usb_reg TOKEN, 0xA8
_usb_reg SOFTHLD, 0xAC
_usb_reg BDTPAGE2, 0xB0
_usb_reg BDTPAGE3, 0xB4
.macro _usb_endpoints i=0, m=15
_usb_reg ENDPT\i, 0xC0 + (4 * \i)
.if \m - \i
.altmacro
_usb_endpoints %(\i + 1), \m
.noaltmacro
.endif
.endm
_usb_endpoints
.equiv HOSTWOHUB, 7
.equiv RETRYDIS, 6
.equiv EPCTLDIS, 4
.equiv EPRXEN, 3
.equiv EPTXEN, 2
.equiv EPSTALL, 1
.equiv EPHSHK, 0

_usb_reg USBCTRL, 0x100
.equiv SUSP, 7
.equiv PDE, 6

_usb_reg OBSERVE, 0x104
_usb_reg CONTROL, 0x108
.equiv DPPULLUPNONOTG, 4

_usb_reg USBTRC0, 0x10C
_usb_reg USBFRMADJUST, 0x114

