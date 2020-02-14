.include "prelude.s"
.include "sim.s"
.include "port.s"
.include "gpio.s"
.include "nvic.s"
.include "usbotg.s"
.include "uart.s"
.include "usb.s"
.include "pins.s"
.include "keycodes.s"

.equiv BC, 16
.equiv OWN, 7
.equiv DATA01, 6
.equiv KEEP, 5
.equiv NINC, 4
.equiv DTS, 3
.equiv BDT_STALL, 2
def TOK_PID, 2, 4

.include "descriptors.s"

.bss
configuration:
  .space 1
.balign 4

setup_packet:
  .space 8

desc_dev_ram:
  .space desc_dev_end - desc_dev
.balign 4

desc_cfg_ram:
  .space desc_hid - desc_cfg
desc_hid_ram:
  .space desc_ep_end - desc_hid
.balign 4

desc_rep_ram:
  .space desc_rep_end - desc_rep
.balign 4

ep0_rx_buf:
ep0_rx_buf_even:
  .space 64
ep0_rx_buf_odd:
  .space 64
.balign 4

ep0_tx_next:
ep0_tx_next_odd:
  .space 1
ep0_tx_next_data:
  .space 1
.balign 4

ep1_tx_next_odd:
  .space 1
ep1_tx_next_data:
  .space 1
.balign 4

right_state:
  .space 8

.balign 16
ep1_tx_buf:
ep1_tx_buf_even:
  .space 8
ep1_tx_buf_odd:
  .space 8

.balign 512
bdt:
bdt_ep0:
bdt_ep0_rx:
bdt_ep0_rx_even:
  .space 8
bdt_ep0_rx_odd:
  .space 8
bdt_ep0_tx:
bdt_ep0_tx_even:
  .space 8
bdt_ep0_tx_odd:
  .space 8
bdt_ep1:
bdt_ep1_rx:
bdt_ep1_rx_even:
  .space 8
bdt_ep1_rx_odd:
  .space 8
bdt_ep1_tx:
bdt_ep1_tx_even:
  .space 8
bdt_ep1_tx_odd:
  .space 8

.text

.macro case_setup reg, dir, type, recipient, bRequest, block
  case \reg, (\dir << 7 | \type << 5 | \recipient) | \bRequest << 8, \block
.endm

.global main
function main
  val r0, SIM_SCGC4_RO | 1<<USBOTG | 1<<UART0
  reg_write SIM_SCGC4, r0

  val r0, SIM_SCGC5_RO | 1<<PORTA | 1<<PORTB | 1<<PORTC | 1<<PORTD | 1<<PORTE
  reg_write SIM_SCGC5, r0

  val r0, 0
  ldr r1, =right_state
  str r0, [r1]
  str r0, [r1, 4]

  call debounce_init

  .macro map side, pin, keycode
    .ifc \side, left
      port_cfg_map \pin, \keycode
    .endif
  .endm
  port_init
  .purgem map

  val r0, 4<<MUX
  reg_write PORTE_PCR21, r0
  call uart_init
  val r0, 1<<RIE | 1<<RE
  reg_write UART0_C2, r0

  call usb_init

  ldr r1, =configuration
  loop
    ldrb r0, [r1]
    cmp r0, 1
  until eq
    wfi
  end

  ldr r4, =ep1_tx_next_odd
  ldr r5, =bdt_ep1_tx
  loop
    ldrb r6, [r4]
    lsls r6, r6, 3
    adds r6, r5, r6 /* r6 = &bdt_ep1_tx(_odd) */
    ldr r1, [r6]
    lsrs r1, OWN + 1
    unless cs
      ldr r7, [r6, 4] /* r7 = &ep1_tx_buf(_odd) */
      loop
        mov r0, r7
        call scan
        cmp r0, 0
      while eq
      mov r0, r6 /* r0 = &bdt_ep1_tx(_odd) */
      mov r1, r4
      call ep1_tx
    else
      /* wait for a TOKDNE interrupt to give us the buffer */
      wfi
    end
  end
