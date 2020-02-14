.include "prelude.s"
.include "nvic.s"
.include "port.s"
.include "gpio.s"
.include "uart.s"

/* IN r0 - Destination address
 * IN r1 - Source address
 * IN r2 - Number of bytes to copy
 */
.global memcpy
function memcpy
  push {r4, r5, r6, r7}

  loop
    cmp r2, 16
  until lo
    ldm r1!, {r4, r5, r6, r7}
    stm r0!, {r4, r5, r6, r7}
    subs r2, 16
  end

  loop
    cmp r2, 1
  until lo
    ldrb r4, [r1]
    strb r4, [r0]
    adds r0, 1
    adds r1, 1
    subs r2, 1
  end

  pop {r4, r5, r6, r7}
  bx lr
end

.global uart_init
function uart_init
  /* 48Mhz clock / (300 * 16 default OSR) = 10000 baud */
  val r0, 300 >> 8
  reg_write UART0_BDH, r0

  val r0, 300 & 0xff
  reg_write UART0_BDL, r0

  val r0, 1<<12
  reg_write NVIC_ISER, r0

  bx lr
end

.global led
function led
  ldr r1, =(1<<MUX | 1<<DSE | 1<<SRE)
  reg_write PORTC_PCR5, r1

  movs r1, 1<<5
  reg_write GPIOC_PDDR, r1
  reg_write GPIOC_PDOR, r1

  bx lr
end

.global led_off
function led_off
  movs r1, 1<<5
  reg_write GPIOC_PCOR, r1
  bx lr
end

.global led_toggle
function led_toggle
  movs r1, 1<<5
  reg_write GPIOC_PTOR, r1
  bx lr
end
