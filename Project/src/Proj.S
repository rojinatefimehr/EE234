.text
.global main

.set LED_BASE, 0x41210000
.set SSD_BASE, 0x43C10000
.set TTC_BASE, 0xF8001000
.set C_ZERO, 0x00000000
.set C_TIMER, 0x09
.set NR_ITER, 100
.set MATRIX_N, 8
.set MATRIX_N2, 256

// R11 (n), R12 (iterator)

main:
	BL init_LED		// turn off all the LEDs.
	BL disable_7seg	// turn it off.
	BL init_var		// R11 has n. You can use it as a global variable to get n.
	BL LED_0001		// turn on the rightmost LED.
	BL set_timer
	B init_matrix
main_loop:
	CMP R12, #NR_ITER	// # iterations
	BGE main_done
	B matrix_mul		// you should implement this subroutine.
main_loop_inc:
	ADD R12, R12, #1
	ADD R13, R13, #MATRIX_N2	// adjust the SP to rerun the matrix multiplication.
	B main_loop
main_done:
	SUB R13, R13, #MATRIX_N2
	BL stop_counter
	B check_answer
check_answer_done:
	BL update_7seg
	B matrix_end


matrix_mul:	// R0 ~ R10, R14 are available. Don't touch R11, R12, R15. Place the result in the stack. See the slides.
MUL R5, R11, R11 //R5=n^2
	mov R0, #0 //i=0
	 //Calculate 2*n^2-1 = offset_a
	mov R2, #2
	mul R2, R2, R5
    SUB R2, R2, #1 //offset a
    //Calculate n^2-1
    SUB R3, R5, #1 //offset b
	i_loop:
	cmp R0, R11
	BGT matrix_end
	mov R1, #0 //j=0
	j_loop:
	cmp R1, R11
	BGT matrix_end
	mov R8, R2 //R8 would store the offset of a
    mov R9, R3 //R9 would store the offset of b
	MOV R10, #0 // result[i][j]=0 initialization
    mov R4, #0 //k=0
    k_loop:
    cmp R4, R11
	BGT matrix_end
	mov R6,  R8, LSL #2 // load A[i][k]make the correct offset of a
	mov R7,  R9, LSL #2 // load B[k][j]make the correct offset of b
	ldr R14, [sp, R6]//load a to R14
    ldr R5, [sp, R7] // load b to R5
    MUL R6, R5, R14 // A[i][k] * B[k][j]
    ADD R10, R10, R6
    SUB R8, R8, #1 //a_offset-1
    SUB R9, R9, R11 //b_offset -n
    add R4, R4, #1
	cmp R4, R11 // we need to make a12.b21
	BLT k_loop
	push {R10} //push the result into the stack
	add R2, R2, #1 //a_offset
	add R1, R1, #1 //j++
	cmp R1, R11
	BLT j_loop
	sub R2, R2, R11 //a-n
	add R3, R3, R11 //b+n
	add R0, R0, #1 //i++
	cmp R0, R11
	BLT i_loop
    B main_loop_inc




init_LED:
	LDR R0, =LED_BASE
	MOV R1, #0
	STR R1, [R0]
	BX LR
LED_0001:
	LDR R0, =LED_BASE
	MOV R1, #1
	STR R1, [R0]
	BX LR
LED_1001:	// wrong
	LDR R0, =LED_BASE
	MOV R1, #9
	STR R1, [R0]
	BX LR
LED_1111:	// correct
	LDR R0, =LED_BASE
	MOV R1, #15
	STR R1, [R0]
	BX LR