end

.global uart0_isr
function uart0_isr
  ldr r0, =right_state
  reg_read r1, UART0_D
  lsrs r2, r1, 5
  unless eq /* if r1 >= 32 */
    adds r0, 4
    subs r1, 32
  end
  ldr r3, [r0]
  val r2, 1
  lsls r2, r1
  eors r3, r2
  str r3, [r0]
  bx lr
end

function usb_init
  push {lr}

  ldr r0, =desc_dev_ram
  ldr r1, =desc_dev
  val r2, desc_dev_end - desc_dev
  call memcpy

  ldr r0, =desc_cfg_ram
  ldr r1, =desc_cfg
  val r2, desc_ep_end - desc_cfg
  call memcpy

  ldr r0, =desc_rep_ram
  ldr r1, =desc_rep
  val r2, desc_rep_end - desc_rep
  call memcpy

  ldr r2, =bdt
  lsrs r2, 8
  reg_write USB0_BDTPAGE1, r2
  lsrs r2, 8
  reg_write USB0_BDTPAGE2, r2
  lsrs r2, 8
  reg_write USB0_BDTPAGE3, r2

  val r0, 1<<6
  reg_write USB0_USBTRC0, r0

  val r0, 1<<DPPULLUPNONOTG
  reg_write USB0_CONTROL, r0

  val r0, 0
  reg_write USB0_USBCTRL, r0

  val r0, 1<<USBRSTEN
  reg_write USB0_INTEN, r0

  val r0, 1<<24
  reg_write NVIC_ISER, r0

  pop {pc}
end

.global usb_isr
function usb_isr
  reg_read r1, USB0_ISTAT
  case_lsb r1, 1, usbrst
  case_lsb r1, 3, tokdne
  case_lsb r1, 4 stall
  hang

  block usbrst
    val r0, 0
    ldr r1, =configuration
    strb r0, [r1]

    ldr r1, =ep0_tx_next
    strh r0, [r1]

    ldr r1, =bdt_ep0_tx
    str r0, [r1]
    str r0, [r1, 8]

    reg_write USB0_ADDR, r0

    val r0, 64<<BC | 1<<OWN | 1<<DTS
    ldr r1, =bdt_ep0_rx
    str r0, [r1]
    str r0, [r1, 8]

    ldr r0, =ep0_rx_buf
    str r0, [r1, 4] /* bdt_ep0_rx_even->addr = &ep0_rx_buf_even */
    adds r0, 64
    str r0, [r1, 12] /* bdt_ep0_rx_odd->addr = &ep0_rx_buf_odd */

    val r0, 1<<EPRXEN | 1<<EPTXEN | 1<<EPHSHK
    reg_write USB0_ENDPT0, r0

    val r0, 0xff
    reg_write USB0_ISTAT, r0

    val r0, 1<<STALLEN | 1<<TOKDNEEN | 1<<USBRSTEN
    reg_write USB0_INTEN, r0

    val r0, 1<<ODDRST | 1<<USBENSOFEN
    reg_write USB0_CTL, r0

    bx lr

  block tokdne
    push {lr}
    reg_read r0, USB0_STAT

    lsrs r1, r0, ENDP + 1
    unless cs
      call control
    end

    val r0, 1<<TOKDNE
    reg_write USB0_ISTAT, r0
    pop {pc}

  block stall
    val r0, 1<<EPRXEN | 1<<EPTXEN | 1<<EPHSHK
    reg_write USB0_ENDPT0, r0

    val r0, 1<<STALL
    reg_write USB0_ISTAT, r0
    bx lr
end

/* IN r0 - Contents of USB0_STAT
 */
