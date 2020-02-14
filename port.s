.macro _port_pcr port, base, i=0, m=31
def PORT\port\()_PCR\i, \base + (4 * \i), 32
.if \m - \i
.altmacro
_port_pcr \port, \base, %(\i + 1), \m
.noaltmacro
.endif
.endm

.macro _port port, base
_port_pcr \port, \base
def PORT\port\()_GPCLR, \base + 0x80, 32
def PORT\port\()_GPCHR, \base + 0x84, 32
def PORT\port\()_ISFR, \base + 0xA0, 32
.endm

_port A 0x40049000
_port B 0x4004A000
_port C 0x4004B000
_port D 0x4004C000
_port E 0x4004D000

.equiv ISF, 24
.equiv IRQC, 16
.equiv MUX, 8
.equiv DSE, 6
.equiv PFE, 4
.equiv SRE, 2
.equiv PE, 1
.equiv PS, 0

.equiv GPWE, 16
.equiv GPWD, 0

.macro port_cfg_map pin, keycode
  .if PIN\pin\()_PORT == port
    .if ((high == 1 && PIN\pin\()_NUM >= 16) || (high == 0 && PIN\pin\()_NUM < 16))
      .set acc, acc | 1<<PIN\pin\()_NUM
    .endif
  .endif
.endm

/* IN r0 - desired Pin Control Register bits [15:0], will not be modified
 * OUT r1 - scratch register, contents undefined
 */
.macro port_cfg port
  .set port, \port
  .set acc, 0
  .set high, 0
  .include "keymap.s"
  .if acc > 0
    val r1, acc << GPWE
    orrs r1, r0
    reg_write PORT\port\()_GPCLR, r1
  .endif
  .set acc, 0
  .set high, 1
  .include "keymap.s"
  .if acc > 0
    val r1, acc
    orrs r1, r0
    reg_write PORT\port\()_GPCHR, r1
  .endif
.endm

.macro port_init
  val r0, 1<<MUX | 1<<PE | 1<<PS

  port_cfg A
  port_cfg B
  port_cfg C
  port_cfg D
  port_cfg E
.endm

