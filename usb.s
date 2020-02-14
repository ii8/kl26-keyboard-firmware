/* bRequest codes */
.equiv GET_STATUS, 0
.equiv CLEAR_FEATURE, 1
.equiv SET_FEATURE, 3
.equiv SET_ADDRESS, 5
.equiv GET_DESCRIPTOR, 6
.equiv SET_DESCRIPTOR, 7
.equiv GET_CONFIGURATION, 8
.equiv SET_CONFIGURATION, 9
.equiv GET_INTERFACE, 10
.equiv SET_INTERFACE, 11
.equiv SYNC_FRAME, 12

/* Class specific bRequest codes */
.equiv GET_REPORT, 0x01
.equiv GET_IDLE, 0x02
.equiv SET_IDLE, 0x0A

/* Descriptor Types */
.equiv DEVICE, 1
.equiv CONFIGURATION, 2
.equiv STRING, 3
.equiv INTERFACE, 4
.equiv ENDPOINT, 5
.equiv DEVICE_QUALIFIER, 6
.equiv OTHER_SPEED_CONFIGURATION, 7
.equiv INTERFACE_POWER, 8

.equiv HID, 0x21
.equiv REPORT, 0x22
.equiv PHYSICAL_DESCRIPTOR, 0x23

.equiv bmRequestType, 0
.equiv bRequest, 1
.equiv wValue, 2
.equiv wIndex, 4
.equiv wLength, 6
