
MEMORY
{
  flash (rx) : o = 0, l = 64K
  ram   (rw) : o = 0x20000000 - (8K / 4), l = 8K
}

SECTIONS
{
  .text : {
    startup.o(vectors)
    startup.o(.text)
    . = 0x400;
    QUAD(0xFFFFFFFFFFFFFFFF)
    LONG(0xFFFFFFFF)
    BYTE(0xFE)
    BYTE(0xFB)
    BYTE(0xFF)
    BYTE(0xFF)
    *(.text)
    *(.rodata)
  } >flash =0xFF

  .bss : {
    *(.bss)
  } >ram
}

stack_top = ORIGIN(ram) + LENGTH(ram);

