//File: assign1b.asm
//Author: Mohammed Hossain
//Date: sept 27, 2022


print:	.string	"Current max: %d |x = %d | y= %d |\n"

define(x_r, x19)
define(max_val,x25)
define(y_r, x22)

	.global main
	.balign 4
main:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	x_r, -10			// x = =10
	b	test				//branch test

main_body:
	mov	x20, -103			//x20 = -103
	mov	x21, 56				//x21 = 56

	madd	x21, x21, x_r, x20		//x21 =56x +(-103)

	mov	x20, 301			//set x20 = 301
	mul	x23, x_r, x_r			//x^2
	madd	x20, x20, x23, x21			//x20 = 301x^2 + 56x - 37

	mov	x22, -4				//set x22 = 4
	mul 	x24, x23, x23			// x^4
	madd	x22, x22, x24, x20		// -4x^4 + 301x^2 + 56x - 103

						
	cmp 	max_val, 0			//x25 = Max_value and is set to 0
	b.eq 	if				//setting x25 = x22 beacuse of the first loop x25 is 0
	b	else

if:
	mov	max_val, y_r			// max_val = x22
	b	continue

else:
	cmp	max_val, y_r
	b.gt	continue			//if current max < new Y value then than branch and continue

	mov	max_val, y_r			//if new Y val> then max_val then update max_val

continue:
	adrp	x0, print			//set the argument to printf
	add	x0, x0, :lo12:print		//set the argument to printf (lower bits)
	mov	x1, max_val			//set Argument 1
	mov	x2, x_r				//set Argumnet 2
	mov 	x3, y_r				//set Argumetn 3
	bl	printf				//call printf

	add	x_r, x_r, 1			//i++

test:
	cmp	x19, 11
	b.lt	main_body			//if x < 10 then loop agian of not dont loop and exit

exit:

	ldp x29, x30, [sp], 16
	ret