function control
  push {r4, r5, lr}

  lsls r0, 1
  ldr r4, =bdt
  orrs r4, r0 /* r4 = buffer descriptor address */

  ldr r5, [r4] /* r5 = bd meta info */
  ext r5, r5, TOK_PID /* r5 = Packet ID */
  case r5, 0x1, out_pid
  case r5, 0x9, in_pid
  case r5, 0xD, setup_pid
  hang

  block out_pid
    val r0, 64<<BC | 1<<OWN | 1<<DATA01 | 1<<DTS
    str r0, [r4]

    b done

  block in_pid
    ldr r0, =setup_packet
    ldr r1, [r0]
    uxth r4, r1 /* r4 = bRequest, bmRequestType */
    case_setup r4, 0, 0, 0, SET_ADDRESS, set_address_complete
    b done
    block set_address_complete
      lsrs r2, r1, 16 /* r2 = wValue */
      reg_write USB0_ADDR, r2
      b done

  block setup_pid
    val r0, 1
    ldr r1, =ep0_tx_next_data
    strb r0, [r1]

    ldr r5, [r4, 4] /* r5 = setup data addr from bd */
    ldm r5!, {r1, r2}
    ldr r0, =setup_packet
    stm r0!, {r1, r2}

    val r0, 64<<BC | 1<<OWN | 1<<DATA01 | 1<<DTS
    str r0, [r4]

    push {r6, r7}
    uxth r4, r1     /* r4 = bRequest, bmRequestType */
    lsrs r5, r1, 16 /* r5 = wValue */
    uxth r6, r2     /* r6 = wIndex */
    lsrs r7, r2, 16 /* r7 = wLength */
    case_setup r4, 0, 0, 0, SET_ADDRESS, req_set_address
    case_setup r4, 0, 0, 0, SET_CONFIGURATION, reg_set_cfg
    case_setup r4, 1, 0, 0, GET_DESCRIPTOR, req_get_std_desc
    case_setup r4, 1, 0, 1, GET_DESCRIPTOR, req_get_hid_desc
    case_setup r4, 0, 1, 1, SET_IDLE, req_set_idle
    /* TODO: GET_IDLE */
    call ep0_stall
    b done_setup

    block req_set_address
      val r0, 0
      val r1, 0
      b done_tx_zero

    block reg_set_cfg
      cmp r5, 1
      unless eq
        hang
      end
      call ep1_init
      val r1, 1
      ldr r2, =configuration
      strb r1, [r2]
      val r0, 0
      val r1, 0
      b done_tx_zero

    block req_get_std_desc
      lsrs r0, r5, 8 /* r0 = Descriptor type */
      case r0, DEVICE, req_get_desc_dev
      case r0, DEVICE_QUALIFIER, req_get_desc_qual
      case r0, CONFIGURATION, req_get_desc_cfg
      call ep0_stall
      b done_setup

      block req_get_desc_dev
        ldr r0, =desc_dev_ram
        val r1, desc_dev_end - desc_dev
        b done_tx

      block req_get_desc_qual
        call ep0_stall
        b done_setup

      block req_get_desc_cfg
        ldr r0, =desc_cfg_ram
        val r1, desc_ep_end - desc_cfg
        b done_tx

    block req_get_hid_desc
      lsrs r0, r5, 8 /* r0 = Descriptor type */
      case r0, HID, req_get_desc_hid
      case r0, REPORT, req_get_desc_rep
      call ep0_stall
      b done_setup

      block req_get_desc_hid
        ldr r0, =desc_hid_ram
        val r1, desc_hid_end - desc_hid
        b done_tx

      block req_get_desc_rep
        ldr r0, =desc_rep_ram
        val r1, desc_rep_end - desc_rep
        b done_tx

    block req_set_idle
      /* TODO: nonzero idle request */
      val r0, 0
      val r1, 0
      b done_tx_zero

  block done_tx
    cmp r1, r7
    unless ls
      mov r1, r7
    end

  block done_tx_zero
    call ep0_tx

  block done_setup
    pop {r6, r7}

    val r0, 0<<TXSUSPENDTOKENBUSY | 1<<USBENSOFEN
    reg_write USB0_CTL, r0

  block done
    pop {r4, r5, pc}
end

