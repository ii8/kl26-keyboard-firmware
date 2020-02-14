.include "prelude.s"
.include "syst.s"

.bss
.balign 4

data_start:
/* `state` tracks the recently pressed/released keys, any change of a key
 * whose corresponding bit in `state` is set will be ignored.
 * This is just an optimisation, `state` can be reconstructed from `history`.
 */
state:
  .space 8

/* current changeset in history */
index:
  .space 1
.space 3

/* history of changes to key state, spans the last 8 ms
 * each entry has the bits of keys that have been pressed or released
 * during that millisecond set */
history:
  .space 64

data_end:

.text

.global debounce_init
function debounce_init
  val r0, 0
  ldr r1, =data_start
  val r2, data_end - data_start
  loop
    subs r2, 4
    str r0, [r1, r2]
  while ne

  val r0, 48000 - 1
  reg_write SYST_RVR, r0

  val r0, 0
  reg_write SYST_CVR, r0

  val r0, 1<<CLKSOURCE | 1<<ENABLE
  reg_write SYST_CSR, r0

  bx lr
end

/* IN r0 - Old report 1
 * IN r1 - Old report 2
 * IN r2 - New report 1
 * IN r3 - New report 2
 * OUT r0 - Debounced new report 1
 * OUT r1 - Debounced new report 2
 */
.global debounce
function debounce
  push {r4, r5, r6, r7}

  /* change = in_new XOR in_old */
  eors r2, r0
  eors r3, r1

  /* masked_change = change AND (NOT state) */
  ldr r6, =state
  ldr r4, [r6]
  ldr r5, [r6, 4]
  bics r2, r4
  bics r3, r5

  /* out_new = in_old XOR masked_change */
  eors r0, r2
  eors r1, r3

  /* state = state OR masked_change */
  orrs r4, r2
  orrs r5, r3
  str r4, [r6]
  str r5, [r6, 4]

  /* history[index] = history[index] OR masked_change */
  ldr r6, =history
  ldr r7, =index

  ldrb r4, [r7]
  ldr r5, [r6, r4]
  orrs r5, r2
  str r5, [r6, r4]

  adds r4, 4
  ldr r5, [r6, r4]
  orrs r5, r3
  str r5, [r6, r4]

  reg_read r2, SYST_CSR
  lsrs r2, COUNTFLAG + 1
  unless cc
    /* index = index + 8 mod 64 */
    adds r4, 4
    val r5, 63
    ands r4, r5
    strb r4, [r7]

    /* state = state XOR history[index]
     * history[index] = 0 */
    val r5, 0
    ldr r2, [r6, r4]
    str r5, [r6, r4]
    adds r4, 4
    ldr r3, [r6, r4]
    str r5, [r6, r4]

    ldr r6, =state
    ldr r4, [r6]
    ldr r5, [r6, 4]
    eors r4, r2
    eors r5, r3
    str r4, [r6]
    str r5, [r6, 4]
  end
  pop {r4, r5, r6, r7}
  bx lr
end

