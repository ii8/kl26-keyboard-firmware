.include "prelude.s"
.include "sim.s"
.include "port.s"
.include "gpio.s"
.include "uart.s"
.include "pins.s"
.include "keycodes.s"

.text

.global usb_isr
.equiv usb_isr, hang

.global uart0_isr
.equiv uart0_isr, hang

.global main
function main
  val r0, SIM_SCGC4_RO | 1<<UART0
  reg_write SIM_SCGC4, r0

  val r0, SIM_SCGC5_RO | 1<<PORTA | 1<<PORTB | 1<<PORTC | 1<<PORTD | 1<<PORTE
  reg_write SIM_SCGC5, r0

  .macro map side, pin, keycode
    .ifc \side, right
      port_cfg_map \pin, \keycode
    .endif
  .endm
  port_init
  .purgem map

  val r0, 4<<MUX
  reg_write PORTE_PCR20, r0
  call uart_init
  val r0, 1<<TE
  reg_write UART0_C2, r0

  val r4, 0
  val r5, 0

  loop
    .macro scan_action i
      .if \i < 32
        lsrs r2, r4, \i
      .else
        lsrs r2, r5, \i - 32
      .endif
      ands r2, r1
      eors r2, r0
      unless eq
        movs r0, \i
        reg_write UART0_D, r0

        .if \i < 32
          nz lsls, r2, \i
          eors r4, r2
        .else
          nz lsls, r2, \i - 32
          eors r5, r2
        .endif

        loop
          reg_read r0, UART0_S1
          lsrs r0, TDRE + 1
        while cc
      end
    .endm
    .macro map side, pin, keycode
      .ifc \side, right
        gpio_scan_map \pin, \keycode, r6
      .endif
    .endm
    gpio_scan r6
    .purgem map
  end
end

