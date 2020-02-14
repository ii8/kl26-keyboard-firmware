.syntax unified
.arch armv6-m
.cpu cortex-m0plus
.thumb

.set _level, 0
.set _type0, 0
.set _type1, 0
.set _type2, 0
.set _type3, 0
.set _type4, 0
.set _current_addr, -1

.macro _up type
.set _level, _level + 1
.if _type4 <> 0
  .error "Control statements nested too deep."
.endif
.set _type4, _type3
.set _type3, _type2
.set _type2, _type1
.set _type1, _type0
.set _type0, \type
.endm

.macro _down
.set _level, _level - 1
.set _type0, _type1
.set _type1, _type2
.set _type2, _type3
.set _type3, _type4
.set _type4, 0
.endm

.macro _jump op, loc
  .if _level == 1
    \op 1\loc
  .elseif  _level == 2
    \op 2\loc
  .elseif  _level == 3
    \op 3\loc
  .elseif  _level == 4
    \op 4\loc
  .else
    .error "Control statements nested too deep."
  .endif
.endm

.macro _target loc
  .if _level == 1
    1\loc\():
  .elseif  _level == 2
    2\loc\():
  .elseif  _level == 3
    3\loc\():
  .elseif  _level == 4
    4\loc\():
  .else
    .error "Control statements nested too deep."
  .endif
  .set _current_addr, -1
.endm

.macro function name
  .thumb_func
  \name\():
  _up 1
  _target 0
.endm

.macro block l
  \l\():
  .set _current_addr, -1
.endm

.macro call f
  bl \f
  .set _current_addr, -1
.endm

.macro unless cond
  _up 2
  _jump b\cond, 3f
.endm

.macro else
  _jump b, 6f
  _target 3
.endm

.macro loop
  _up 3
  _target 1
.endm

.macro until cond
  _jump b\cond, 6f
.endm

.macro while cond
  _jump b\cond, 1b
  _target 6
  _down
.endm

.macro end
  _target 3
  .if _type0 == 1
    .pool
  .elseif _type0 == 3
    _jump b, 1b
  .endif
  _target 6
  _down
.endm

.text
function hang
  call led
  b .
end
.previous

.macro hang
  call hang
.endm

.macro _val_shift r, original_v, v, shift
  .if (\v) % 2 == 0
    .if (\v) / 2 <= 255
      movs \r, (\v) / 2
      lsls \r, \r, \shift + 1
    .else
      _val_shift \r, (\original_v), (\v) / 2, (\shift) + 1
    .endif
  .else
    ldr \r, =(\original_v)
  .endif
.endm

/* Load literal value `v` into register `r` */
.macro val r, v
  .if (\v) <= 255
    movs \r, (\v)
  .elseif (\v) <= 2*255
    movs \r, 255
    adds \r, (\v) - 255
  .else
    _val_shift \r, \v, \v, 0
  .endif
.endm

/* Extract value of `field` from `rm`, zero extend it to 32 bits,
 * and write the result to `rd`. */
.macro ext rd, rm, field, scratch=r2
  .ifndef \field\()_WIDTH
    .error "Width not defined for field \field"
  .endif
  .if \field == 0
    .if \field\()_WIDTH == 8
      uxtb rd, rm
    .elseif \field\()_WIDTH == 16
      uxth rd, rm
    .else
      .ifc \rd, \rm
        val \scratch, (1 << \field\()_WIDTH) - 1
        ands \rd, \scratch
      .else
        val \rd, (1 << \field\()_WIDTH) - 1
        ands \rd, \rm
      .endif
    .endif
  .else
    lsrs \rd, \rm, \field
    .if \field\()_WIDTH == 8
      uxtb rd, rm
    .elseif \field\()_WIDTH == 16
      uxth rd, rm
    .else
      val \scratch, (1 << \field\()_WIDTH) - 1
      ands \rd, \scratch
    .endif
  .endif
.endm

/* Shift the bits of `mut_reg` right by `n`, if the last bit shifted out
 * was set before the shift, branch to `block` */
.macro case_lsb mut_reg, n, block
  lsrs \mut_reg, \mut_reg, \n
  bcs \block
.endm

/* If the contents of `reg` are equal to the value `v`, branch to `block` */
.macro case reg, v, block, scratch=r2
  .if (\v) <= 255
    cmp \reg, \v
  .else
    val \scratch, \v
    cmp \reg, \scratch
  .endif
  beq \block
.endm

.macro _mem_op op, addr, r
  .if _current_addr <> (\addr & 0xFFFFFFE0)
    ldr r3, =(\addr & 0xFFFFFFE0)
    .set _current_addr, (\addr & 0xFFFFFFE0)
  .endif
  \op \r, [r3, \addr & 0x1f]
.endm

.macro reg_read rd, reg
  .if \reg\()_WIDTH == 8
    _mem_op ldrb, \reg, \rd
  .elseif \reg\()_WIDTH == 16
    _mem_op ldrh, \reg, \rd
  .elseif \reg\()_WIDTH == 32
    _mem_op ldr, \reg, \rd
  .else
    .error "Width not defined for register \reg"
  .endif
.endm

.macro reg_write reg, rs
  .if \reg\()_WIDTH == 8
    _mem_op strb, \reg, \rs
  .elseif \reg\()_WIDTH == 16
    _mem_op strh, \reg, \rs
  .elseif \reg\()_WIDTH == 32
    _mem_op str, \reg, \rs
  .else
    .error "Width not defined for register \reg"
  .endif
.endm

.macro def sym, val, width
  .equiv \sym, \val
  .equiv \sym\()_WIDTH, \width
.endm

.macro nz op, r, i
  .if \i
    \op \r, \i
  .endif
.endm

