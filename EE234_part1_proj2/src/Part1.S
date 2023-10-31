.text
.global main

@define constants, these can be used as symbols in your code
.set SSD_BASE, 0x43C10000
.set VAL, 0x0F8A0682
.set BTN_BASE, 0x41200000



@the set and equ directives are equivalent and can be used interchangeably

	main:


	LDR R1, =SSD_BASE
	LDR R2, =BTN_BASE
	LDR R12, =0x40000 //counter
	MOV R0, #0X01
	STR R0, [R1] // enable 7-seg (default mode)
	LDR R0, =VAL
    //STR R0, [R1, #0x04]
	MOV r4, #0x0 // Previous Value
	mov r7, #0x0 //intial value for storing the counter
	mov r3, #0
	mov r9, #0 //starting time

	loop1:
	mov r9, #0
	mov r4, r3
	ldr r3, [r2] // get pushbtn data
	and r3, r3, #0x01 // only btn[0]
	mvn r4, r4
	and r5, r3, r4 // get 0 or 1
	//check for the first rising edge
	cmp r5, #1
	BEQ start_counting
	b loop1


	start_counting:
	add r9, r9, #1
	cmp r9, r12 // ignore rising and falling edge in that specific period
	BLE start_counting
	b loop2

	loop2:
	add r7, r7, r5 //increasing
	and r7, r7, #15
    STR R7, [R1, #0x04]
	b loop1

	.end
