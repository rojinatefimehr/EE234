.text
.global main

.set SSD_BASE, 0x43C10000
.set TTC_BASE, 0xF8001000
.set BTN_BASE, 0x41200000

main:
	LDR R3, =BTN_BASE //Get btn
	BL enable_7seg
	BL set_timer
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	BL update_7seg
	B Reset // go to the first state

loop1:
	LDR R0, =TTC_BASE
	LDR R1, [R0, #0x54]  // if the counter reaches the max (0.01s), this will be 1.
	CMP R1, #1
	BNE loop1
	ADD R9, R9, #1
	CMP R9, #10
	BLT loop1
	// the counter is set to 0.01s. Now, whenever R9 becomes 10 (0.1s), we update the 7seg.
	MOV R9, #0
	ADD R10, R10, #1
	CMP R10, #10
	BLT proc1
	MOV R10, #0
	ADD R11, R11, #1
	CMP R11, #10
	BLT proc1
	MOV R11, #0
proc1:
	BL update_7seg
	B St_Run

enable_7seg:
	LDR R0, =SSD_BASE
	MOV R1, #0x01
	STR R1, [R0]
	BX LR

update_7seg:	// var:R9, R10, R11, R12
	LDR R0, =SSD_BASE
	LDR R1, =0x80008080
	ORR r1,r1,r9 //R9 is the first dispaly
	MOV R2, R10, LSL #8 //second digit
	ORR R1, R1, R2
	MOV R2, R11, LSL #16 //third display
	ORR R1, R1, R2
	MOV R2, R12, LSL #24 //fourth
	ORR R1, R1, R2
	STR R1, [R0, #0x04]
	BX LR

set_timer:
	LDR R0, =TTC_BASE
	// 1. [Clock Control] External clock edge: no. Clock source: no (use the system clock).
	// Prescaler: yes (N = 4'b1001 = 9, i.e., divided by 1024. The timer will run one tick every 1024 system clock ticks.).
	// The system clock is 111MHz, the timer will run one tick every 9.23us.
	MOV R1, #0x13
	STR R1, [R0]
	// 2. [Counter Control] Waveform polarity: 0. Output waveform: disable.
	// Counter reset: no. Match mode: no. Up counter. Counter disable.
	MOV R1, #0x21
	STR R1, [R0, #0x0C]
	// 3. [Interval Value] # ticks before the timer resets itself. After the prescale, the frequency
	// of the timer counter is 111MHz / 1024 = 108.4kHz (111MHz is the system clock).
	// If we set the interval to 1083 ticks, an interval will be approximately 0.01 second.
	LDR R1, =#1083
	STR R1, [R0, #0x24]
	// 4. [Interrupt Enable] Enable the interrupt.
	MOV R1, #0x01
	STR R1, [R0, #0x60]
	// 5. Turn on the counter and enable it (interval mode).
	MOV R1, #0x22
	STR R1, [R0, #0x0C]
	BX LR

	//initialize the stopwatch 0000
	Reset:
	MOV R9, #0 //first
	MOV R10, #0 //second
	MOV R11, #0 //third
	MOV R12, #0 //Fourth display
	BL update_7seg

//BTN0: Start the stopwatch. Next state [ST_RUN]
//BTN3: Nothing happens. Next state [ST_RESET]
	St_Reset:
	//get btn
	ldr r4, [r3]
	// if btn[0] start the watch otherwise don't do anything
	cmp r4, #1
	BEQ  St_Run
	B St_Reset

//BTN0: Stop the stopwatch. Next state [ST_STOP]
//BTN3: Stop visualizing the stopwatch, but keep counting in the background. Next state [ST_BG]
	St_Run:
	//if btn[0] stop
	ldr r4, [r3]
	cmp r4, #1
	BEQ St_Stop
	cmp r4, #8 // if btn[3] keep counting in the back
	BEQ St_BG

	LDR R0, =TTC_BASE
	LDR R1, [R0, #0x54]  // if the counter reaches the max (0.01s), this will be 1.
	CMP R1, #1
	BNE St_Run
	ADD R9, R9, #1
	CMP R9, #10
	BLT proc1
	// the counter is set to 0.01s. Now, whenever R9 becomes 10 (0.1s), we update the 7seg.
	MOV R9, #0
	ADD R10, R10, #1
	CMP R10, #10
	BLT proc1
	MOV R10, #0
	ADD R11, R11, #1
	CMP R11, #10
	BLT proc1
	MOV R11, #0
	ADD R12, R12, #1
	CMP R12, #10
	BLT proc1
	MOV R12, #0
	b proc1

//BTN0: Resume the stopwatch. Next state [ST_RUN]
//BTN3: Stop the stopwatch and initialize your stopwatch. Next state [ST_RESET]
	St_Stop:
	ldr r4, [r3]
	cmp r4, #1
	BEQ St_Run
	cmp r4, #8 // if btn[3]=1000
	BEQ Reset // make it zero
	BL update_7seg
	b St_Stop

//BTN0: Stop counting. Show the last time (that was being counted in the background) on the seven-segment display. Next state [ST_STOP]
//BTN3: Keep counting and resume visualizing the stopwatch. Next state [ST_RUN]
	St_BG:
	ldr r4, [r3]
	cmp r4, #1
	BEQ St_Stop
	cmp r4, #8
	BEQ St_Run

	LDR R0, =TTC_BASE
	LDR R1, [R0, #0x54]  // if the counter reaches the max (0.01s), this will be 1.
	CMP R1, #1
	BNE St_BG
	ADD R9, R9, #1
	CMP R9, #10
	BLT St_BG
	// the counter is set to 0.01s. Now, whenever R9 becomes 10 (0.1s), we update the 7seg.
	MOV R9, #0
	ADD R10, R10, #1
	CMP R10, #10
	BLT St_BG
	MOV R10, #0
	ADD R11, R11, #1
	CMP R11, #10
	BLT St_BG
	MOV R11, #0
	ADD R12, R12, #1
	CMP R12, #10
	BLT St_BG
	MOV R12, #0
	b St_BG

	.end


