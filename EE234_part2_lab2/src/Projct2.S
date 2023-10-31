.global main

@define constants, these can be used as symbols in your code
.equ LED_CTL, 0x41210000
.set SW_DATA, 0x41220000
.set LD4_BASE, 0x43C00000 //RGB




@the set and equ directives are equivalent and can be used interchangeably

main:
	ldr r1,=SW_DATA	@load switch address from constant
	ldr r3,= LD4_BASE
	ldr r12, = 840000 //counter

	//enabling RGB LED
	MOV R0, #0x01
	STR R0, [R3, #0x00]	// enable R of LD4
	STR R0, [R3, #0x10]	// enable G of LD4
	STR R0, [R3, #0x20]	// enable B of LD4
	// Period

	MOV R0, #0xFF  // 255
	STR R0, [R3, #0x04]  // Period of R of LD4 = 255
	STR R0, [R3, #0x14]  // Period of G of LD4 = 255
	STR R0, [R3, #0x24]  // Period of B of LD4 = 255

	//STR R14, [R3, #0x28]  // Width of R of LD4 = 255 (always on)
	//STR R8, [R3, #0x08]  // Width of B of LD4 = 0 (always off)
	//STR R11, [R3, #0x18]  // Width of G of LD4 = 0 (always off)

mov r14, #0

mov r10, #0x28

//Red
	Red_bright:
	add r9, r3,r10
	STR R14, [R9]  // Width of R of LD4 = 255 (always on)
	add r14, r14, #1 //increase the brightness
	mov r5, #0 //delay counting
	b Red_delay_bright

	Red_delay_bright:
	add r5, r5, #1 //counting
	cmp r5, r12
	BLE Red_delay_bright //wait for a bit until counter reaches to Period
	cmp r14, r0
	BLE Red_bright //as long as less than period bright up otherwise bright down
	b less_bright

	less_bright:
	STR R14, [R9]
	sub r14, r14, #1 // less brightness
	mov r6, #0 // for delay again in less bright
	b Red_delay_again

	Red_delay_again:
	add r6, r6, #1 //counting
	cmp r6, r12
	BLE Red_delay_again//wait until counter reaches to period
	cmp r14, #0 // if it is zero, make it off
	BGT less_bright

	cmp r10,#0x28
	BEQ R2G
	cmp r10, #0x18
	BEQ G2B
	mov r10, #0x28
	b Red_bright

	R2G:
	mov r10, #0x18
	b Red_bright

	G2B:
	mov r10, #0x08
	b Red_bright

/*
	//Green
	Green_bright:
	STR R14, [R3, #0x18]  // Width of R of LD4 = 255 (always on)
	add r14, r14, #1 //increase the brightness
	mov r5, #0 //delay counting
	b Green_delay_bright

	Green_delay_bright:
	add r5, r5, #1 //counting
	cmp r5, r12
	BLE Green_delay_bright //wait for a bit until counter reaches to Period
	cmp r14, r0
	BLE Green_bright //as long as less than period bright up otherwise bright down
	b less_bright1

	less_bright1:
	STR R14, [R3, #0x18]
	sub r14, r14, #1 // less brightness
	mov r6, #0 // for delay again in less bright
	b Green_delay_again

	Green_delay_again:
	add r6, r6, #1 //counting
	cmp r6, r12
	BLE Green_delay_again//wait until counter reaches to period
	cmp r14, #0 // if it is zero, make it off
	BGT less_bright1

	//Blue
	Blue_bright:
	STR R14, [R3, #0x08]  // Width of R of LD4 = 255 (always on)
	add r14, r14, #1 //increase the brightness
	mov r5, #0 //delay counting
	b Blue_delay_bright

	Blue_delay_bright:
	add r5, r5, #1 //counting
	cmp r5, r12
	BLE Blue_delay_bright //wait for a bit until counter reaches to Period
	cmp r14, r0
	BLE Blue_bright //as long as less than period bright up otherwise bright down
	b less_bright2

	less_bright2:
	STR R14, [R3, #0x08]
	sub r14, r14, #1 // less brightness
	mov r6, #0 // for delay again in less bright
	b Blue_delay_again

	Blue_delay_again:
	add r6, r6, #1 //counting
	cmp r6, r12
	BLE Blue_delay_again//wait until counter reaches to period
	cmp r14, #0 // if it is zero, make it off
	BGT less_bright2

	b Red_bright

*/
.end
