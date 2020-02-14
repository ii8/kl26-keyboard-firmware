.equiv A, 1
.equiv B, 2
.equiv C, 3
.equiv D, 4
.equiv E, 5

.macro defpin pin, port, n
  .equiv PIN\pin\()_PORT, \port
  .equiv PIN\pin\()_NUM, \n
.endm

defpin 0, B, 16
defpin 1, B, 17
defpin 2, D, 0
defpin 3, A, 1
defpin 4, A, 2
defpin 5, D, 7
defpin 6, D, 4
defpin 7, D, 2
defpin 8, D, 3
defpin 9, C, 3
defpin 10, C, 4
defpin 11, C, 6
defpin 12, C, 7
defpin 13, C, 5
defpin 14, D, 1
defpin 15, C, 0
defpin 16, B, 0
defpin 17, B, 1
defpin 18, B, 3
defpin 19, B, 2
defpin 20, D, 5
defpin 21, D, 6
defpin 22, C, 1
defpin 23, C, 2
defpin 24, E, 20
defpin 25, E, 21
defpin 26, E, 30