/* IN r0 - Address of data
 * IN r1 - Data length
 */
function ep0_tx
  push {r4, r5, r6}

  val r2, 1
  ldr r3, =ep0_tx_next_odd
  ldrb r4, [r3]
  eors r2, r4
  strb r2, [r3]

  val r2, 1
  ldr r3, =ep0_tx_next_data
  ldrb r5, [r3]
  eors r2, r5
  strb r2, [r3]


  lsls r4, 3
  ldr r6, =bdt_ep0_tx
  add r4, r4, r6 /* r4 = &bd */

  str r0, [r4, 4] /* bd->addr = r0 */

  lsls r1, BC
  val r2, 1<<OWN | 1<<DTS
  orrs r1, r2
  lsls r5, DATA01
  orrs r1, r5
  str r1, [r4] /* bd = r1<<BC | 1<<OWN | r5<<DATA01 | 1<<DTS */

  pop {r4, r5, r6}
  bx lr
end

function ep0_stall
  val r0, 1<<EPRXEN | 1<<EPTXEN | 1<<EPSTALL | 1<<EPHSHK
  reg_write USB0_ENDPT0, r0
  bx lr
end

function ep1_init
  ldr r2, =ep1_tx_buf
  val r0, 0
  str r0, [r2]
  str r0, [r2, 4]
  str r0, [r2, 8]
  str r0, [r2, 12]

  val r0, 1<<EPTXEN | 1<<EPHSHK
  reg_write USB0_ENDPT1, r0

  /* Send one empty record */
  ldr r1, =bdt_ep1_tx
  val r0, 7<<BC | 1<<OWN | 1<<DTS
  str r0, [r1]
  str r2, [r1, 4] /* bdt_ep1_tx_even.addr = ep1_tx_buf_even */

  val r0, 0 /* OWN bit not set */
  str r0, [r1, 8]
  adds r2, 8 /* r2 = ep1_tx_buf_odd */
  str r2, [r1, 12]

  ldr r1, =ep1_tx_next_odd
  ldr r2, =ep1_tx_next_data
  val r0, 1
  strb r0, [r1]
  strb r0, [r2]
  bx lr
end

/* IN r0 - address of buffer descriptor
 * IN r1 - &ep1_tx_next_odd */
function ep1_tx
  ldrb r2, [r1]
  val r3, 1
  eors r2, r3
  strb r2, [r1]

  ldr r1, =ep1_tx_next_data
  ldrb r2, [r1]
  eors r3, r2
  strb r3, [r1]

  val r1, 7<<BC | 1<<OWN | 1<<DTS
  lsls r2, DATA01
  orrs r1, r2
  str r1, [r0]

  bx lr
end

/* IN r0 - address of current report buffer
 * OUT r0 - 0 if no change, 1 if the report has changed */
function scan
  push {r0, r4, r5, lr}

  ldr r3, =right_state
  ldr r2, [r3]
  ldr r3, [r3, 4]

  .macro scan_action i
    .if \i < 32
      nz lsls, r0, \i
      orrs r2, r0
    .else
      nz lsls, r0, \i - 32
      orrs r3, r0
    .endif
  .endm
  .macro map side, pin, keycode
    .ifc \side, left
      gpio_scan_map \pin, \keycode, r4
    .endif
  .endm
  gpio_scan r4
  .purgem map

  pop {r0}
  mov r4, r0
  val r5, 1<<3
  eors r5, r4 /* r5 = address of other report buffer */
  ldr r0, [r5]
  ldr r1, [r5, 4]
  call debounce
  str r0, [r4]
  str r1, [r4, 4]

  /* ldr r0, [r4] */
  ldr r1, [r5]
  cmp r0, r1
  unless eq
    val r0, 1
    pop {r4, r5, pc}
  end
  ldr r0, [r4, 4]
  ldr r1, [r5, 4]
  cmp r0, r1
  unless eq
    val r0, 1
  else
    val r0, 0
  end
  pop {r4, r5, pc}
end
