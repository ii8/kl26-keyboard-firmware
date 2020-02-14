.section .rodata

.balign 4
desc_dev:
.byte  desc_dev_end - desc_dev  @ bLength
.byte  DEVICE                   @ bDescriptorType
.2byte 0x0200                   @ bcdUSB
.byte  0                        @ bDeviceClass
.byte  0                        @ bDeviceSubClass
.byte  0                        @ bDeviceProtocol
.byte  64                       @ bMaxPacketSize0
.2byte 0x0783                   @ idVendor
.2byte 0xDEAD                   @ idProduct
.2byte 0x0100                   @ bcdDevice
.byte  0                        @ iManufacturer
.byte  0                        @ iProduct
.byte  0                        @ iSerialNumber
.byte  1                        @ bNumConfigurations
desc_dev_end:

.balign 4
desc_cfg:
.byte  desc_cfg_end - desc_cfg  @ bLength
.byte  CONFIGURATION            @ bDescriptorType
.2byte desc_ep_end - desc_cfg   @ wTotalLength
.byte  1                        @ bNumInterfaces
.byte  1                        @ bConfigurationValue
.byte  0                        @ iConfiguration
.byte  0b10000000               @ bmAttributes /* TODO: Remote wakeup */
.byte  120                      @ bMaxPower
desc_cfg_end:

desc_if:
.byte  desc_if_end - desc_if    @ bLength
.byte  INTERFACE                @ bDescriptorType
.byte  0                        @ bInterfaceNumber
.byte  0                        @ bAlternateSetting
.byte  1                        @ bNumEndpoints
.byte  0x03                     @ bInterfaceClass
.byte  0                        @ bInterfaceSubClass
.byte  1                        @ bInterfaceProtocol
.byte  0                        @ iInterface
desc_if_end:

desc_hid:
.byte  desc_hid_end - desc_hid  @ bLength
.byte  HID                      @ bDescriptorType
.2byte 0x0111                   @ bcdHID
.byte  0                        @ bCountryCode
.byte  1                        @ bNumDescriptors
.byte  REPORT                   @ bDescriptorType
.2byte desc_rep_end - desc_rep  @ wDescriptorLength
desc_hid_end:

desc_ep:
.byte  desc_ep_end - desc_ep    @ bLength
.byte  ENDPOINT                 @ bDescriptorType
.byte  0x81                     @ bEndpointAddress
.byte  0b00000011               @ bmAttributes
.2byte 7                        @ wMaxPacketSize
.byte  1                        @ bInterval
desc_ep_end:


.equiv Usage_Page, 0x05
  .equiv Generic_Desktop, 0x01
  .equiv Key_Codes, 0x07
  .equiv LEDs, 0x08

.equiv Usage, 0x09
  .equiv Keyboard, 0x06

.equiv Collection, 0xA1
  .equiv Application, 0x01
.equiv End_Collection, 0xC0
.equiv Report_Size, 0x75
.equiv Report_Count, 0x95
.equiv Usage_Minimum, 0x19
.equiv Usage_Maximum, 0x29
.equiv Logical_Minimum, 0x15
.equiv Logical_Maximum, 0x25
.equiv Input, 0x81
.equiv Output, 0x91
  .equiv Data, 0
  .equiv Constant, 1
  .equiv Array, 0
  .equiv Variable, 2
  .equiv Absolute, 0
  .equiv Relative, 4

.balign 4
desc_rep:
.byte Usage_Page, Generic_Desktop
.byte Usage, Keyboard
.byte Collection, Application
.byte   Usage_Page, Key_Codes
.byte   Logical_Minimum, 0
.byte   Logical_Maximum, 1
.byte   Report_Size, 1

.byte   Report_Count, 8
.byte   Usage_Minimum, 224
.byte   Usage_Maximum, 231
.byte   Input, Data | Variable | Absolute

.byte   Report_Count, 42
.byte   Usage_Minimum, 4
.byte   Usage_Maximum, 45
.byte   Input, Data | Variable | Absolute

.byte   Report_Count, 6
.byte   Input, Constant
.byte End_Collection
desc_rep_end:

