.macro _gpio_port port, base
def \port\()_PDOR, \base, 32
def \port\()_PSOR, \base + 0x4, 32
def \port\()_PCOR, \base + 0x8, 32
def \port\()_PTOR, \base + 0xC, 32
def \port\()_PDIR, \base + 0x10, 32
def \port\()_PDDR, \base + 0x14, 32
.endm

.macro _gpio_ports prefix, base
_gpio_port \prefix\()A, \base
_gpio_port \prefix\()B, (\base + 0x40)
_gpio_port \prefix\()C, (\base + 0x80)
_gpio_port \prefix\()D, (\base + 0xC0)
_gpio_port \prefix\()E, (\base + 0x100)
.endm

_gpio_ports GPIO, 0x400FF000
_gpio_ports FGPIO, 0xF8000000

.macro gpio_scan_map pin, keycode, r_pdir
  .if PIN\pin\()_PORT == port
    lsrs r0, \r_pdir, PIN\pin\()_NUM
    ands r0, r1
    .if \keycode >= 224 && \keycode <= 231
      scan_action (\keycode - 224)
    .elseif \keycode >= 4 && \keycode <= 27
      scan_action (8 + (\keycode - 4))
    .elseif \keycode >= 28 && \keycode <= 45
      scan_action ((\keycode - 28) + 32)
    .else
      .error "Keycode \keycode out of bounds."
    .endif
  .endif
.endm

.macro gpio_scan_port port, r_pdir
  val \r_pdir, FGPIO\port\()_PDIR
  ldr \r_pdir, [\r_pdir]
  mvns \r_pdir, \r_pdir
  .set port, \port
  .include "keymap.s"
.endm

.macro gpio_scan, r_pdir
  val r1, 1
  gpio_scan_port A, \r_pdir
  gpio_scan_port B, \r_pdir
  gpio_scan_port C, \r_pdir
  gpio_scan_port D, \r_pdir
  gpio_scan_port E, \r_pdir
.endm