set_timer:
	LDR R0, =TTC_BASE
	MOV R1, #C_TIMER
	STR R1, [R0]
	MOV R1, #0x23
	STR R1, [R0, #0x0C]
	LDR R1, =#0x7FFF
	STR R1, [R0, #0x24]
	MOV R1, #0x01
	STR R1, [R0, #0x60]
	MOV R1, #0x22
	STR R1, [R0, #0x0C]
	BX LR
stop_counter:
	LDR R0, =TTC_BASE
	MOV R1, #0x21
	STR R1, [R0, #0x0C]
init_var:
	LDR R0, =C_ZERO
	LDR R1, =C_ZERO
	LDR R2, =C_ZERO
	LDR R3, =C_ZERO
	LDR R4, =C_ZERO
	LDR R5, =C_ZERO
	LDR R6, =C_ZERO
	LDR R7, =C_ZERO
	LDR R8, =C_ZERO
	LDR R9, =C_ZERO
	LDR R10, =C_ZERO
	LDR R11, =MATRIX_N
	LDR R12, =C_ZERO
	BX LR
disable_7seg:
	LDR R0, =SSD_BASE
	MOV R1, #0x00
	STR R1, [R0]
	BX LR
update_7seg:
	LDR R4, =TTC_BASE
	LDR R4, [R4, #0x18]
	LDR R5, =0x80808080
	LDR R1, =0x0000000F

	AND R2, R1, R4
	ORR R5, R5, R2

	MOV R4, R4, LSR #4
	AND R2, R1, R4
	MOV R2, R2, LSL #8
	ORR R5, R5, R2

	MOV R4, R4, LSR #4
	AND R2, R1, R4
	MOV R2, R2, LSL #16
	ORR R5, R5, R2

	MOV R4, R4, LSR #4
	AND R2, R1, R4
	MOV R2, R2, LSL #24
	ORR R5, R5, R2

	LDR R0, =SSD_BASE
	MOV R1, #0x01
	STR R1, [R0]
	STR R5, [R0, #0x04]
	BX LR
init_matrix:
	LDR R0, =C_ZERO
	LDR R1, =C_ZERO
	LDR R2, =C_ZERO
	LDR R3, =C_ZERO
	LDR R4, =C_ZERO
	LDR R5, =C_ZERO
	LDR R6, =C_ZERO
	LDR R7, =C_ZERO
	MOV R0, #2
	MOV R1, #1
	MOV R2, #3
	MOV R3, #4
	MOV R4, #6
	MOV R5, #2
	MOV R6, #4
	MOV R7, #3
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #3
	MOV R1, #8
	MOV R2, #4
	MOV R3, #5
	MOV R4, #2
	MOV R5, #1
	MOV R6, #5
	MOV R7, #3
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #3
	MOV R1, #2
	MOV R2, #1
	MOV R3, #4
	MOV R4, #2
	MOV R5, #3
	MOV R6, #5
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #4
	MOV R1, #2
	MOV R2, #1
	MOV R3, #5
	MOV R4, #6
	MOV R5, #2
	MOV R6, #3
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #3
	MOV R1, #3
	MOV R2, #4
	MOV R3, #2
	MOV R4, #4
	MOV R5, #2
	MOV R6, #3
	MOV R7, #1
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #2
	MOV R1, #4
	MOV R2, #5
	MOV R3, #3
	MOV R4, #2
	MOV R5, #1
	MOV R6, #4
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #2
	MOV R1, #1
	MOV R2, #3
	MOV R3, #4
	MOV R4, #2
	MOV R5, #3
	MOV R6, #1
	MOV R7, #3
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #2
	MOV R1, #4
	MOV R2, #1
	MOV R3, #3
	MOV R4, #2
	MOV R5, #2
	MOV R6, #2
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #4
	MOV R1, #3
	MOV R2, #2
	MOV R3, #1
	MOV R4, #4
	MOV R5, #3
	MOV R6, #2
	MOV R7, #1
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #1
	MOV R1, #3
	MOV R2, #1
	MOV R3, #3
	MOV R4, #1
	MOV R5, #3
	MOV R6, #1
	MOV R7, #3
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #2
	MOV R1, #3
	MOV R2, #2
	MOV R3, #3
	MOV R4, #4
	MOV R5, #2
	MOV R6, #4
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #1
	MOV R1, #3
	MOV R2, #5
	MOV R3, #7
	MOV R4, #1
	MOV R5, #3
	MOV R6, #5
	MOV R7, #7
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #2
	MOV R1, #4
	MOV R2, #1
	MOV R3, #2
	MOV R4, #2
	MOV R5, #4
	MOV R6, #1
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #3
	MOV R1, #3
	MOV R2, #1
	MOV R3, #1
	MOV R4, #3
	MOV R5, #3
	MOV R6, #1
	MOV R7, #1
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #1
	MOV R1, #3
	MOV R2, #2
	MOV R3, #4
	MOV R4, #1
	MOV R5, #3
	MOV R6, #2
	MOV R7, #4
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	MOV R0, #3
	MOV R1, #3
	MOV R2, #2
	MOV R3, #1
	MOV R4, #3
	MOV R5, #3
	MOV R6, #2
	MOV R7, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R4}
	PUSH {R5}
	PUSH {R6}
	PUSH {R7}
	B main_loop
check_answer:
	LDR R0, [SP, #252]
	CMP R0, #50
	BNE wrong_answer
	LDR R0, [SP, #248]
	CMP R0, #81
	BNE wrong_answer
	LDR R0, [SP, #244]
	CMP R0, #53
	BNE wrong_answer
	LDR R0, [SP, #240]
	CMP R0, #75
	BNE wrong_answer
	LDR R0, [SP, #236]
	CMP R0, #56
	BNE wrong_answer
	LDR R0, [SP, #232]
	CMP R0, #78
	BNE wrong_answer
	LDR R0, [SP, #228]
	CMP R0, #59
	BNE wrong_answer
	LDR R0, [SP, #224]
	CMP R0, #75
	BNE wrong_answer
	LDR R0, [SP, #220]
	CMP R0, #54
	BNE wrong_answer
	LDR R0, [SP, #216]
	CMP R0, #95
	BNE wrong_answer
	LDR R0, [SP, #212]
	CMP R0, #66
	BNE wrong_answer
	LDR R0, [SP, #208]
	CMP R0, #102
	BNE wrong_answer
	LDR R0, [SP, #204]
	CMP R0, #62
	BNE wrong_answer
	LDR R0, [SP, #200]
	CMP R0, #91
	BNE wrong_answer
	LDR R0, [SP, #196]
	CMP R0, #74
	BNE wrong_answer
	LDR R0, [SP, #192]
	CMP R0, #101
	BNE wrong_answer
	LDR R0, [SP, #188]
	CMP R0, #44
	BNE wrong_answer
	LDR R0, [SP, #184]
	CMP R0, #68
	BNE wrong_answer
	LDR R0, [SP, #180]
	CMP R0, #49
	BNE wrong_answer
	LDR R0, [SP, #176]
	CMP R0, #69
	BNE wrong_answer
	LDR R0, [SP, #172]
	CMP R0, #46
	BNE wrong_answer
	LDR R0, [SP, #168]
	CMP R0, #67
	BNE wrong_answer
	LDR R0, [SP, #164]
	CMP R0, #51
	BNE wrong_answer
	LDR R0, [SP, #160]
	CMP R0, #70
	BNE wrong_answer
	LDR R0, [SP, #156]
	CMP R0, #52
	BNE wrong_answer
	LDR R0, [SP, #152]
	CMP R0, #81
	BNE wrong_answer
	LDR R0, [SP, #148]
	CMP R0, #55
	BNE wrong_answer
	LDR R0, [SP, #144]
	CMP R0, #76
	BNE wrong_answer
	LDR R0, [SP, #140]
	CMP R0, #54
	BNE wrong_answer
	LDR R0, [SP, #136]
	CMP R0, #80
	BNE wrong_answer
	LDR R0, [SP, #132]
	CMP R0, #57
	BNE wrong_answer
	LDR R0, [SP, #128]
	CMP R0, #77
	BNE wrong_answer
	LDR R0, [SP, #124]
	CMP R0, #45
	BNE wrong_answer
	LDR R0, [SP, #120]
	CMP R0, #70
	BNE wrong_answer
	LDR R0, [SP, #116]
	CMP R0, #41
	BNE wrong_answer
	LDR R0, [SP, #112]
	CMP R0, #61
	BNE wrong_answer
	LDR R0, [SP, #108]
	CMP R0, #53
	BNE wrong_answer
	LDR R0, [SP, #104]
	CMP R0, #66
	BNE wrong_answer
	LDR R0, [SP, #100]
	CMP R0, #49
	BNE wrong_answer
	LDR R0, [SP, #96]
	CMP R0, #58
	BNE wrong_answer
	LDR R0, [SP, #92]
	CMP R0, #42
	BNE wrong_answer
	LDR R0, [SP, #88]
	CMP R0, #71
	BNE wrong_answer
	LDR R0, [SP, #84]
	CMP R0, #48
	BNE wrong_answer
	LDR R0, [SP, #80]
	CMP R0, #73
	BNE wrong_answer
	LDR R0, [SP, #76]
	CMP R0, #52
	BNE wrong_answer
	LDR R0, [SP, #72]
	CMP R0, #66
	BNE wrong_answer
	LDR R0, [SP, #68]
	CMP R0, #58
	BNE wrong_answer
	LDR R0, [SP, #64]
	CMP R0, #70
	BNE wrong_answer
	LDR R0, [SP, #60]
	CMP R0, #42
	BNE wrong_answer
	LDR R0, [SP, #56]
	CMP R0, #59
	BNE wrong_answer
	LDR R0, [SP, #52]
	CMP R0, #44
	BNE wrong_answer
	LDR R0, [SP, #48]
	CMP R0, #56
	BNE wrong_answer
	LDR R0, [SP, #44]
	CMP R0, #48
	BNE wrong_answer
	LDR R0, [SP, #40]
	CMP R0, #56
	BNE wrong_answer
	LDR R0, [SP, #36]
	CMP R0, #50
	BNE wrong_answer
	LDR R0, [SP, #32]
	CMP R0, #56
	BNE wrong_answer
	LDR R0, [SP, #28]
	CMP R0, #35
	BNE wrong_answer
	LDR R0, [SP, #24]
	CMP R0, #56
	BNE wrong_answer
	LDR R0, [SP, #20]
	CMP R0, #37
	BNE wrong_answer
	LDR R0, [SP, #16]
	CMP R0, #54
	BNE wrong_answer
	LDR R0, [SP, #12]
	CMP R0, #37
	BNE wrong_answer
	LDR R0, [SP, #8]
	CMP R0, #55
	BNE wrong_answer
	LDR R0, [SP, #4]
	CMP R0, #39
	BNE wrong_answer
	LDR R0, [SP]
	CMP R0, #55
	BNE wrong_answer
	B correct_answer
correct_answer:
	BL LED_1111
	B check_answer_done
wrong_answer:
	BL LED_1001
	B check_answer_done

matrix_end:

.end
