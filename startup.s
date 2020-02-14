.include "prelude.s"
.include "sim.s"
.include "osc.s"
.include "mcg.s"

.section vectors

.4byte stack_top
.4byte reset_isr
.fill 1, 4
.4byte hardfault_isr
.fill 12, 4

.fill 12, 4
.4byte uart0_isr
.fill 11, 4
.4byte usb_isr
.fill 7, 4

.text

function reset_isr
  val r1, 0
  reg_write SIM_COPC, r1


  val r1, 1<<SC8P | 1<<SC2P | 1<<ERCLKEN
  reg_write OSC0_CR, r1

  val r1, 1<<LOCRE0 | 2<<RANGE0 | 1<<EREFS0
  reg_write MCG_C2, r1
  val r1, 2<<CLKS | 4<<FRDIV
  reg_write MCG_C1, r1

  val r2, 1<<OSCINIT0 | 2<<CLKST
  loop
    reg_read r1, MCG_S
    cmp r1, r2
  while ne

  val r1, 3<<PRDIV0
  reg_write MCG_C5, r1

  val r1, 1<<PLLS
  reg_write MCG_C6, r1

  adds r2, 1<<PLLST | 1<<LOCK0
  loop
    reg_read r1, MCG_S
    cmp r1, r2
  while ne

  val r1, 1<<OUTDIV1 | 1<<OUTDIV4
  reg_write SIM_CLKDIV1, r1

  val r1, 4<<FRDIV
  reg_write MCG_C1, r1

  adds r2, 1<<CLKST
  loop
    reg_read r1, MCG_S
    cmp r1, r2
  while ne

  val r1, 1<<UART0SRC | 1<<USBSRC | 1<<PLLFLLSEL | 6<<CLKOUTSEL
  reg_write SIM_SOPT2, r1

  b main
end

function hardfault_isr
  val r0, SIM_SCGC5_RO | 1<<PORTC
  reg_write SIM_SCGC5, r0

  call led

  loop
    val r0, 48000000 / 4
    loop
      subs r0, 1
    while ne
    call led_toggle
  end
end
