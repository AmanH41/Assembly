//File:assign2a.asm
//Author: Mohammed Hossain

print_str:	.string "original: 0x%08X reversed: 0x%08X\n"

//define variables
define(x_r, w19)
define(y_r, w20)
define(t1_r, w21)
define(t2_r, w22)
define(t3_r, w23)
define(t4_r, w24)

	.balign 4
    	.global main

main:
	stp     fp, lr, [sp, -16]!     		// save frame pointer (FP) and link register (LR) to the stack
    	mov     fp, sp                     	// update FP to the top of the stack

//Initialize variable
	mov	x_r, 0x07FC07FC			//x = 0x07FC0fFC

//Reverse bits in the varibles
//step 1
	and	t1_r, x_r, 0x55555555		// (x & 0x55555555)
	lsl	t1_r, t1_r, 1			// t1 = (x & 0x55555555) << 1

	lsr	t2_r, x_r, 1			// (x >> 1)
	and	t2_r, t2_r, 0x55555555		// (x >> 1) & 0x55555555

	orr	y_r, t1_r, t2_r			// y = t1 | t2


//step 2
	and	t1_r, y_r, 0x33333333		// (y & 0x33333333)
	lsl	t1_r, t1_r, 2			//t2 = (y & 0x33333333) << 2

	lsr	t2_r, y_r, 2			// (y >> 2)
	and	t2_r, t2_r, 0x33333333		// t2 = (y >> 2) & 0x33333333

	orr	y_r, t1_r, t2_r			// y = t1 | t2

//step 3
	and     t1_r, y_r, 0x0F0F0F0F      	// (y & 0x0F0F0F0F)
        lsl     t1_r, t1_r, 4              	//t2 = (y & 0x0F0F0F0F) << 4

        lsr     t2_r, y_r, 4            	// (y >> 2)
        and     t2_r, t2_r, 0x0F0F0F0F     	// t2 = (y >> 2) & 0x0F0F0F0F

        orr     y_r, t1_r, t2_r         	// y = t1 | t2

//step 4
	lsl	t1_r, y_r, 24			// t1 = y << 24

	and	t2_r, y_r, 0xFF00		// (y & 0xFF00)
	lsl	t2_r, t2_r, 8			// t2 = (y & 0xFF00) << 8

	lsr	t3_r, y_r, 8			// (y >> 8) 
	and	t3_r, t3_r, 0xFF00		// (y >> 8) & 0xFF00

	lsr	t4_r, y_r, 24			// y >> 24

	orr	y_r, t1_r, t2_r			// y = t1 | t2
	orr	y_r, y_r, t3_r			// y | t3 
	orr	y_r, y_r, t4_r			//y = t1 | t2 | t3 | t4

//Print out the original and reversed variables
	ldr	x0, =print_str
	mov	w1, x_r
	mov	w2, y_r
	bl	printf

    	ldp     fp, lr, [sp], 16    		// clean up lines, restores the stack
	ret
