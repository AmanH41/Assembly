//File: assign1a.s
//Author: Mohammed Hossain
//Date: sept 27, 2022


print:	.string	"Current max: %d |x = %d | y= %d |\n"

	.global main
	.balign 4
main:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	x19, -10			// x = =10

test:
	cmp	x19, 11
	b.eq	exit

main_body:
	mov	x20, -103			//x20 = -103
	mov	x21, 56				//x21 = 56

	mul	x21, x21, x19			//x21 = 56x
	add	x21, x21, x20			//x21= 56x - 103

	mov	x20, 301			//set x20 = 301
	mul	x23, x19, x19			//x^2
	mul 	x20, x20,x23			//x20 = 301 * x^2

	add	x20, x20, x21			//x20 = 301x^2 + 56x - 103

	mov	x22, -4				//set x22 = 4
	mul 	x24, x23, x23			// x^4
	mul	x22, x22, x24			//set x22 = -4x^4

	add	x22, x22, x20			// -4x^4 + 301x^2 + 56x - 103

						
	cmp 	x25,0				//x25 = Max_value and is set to 0
	b.eq 	if				//setting x25 = x22 beacuse of the first loop x25 is 0
	b	else

if:
	mov	x25, x22			// max_val = x22
	b	continue

else:
	cmp	x25, x22
	b.gt	continue			//if current max < new Y value then than branch and continue

	mov	x25, x22			//if new Y val> then max_val then update max_val

continue:
	adrp	x0, print			//set the argument to printf
	add	x0, x0, :lo12:print		//set the argument to printf (lower bits)
	mov	x1, x25				//set Argument 1
	mov	x2, x19				//set Argumnet 2
	mov 	x3, x22				//set Argumetn 3
	bl	printf				//call printf

	add	x19, x19, 1			//i++
	b	test

exit:

	ldp x29, x30, [sp], 16
	ret


