AS=arm-none-eabi-as
LD=arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy

COMMON_OBJS=startup.o common.o debounce.o

all: left.hex right.hex
left: left.hex
right: right.hex

%.elf: %.o $(COMMON_OBJS)
	$(LD) -T link.ld -o $@ $^

%.hex: %.elf
	$(OBJCOPY) -O ihex -j .text $< $@

clean:
	rm -f *.o *.elf *.hex

*.o: prelude.s
startup.o: sim.s osc.s mcg.s
left.o: sim.s port.s gpio.s nvic.s usbotg.s uart.s usb.s pins.s keycodes.s descriptors.s keymap.s
right.o: sim.s port.s gpio.s uart.s pins.s keycodes.s
common.o: nvic.s port.s gpio.s uart.s
debounce.o: syst.s

.PHONY: all left right clean
.PRECIOUS: %.elf
